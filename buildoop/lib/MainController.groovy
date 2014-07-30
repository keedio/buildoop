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
 * @author Javi Roman <javiroman@redoop.org>
 *
 */
class MainController {
    def _buildoop
    def wo
    def LOG
    def BDROOT
    def globalConfig
    def fileDownloader
    def packageBuilder
	def hasDoPackage

    def MainController(buildoop) {
        _buildoop = buildoop
		wo = buildoop.wo
		LOG = buildoop.log
		BDROOT = buildoop.ROOT
		globalConfig = buildoop.globalConfig
	    // custom package by default
		hasDoPackage = true

		String[] roots = [globalConfig.buildoop.classfolder]
		def engine = new GroovyScriptEngine(roots)

		// Load of helpers groovy classes.
		def FileDownloaderClass = engine.loadScriptByName('FileDownloader.groovy')
		fileDownloader = FileDownloaderClass.newInstance(buildoop)

		def PackageBuilderClass = engine.loadScriptByName('PackageBuilder.groovy')
		packageBuilder = PackageBuilderClass.newInstance(buildoop)

		switch (wo["arg"]) {
			case "-version":
				getVersion()
				break

			case "-targets":
				getTargets()
				break

			case "-bom":
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
			case "-clean":
				if (wo["pkg"]) {
					clean(wo["pkg"])
				} else {
					def pkgList = getPkgList(wo["bom"])
					for (i in pkgList) {
						clean(i)
					}
				}
				break
			case "-cleanall":
				if (wo["pkg"]) {
					cleanall(wo["pkg"])
				} else {
					def pkgList = getPkgList(wo["bom"])
					for (i in pkgList) {
						cleanall(i)
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
		new File("VERSION").eachLine { 
			line -> println line
		}
	}

	/**
	 * List the available "bill of materials" files.
	 *
	 * @return Listing of file names *.bom in conf/bom
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
                case {line.contains("#")}:
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
		switch (jsonRecipe.do_fetch.download_cmd) {
				case "git":
					println "git hash    : " + jsonRecipe.do_download.src_hash
					break

				case "wget":
        			println "MD5SUM hash : " + jsonRecipe.do_download.src_md5sum
					break

			 	default:
					break
			}
    }

    def downloadSourceFile(uri, git_hash, outFile) {
		if (git_hash) {
        		return fileDownloader.downloadFromGIT(uri, git_hash, outFile)
				System.exit(1)
		} else {
        		return fileDownloader.downloadFromURL(uri, outFile)
		}
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
        // outFile the source package full path
        def outFile = BDROOT + "/" + 
                    globalConfig.buildoop.downloads + "/" +
                    jsonRecipe.do_download.src_uri.tokenize("/")[-1]

		// FIXME: rework this hack, subversion?
		if (jsonRecipe.do_fetch.download_cmd == "git") {
			outFile = outFile + ".tar.gz"
		}

        def f = new File(outFile + ".done")
        if (!f.exists()) {
            println "Downloading $jsonRecipe.do_download.src_uri ..."
			LOG.info "[MainController:makePhases] do_fetch: $jsonRecipe.do_fetch.download_cmd"

			def git_hash = ""

			if (jsonRecipe.do_fetch.download_cmd == "git") {
				git_hash = jsonRecipe.do_download.src_hash
			}

            long start = System.currentTimeMillis()
            def size = downloadSourceFile(jsonRecipe.do_download.src_uri,
											git_hash,
										  	outFile)

            println "Downloaded: $size bytes"
            long end = System.currentTimeMillis()

            _buildoop.userMessage("OK", "[OK] ")
            println "Elapsed time: " + ((end - start) / 1000) + " seconds ";

		    switch (jsonRecipe.do_fetch.download_cmd) {
				case "git":
                	f.createNewFile() 
					break

				case "wget":
	            	def md5Calculated = fileDownloader.getMD5sum(outFile, size)
            		if (md5Calculated == jsonRecipe.do_download.src_md5sum) {
                		// create done file
                		f.createNewFile() 
            		} else {
                		LOG.error "[makePhases] md5sum fails!!!"
                		LOG.error "[makePhases] md5sum calculated: $md5Calculated" 
                		LOG.error "[makePhases] md5sum from recipe: $jsonRecipe.do_download.src_md5sum"
                		_buildoop.userMessage("ERROR",
                    			"ERROR: md5sum for $jsonRecipe.do_download.src_uri failed:\n")
                		_buildoop.userMessage("ERROR",
                    			"Calculated : $md5Calculated\n")
                		_buildoop.userMessage("ERROR",
                    			"From recipe: $jsonRecipe.do_download.src_md5sum\n")
                		_buildoop.userMessage("ERROR", "Aborting program!\n")
                		System.exit(1)
            		}
					break

			 	default:
					break
			}

        } else {
            _buildoop.userMessage("OK", "[OK]")
            println " Recipe: " + outFile.tokenize('/').last() + " ready to build "
            LOG.info "[makePhases] download .done file exits skipped" 
        }
        
        // 3. extract source

        // 4. build the sources

        /* 
         * 5. package building:
         *
         *    do_package
         *
         * [src:recipes/pig/pig-0.11.1_openbus-0.0.1-r1, 
         *   dest:build/work/pig-0.11.1_openbus0.0.1-r1]
         */
			
	     // check if custom package building
		 try {
			 println jsonRecipe.do_package.commands
		 } catch(e) {
  			hasDoPackage = false
	     }

		 if (!hasDoPackage) {
			// defalt build package
         	def baseFolders = ["src":"", "dest":"", "srcpkg":""]
            def s = pkg.split('.bd')[0].split("/")

         	baseFolders["src"] = globalConfig.buildoop.recipes + "/" + 
								s[-2] + "/" + s[-1]

         	baseFolders["dest"] = globalConfig.buildoop.work + "/" + 
                jsonRecipe.do_info.filename.split('.bd')[0]

         	baseFolders["srcpkg"] = outFile

         	packageBuilder.makeWorkingFolders(baseFolders)
        
         	// build/stamps/pig-0.11.1_openbus0.0.1-r1.done
         	def stampFile = globalConfig.buildoop.stamps + '/' +
                baseFolders["dest"].tokenize('/').last() + ".done"
         	f = new File(stampFile)
         	if (!f.exists()) {
            	packageBuilder.copyBuildFiles(baseFolders)
            	packageBuilder.execRpmBuild(baseFolders, _buildoop)
            	packageBuilder.moveToDeploy(baseFolders, _buildoop)
            	packageBuilder.createRepo(baseFolders, _buildoop)
            	f.createNewFile() 
        	}
        	_buildoop.userMessage("OK", "[OK]")
        	println " Package built with success"
		} else {
			println "Custom package building processing"
		}

        println "TODO .................."
    }
		
	def clean(pkg) {
		def jsonRecipe = loadJsonRecipe(pkg)

		def stampFile = globalConfig.buildoop.stamps + "/" +
				jsonRecipe.do_info.filename.split('.bd')[0] + ".done"

		new File(stampFile).delete()
	}

	def cleanall(pkg) {
		clean(pkg)
		
		def jsonRecipe = loadJsonRecipe(pkg)

		def downloadFile = globalConfig.buildoop.downloads + "/" +
				jsonRecipe.do_download.src_uri.tokenize('/')[-1]

		if (downloadFile.tokenize('.')[-1] == "git") {
			new AntBuilder().delete(dir: downloadFile)
			downloadFile += ".tar.gz"
		}
		new File(downloadFile).delete()
		new File(downloadFile + ".done").delete()
        
		def workPath = globalConfig.buildoop.work + "/" +
				jsonRecipe.do_info.filename.split('.bd')[0]

		new AntBuilder().delete(dir: workPath)	
	}
}
