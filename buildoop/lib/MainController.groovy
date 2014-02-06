#!/usr/bin/env groovy 
/* vim:set ts=4:sw=4:et:sts=4:ai:tw=80
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import org.apache.log4j.*
import groovy.util.logging.*
import groovy.json.JsonSlurper;

/**
 * The task controller class.
 *
 * This class check the arguments passed by the
 * user and runs the real buildoop commands.
 *
 * @author Javi Roman <javiroman@kernel-labs.org>
 *
 */
class MainController {
	def LOG
	def wo
	def BDROOT
	def globalConfig
	def fileDownloader

	def MainController(w, l, r, g) {
		wo = w
		LOG = l
		BDROOT = r
		globalConfig = g

		String[] roots = [globalConfig.buildoop.classfolder]
		def engine = new GroovyScriptEngine(roots)

		// Load of helpers groovy classes.
		def FileDownloaderClass = engine.loadScriptByName('FileDownloader.groovy')
		fileDownloader = FileDownloaderClass.newInstance(l, r, g)

		switch (wo["arg"]) {
			case "-version":
				getVersion()
				break

			case "-targets":
				getTargets()
				break

			case "-boms":
				getBoms()
				break

			case "-checkenv":
				checkEnv()
				break

			case "-info":
				if ((wo["bom"] == "") && (wo["pkg"] == "")) {
					// info for the buildoop in general
					getInfo()
				} else if ((wo["bom"] != "") && (wo["pkg"] == "")) {
					// info for the BOM file
					getBomInfo(wo["bom"])
				} else {
					// info for the package in BOM file
					getBomPkgInfo(wo)
				}
				break

			case "-build":
				if (wo["pkg"]) {
					makePhases(wo["pkg"])
				} else {
					def pkgList = getPkgList(wo["bom"])
					for (i in pkgList) {
						makePhases(i)
					}
				}
				break
			default:
				break
		}

	}

	/**
     * Get the list of package recipes to build
     *
     * @param bom BOM filename
	 *
	 * @return A list with the full recipe names
     */
	def getPkgList(bom) {
		def bomfile = BDROOT + "/" + globalConfig.buildoop.bomfiles + 
							   "/" + bom
		def list = []
        new File(bomfile).eachLine {
            line ->
            switch(line){
                case {line.contains("TARGET")}:
                    break
                case {line.contains("#")}:
                    break
                case {line.contains("VERSION")}:
					def capitalname = line.split("_VERSION")[0]
					def name = capitalname.toLowerCase()
                    list << globalConfig.buildoop.recipes + "/" + name + "/" + name + 
							"-" + line.split("=")[1].trim() + ".bd"
                    break
                default:
                    break
            }
        }
        return list
	}

	/**
     * List targets from file targets.conf
	 *
	 * List targets ready to use stored in the file targets.conf.
	 * Example: $ buildoop -targets
	 *
	 *
	 * @param bom The BOM file from user arguments
	 */
	def getTargets() {
		println "Available build targets:\n"
		new File(BDROOT + "/" + globalConfig.buildoop.targetfiles + 
											"/targets.conf").eachLine { 
			line -> 
			if (!((line.trim().size() == 0) || (line[0] == '#'))) {
					println line
			}
		}
	}

	def getVersion() {
		new File(BDROOT + "/VERSION").eachLine { 
			line -> println line
		}
	}

	/**
	 * List the available "bill of materials" files.
	 *
	 * @return Listing of file names *.bom in conf/boms
	 */
	def getBoms() {
		println "Available BOM targets:\n"
		def p = ~/.*\.bom/

		LOG.info "[getBoms] BOM file listing"

		new File(globalConfig.buildoop.bomfiles).eachFileMatch(p) {
			f -> println f.getName()
		}
	}

	def checkEnv() {
		println "Check minimal system tools for buildoop"

	}

	def getInfo() {
		println "information about this buildoop version"

	}

