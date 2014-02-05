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
				// FIXME: hardcoded for testing
				wo["pkg"] = "recipes/flume/flume-1.4.0_bigtop-r1.bd"
				makeBuild(wo)
				break
			default:
				break
		}

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
	 * Load the recipe file based on JSON
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
		println "Download cmd: " + jsonRecipe.do_fetch.download_cmd
		println "Build cmds  : " + jsonRecipe.do_compile.commands
		println "Build pkg   : " + jsonRecipe.do_package.commands

	}

	def makeBuild(wo) {
		LOG.info "[makeBuild] Building " +
				 wo["pkg"]

		def jsonRecipe = loadJsonRecipe(wo["pkg"])
		
		def outFile = BDROOT + "/" + 
					globalConfig.buildoop.downloads + "/" +
					jsonRecipe.do_download.src_uri.tokenize("/")[-1]

		def size = fileDownloader.downloadFromURL(jsonRecipe.do_download.src_uri, 
													outFile)
		println fileDownloader.getMD5sum(outFile, size)
		println jsonRecipe.do_download.src_md5sum
	}

}
