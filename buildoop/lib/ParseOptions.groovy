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

/**
 * Class for command line parse checking.
 *
 * @author Javi Roman <javiroman@redoop.org>
 *
 */
class ParseOptions {
    def _buildoop
	def arguments = ["-help", "-version", "-checkenv", 
					"-i", "-info", "-b", "-build",
					"-c", "-clean", "-cleanall",
					"-bom", "-targets", "-remoterepo"]
	def packageName = ""
	def bomName = ""
	def validArgs = ["arg":"", "pkg":"", "bom":"", "url":""]
	def BDROOT
	def LOG
	def globalConfig

	/**
	 * ParseOptions constructor.
	 *
	 * @param log Global log for Log4J (root)
	 * @param root Top folder of buildoop program
	 */
	def ParseOptions(buildoop) {
        _buildoop = buildoop
		LOG = buildoop.log
		BDROOT = buildoop.ROOT
		globalConfig = buildoop.globalConfig

        assert _buildoop != null, 'parameter must not be null'
        assert LOG != null, 'parameter must not be null'
        assert BDROOT != null, 'parameter must not be null'
        assert globalConfig != null, 'parameter must not be null'

        LOG.info "[ParseOptions] constructor, checking enviroment"
        LOG.info "[ParseOptions] Buildoop top dir: $BDROOT"
	}

	/**
	 * Show usage and exit
	 */
	def usage() {
        LOG.warn "[usage] Printing usage info"
		println """usage: buildoop [options] | <bom-name> <[options]> 
Options: 
	-help       this help
 	-version    version information
 	-bom 		list available BOM files
 	-target		list available platform targets
 	-checkenv   check minimal enviroment and host tools
	-remoterepo	list available BOM files in remote repository
BOM Options:
 	-i, -info   Show information about the BOM file
 	-b, -build  Buuild all package of the BOM file
	-c, -clean  Clean build object of all packages of BOM file
	-cleanall   Clean all staging, download and object files
Package Options:
 	-i, -info   Show info about package from BOM
 	-b, -build  Build the package from BOM
	-c, -clean  Clean build objects form package 
	-cleanall   Clean all staging, download and object files
	"""
	}

	// FIXME: more eficiency.
	def fileExists(directoryName, fileName) {
        def fileFound = false

        def dir = new File(directoryName)
        dir.eachFileRecurse {
                if (it.isFile()) {
                        if (it.name == fileName) {
                                fileFound = true
                        }
            }
        }
        return fileFound
	}

	/**
	 * Show message error, usage message and abort program.
	 *
	 * @param msg The error message to display user.
	 */
	def parseError(msg) {
        _buildoop.userMessage("ERROR", "ERROR: " + msg + "\n")
		LOG.error "ERROR: " + msg
		usage()
		System.exit(1)
	}

	/**
     * Check the pkg file usgin BOM file version information.
	 *
	 * If the pkg file enter by user is not present in the BOM file
	 * the function returns a null string, otherwise the full path
	 * of the package in the filesystem.
	 *
	 * @param pkg The package name enter by the user.
     * @param bom The already validate BOM file entered by the user.
     *
	 * @return a package full name.
	 */
	def packageBomFile(pkg, bom) {

		def bomfile = BDROOT + "/" + globalConfig.buildoop.bomfiles + 
							   "/" + bom

		LOG.info "[ParseOptions:packageBomFile] checking -$pkg- in $bomfile"

		def recipe = ""
		new File(bomfile).eachLine { 
			line -> 
			if ((line.split("_VERSION")[0]) == (pkg.toUpperCase())) {
				recipe = BDROOT + "/" + 
							globalConfig.buildoop.recipes +	"/" +
							pkg + "/" + pkg + "-" + 
							line.split("=")[1].trim() + ".bd"
			} 
		}
		return recipe
	}

	def packageDirectFile(pkg) {
		def searchpath = BDROOT + "/recipes"
		if (fileExists(searchpath, pkg + ".bd")) {
			return searchpath + "/" + pkg + ".bd"
		} else {
			return ""
		}
	}

	def bomFile(bom) {
		def searchpath = BDROOT + "/conf"
		if (fileExists(searchpath, bom + ".bom")) {
			return true
		} else {
			return false
		}
	}

	def remoteRepo(url) {
		if  (url.length() < 19) {
			retrun false
		}
		
		def domain = url.substring(0,19)
		if (domain == "https://github.com/") {
			return true
		}
		else 
			return false
		}
	}

    def parseOpt(args) {
		LOG.info "[parseOpt] parseOpt method invoked"
		if (args.size() == 0) {
			parseError("You have to put an option parameter")
		}
			
		// option validation
		for (i in args) {
			if (arguments.contains(i)) {
				validArgs["arg"] = i
			}
		}
		
		if (validArgs["arg"] == "") {
			parseError("Option not supported");
		}

		switch (validArgs["arg"]){
			case "-b":
			case "-build":
			case "-c":
			case "-clean":
			case "-cleanall":
				// bom file validation
				for (i in args) {
					if (!arguments.contains(i)) {
						if (bomFile(i)) {
							validArgs["bom"] = i + ".bom"
							break;
						}
					}
			    }

				// package file validation
				for (i in args) {
					if (!arguments.contains(i)) {
						if (validArgs["bom"]) {
							if (validArgs["bom"] != i+".bom") {
								// we have a valid BOM file, check if the pkg file is
								// consistent.
								validArgs["pkg"] = packageBomFile(i, validArgs["bom"])
									parseError("Package name '$i' doesn't exists in " +
													validArgs["bom"])
								}
								break
							}
					} else {
						// we don't have BOM file, only pkg file
						validArgs["pkg"] = packageDirectFile(i)
						// FIXME: we need a target for this function.
						parseError("This function is not yet implemented")
						break
					}
				}
		
				if (validArgs["bom"] == "" && validArgs["pkg"] == "") {
					parseError("You have to put BOM file and/or package name file")
				}
				break;
			case "-remoterepo":
				// remote url validation
				for (i in args) {
					if (!arguments.contains(i)) {
						if (remoteRepo(i)) {
							validArgs["url"] = i
						}
					}
				}
				if (validArgs["url"] == "") {
					parseError("You have to put a github.com repository url")
				}
				break;
			case "-checkenv":
			case "-i":
			case "-info":
			case "-bom":
			case "-targets":
			case "-help":
			case "-version":
				break;
			default:
				break;
		}

		return validArgs
	}
}