	/**
     * Parse BOM file from user input.
	 *
	 * List the versions of tools and the target stored
	 * in the BOM file from conf/bom/<BOMFILE>.bom.
	 * Example: $ buildoop stable -info
	 *
	 *
	 * @param bom The BOM file from user arguments
	 */
	def getBomInfo(bom) {
		def bomfile = BDROOT + "/" + globalConfig.buildoop.bomfiles + 
							   "/" + bom
		new File(bomfile).eachLine { 
			line -> 
			switch(line){
				case {line.contains("TARGET")}:
					println "Target Platform:\n"
					println line.split("=")[1].trim()
					println "\nEcosystem versions:\n"
					break
				case {line.contains("VERSION")}:
					print line.split("_")[0].trim() + ": "
					println line.split("=")[1].trim()
					break
				default:
					break
			}
		}
	}

	/**
	 * Load the rmecipe file based on JSON
	 *
	 * @param file The full path of the recipe
	 *
	 * @return The JSON formated data
	 */
	def loadJsonRecipe(file) {
		def ret = new JsonSlurper().\
				parse(new File(file).toURL())

		return ret
	}

	/**
     * Parse package file (json recipe) from user input.
	 *
	 * List information about json package file. For list
     * information from package "hadoop" in the BOM file
	 * "stable.bom" this is the command:
     *
	 * Example: $ buildoop stable hadoop -info
	 *
	 * @param bom The BOM file from user arguments
	 */
	def getBomPkgInfo(wo) {
		LOG.info "[getBomPkgInfo] Information about " +
				 wo["pkg"]

		def jsonRecipe = loadJsonRecipe(wo["pkg"])

		println "Recipe name : " + jsonRecipe.do_info.filename
		println "Description : " + jsonRecipe.do_info.description
		println "Home site   : " + jsonRecipe.do_info.homepage
		println "License     : " + jsonRecipe.do_info.license
		println "URL base    : " + jsonRecipe.do_download.src_uri
		println "MD5SUM hash : " + jsonRecipe.do_download.src_md5sum
	}

	def downloadSourceFile(uri, outFile) {
		return fileDownloader.downloadFromURL(uri, outFile)
	}

	/**
     * Package building phases. Probably the most importatnt
     * class in Buildoop.
	 *
	 * 1. Load the recipe JSON data
	 * 2. Download file from JSON URI data and md5sum checking.
	 * 3. Extract the source code and.
	 * 4. Build de tool from source (Makefile, CMake, Maven)
	 * 5. Build the package (RPM, DEB).
	 *
	 * @param wo Command line validated parameters
	 **/
	def makePhases(pkg) {
		LOG.info "[MainController:makePhases] build stages for " + pkg

		/*
         * 1. Load JSON recipe
         *
		 *    FIXME: pending validate JSON schema.
		 */
		def jsonRecipe = loadJsonRecipe(pkg)
		
		/*
         * 2. download and checksum:
		 *
	     *    do_download
         *    do_fetch
		 */
		def outFile = BDROOT + "/" + 
					globalConfig.buildoop.downloads + "/" +
					jsonRecipe.do_download.src_uri.tokenize("/")[-1]

		def f = new File(outFile + ".done")
		if (!f.exists()) {
			println "Downloading $outFile ..."
			long start = System.currentTimeMillis()
			def size = downloadSourceFile(jsonRecipe.do_download.src_uri, outFile)
			println "Downloaded: $size bytes"
			def md5Calculated = fileDownloader.getMD5sum(outFile, size)
		    long end = System.currentTimeMillis()
			println "Elapsed time: " + ((end - start) / 1000) + " seconds";
			if (md5Calculated == jsonRecipe.do_download.src_md5sum) {
				// create done file
				f.createNewFile() 
			} else {
				LOG.error "[makePhases] md5sum fails!!!"
				LOG.error "[makePhases] md5sum calculated: $md5Calculated" 
				LOG.error "[makePhases] md5sum from recipe: $jsonRecipe.do_download.src_md5sum"
				println "ERROR: md5sum for $jsonRecipe.do_download.src_uri failed:"
				println "Calculated : $md5Calculated"
				println "From recipe: $jsonRecipe.do_download.src_md5sum\n"
				println "Aborting program!"
				System.exit(1)
			}
		} else {
			LOG.info "[makePhases] download .done file exits skipped" 
		}
		
		// 3. extract source

		// 4. build the sources

		/* 
	     * 5. package building:
         *
	     *    do_package
	     */

	}
}
