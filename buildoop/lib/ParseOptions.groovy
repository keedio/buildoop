package lib.ParseOptions

class ParseOptions {
	def arguments = ["-help", "-version", "-checkenv", 
					"-i", "-info", "-b", "-build",
					"-c", "-clean", "-cleanall",
					"-boms", "-targets"]
	def packageName = ""
	def bomName = ""
	def validArgs = ["arg":"", "pkg":"", "bom":""]
	def env

	def ParseOptions() {
		env = System.getenv()
	}

	def usage() {
		println """usage: buildoop [options] | <bom-name> <[options]> 
Options: 
	-help       this help
 	-version    version information
 	-checkenv   check minimal enviroment and host tools
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

	def parseError(msg) {
		println "ERROR: " + msg + "\n"
		usage()
		System.exit(1)
	}

	def packageBomFile(pkg, bom) {
		return "recipe/hadoop/" + pkg
	}

	def packageDirectFile(pkg) {
		def searchpath = env["BDROOT"] + "/recipes"
		if (fileExists(searchpath, pkg + ".bd")) {
			return searchpath + "/" + pkg + ".bd"
		} else {
			return ""
		}
	}

	def bomFile(bom) {
		def searchpath = env["BDROOT"] + "/conf"
		if (fileExists(searchpath, bom + ".bom")) {
			return true
		} else {
			return false
		}
	}

    def parseOpt(args) {

		if (args.size() == 0) {
			usage()
			System.exit(1)
		}
			
		if (args.size() > 3) {
			parseError("Wrong numer of arguments")
			System.exit(1)
		}

		// option validation
		for (i in args) {
			if (arguments.contains(i)) {
				validArgs["arg"] = i
			}
		}

		if (validArgs["arg"] == "") {
			parseError("You have to put an option parameter")
		}

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
						validArgs["pkg"] = packageBomFile(i, validArgs["bom"])
						break
					}
				} else {
					validArgs["pkg"] = packageDirectFile(i)
					break
				}
			}
		}

		println validArgs

		if (validArgs["bom"] == "" && validArgs["pkg"] == "") {
			parseError("You have to put BOM file and/or package name file")
		}
	}
}
