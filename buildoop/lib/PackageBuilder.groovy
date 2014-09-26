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
 * Class for ...
 *
 *
 * @author Javi Roman <javiroman@redoop.org>
 *
 */
class PackageBuilder {
	def BDROOT
	def LOG
	def wo
	def globalConfig
	def specfile

    // rpmbuild -ba -D'_topdir /home/jroman/javi' javi/SPECS/flume.spec
	def PackageBuilder(buildoop) {
		LOG = buildoop.log
		BDROOT = buildoop.ROOT
		globalConfig = buildoop.globalConfig
		wo = buildoop.wo
        LOG.info "[PackageBuilder] constructor"
	}

    def makeWorkingFolders(basefolders) {
        LOG.info "[PackageBuilder:makeWorkingFolders] making folders"
		new File(basefolders["dest"]).mkdir()
		new File(basefolders["dest"] + "/rpmbuild").mkdir()
		new File(basefolders["dest"] + "/rpmbuild/SPECS").mkdir()
		new File(basefolders["dest"] + "/rpmbuild/SOURCES").mkdir()
		new File(basefolders["dest"] + "/rpmbuild/BUILD").mkdir()
    }

	def runCommand(strList)  { 
		assert (strList instanceof String ||
            (strList instanceof List && strList.each{ it instanceof String }))

		/*
	     * Because this functionality (string.execute) currently make use 
	     * of java.lang.Process under the covers, the deficiencies of 
         * that class must currently be taken into consideration. With
	     * the method consumeProcessOutput(). 
         * http://groovy.codehaus.org/Process+Management
	     */
  		def proc = strList.execute()
            proc.consumeProcessOutput(System.out, System.err)
  			proc.in.eachLine { 
				line -> println line 
  		}

  		proc.out.close()
  		proc.waitFor()

  		print "[INFO] ( "
  		if(strList instanceof List) {
    		strList.each { print "${it} " }
  		} else {
    		print "command: " + strList
  		}
  		println " )"

  		if (proc.exitValue()) {
    	println "gave the following error: "
    	println "[ERROR] ${proc.getErrorStream()}"
  		}
  		assert !proc.exitValue()
	}

	/**
     * Copy sources, spec to build/work folder.
	 */
    def copyBuildFiles(basefolders) {
		// rpm/sources staff copy to work folder
		def folderIn = basefolders["src"] + "/rpm/sources/"
		def folderOut = basefolders["dest"] + "/rpmbuild/SOURCES/"
		new AntBuilder().copy(todir:folderOut) {
  				fileset(dir:folderIn)
		}

		// source code package from download area to work folder
        println "copy source code to " + basefolders["dest"] + "/rpmbuild/SOURCES"
		def srcFile = basefolders["srcpkg"]
		def destFile = basefolders["dest"] + "/rpmbuild/SOURCES/" +
							basefolders["srcpkg"].split('/')[-1]
		new AntBuilder().copy(file:srcFile, tofile:destFile)

		// copy SPEC file
        println "copy spec file to " + basefolders["dest"] + "/rpmbuild/SPECS"
		folderIn = basefolders["src"] + "/rpm/specs/"
		folderOut = basefolders["dest"] + "/rpmbuild/SPECS/"
		new AntBuilder().copy(todir:folderOut) {
  				fileset(dir:folderIn)
		}

		new File(folderIn).eachFileRecurse { 
			specfile = it.name
		}
    }

    def execRpmBuild(basefolders, buildoop) {
        def command = "rpmbuild -ba -D'_topdir " + buildoop.ROOT + "/" +
            	basefolders["dest"] + "/rpmbuild" + "' " +
            	basefolders["dest"] + "/rpmbuild/SPECS/" + specfile.split('/')[-1]
                
		println "Executing: " +  command
		runCommand(["bash", "-c", command])
    }

	def moveToDeploy(basefolders, buildoop) {
		// RPMS deploy folder
		def folderIn = buildoop.ROOT + "/" + basefolders["dest"] + 
				"/rpmbuild/RPMS/noarch/"

		def folderExits = new File(folderIn)

		LOG.info "[PackageBuilder] moveToDeploy -> distro version: " + wo["bom"]

		def distverbinpath = 
				buildoop.globalConfig.buildoop.bomdeploybin.
						replace("%DIST/%VER", 
								wo["bom"].minus(".bom").split("-")[0] + "/" +
								wo["bom"].minus(".bom").split("-")[1])

		LOG.info "[PackageBuilder] moveToDeploy -> RPM deploy folder: " + distverbinpath

		def folderOut = buildoop.ROOT + "/" + distverbinpath + "/"
		new File(folderOut).mkdirs()

		if (folderExits.exists()) {
			new File(folderIn).eachFileRecurse {
				new File(folderIn + "/" + it.name).
					renameTo(new File(folderOut + "/" + it.name))
			}
		}

		folderIn = buildoop.ROOT + "/" + basefolders["dest"] +
                	"/rpmbuild/RPMS/x86_64/"
		
		folderExits = new File(folderIn)

		if (folderExits.exists()) {
			new File(folderIn).eachFileRecurse {
				new File(folderIn + "/" + it.name).
					renameTo(new File(folderOut + "/" + it.name))
			}
		}
		
		// SRPMS deploy folder
		folderIn = buildoop.ROOT + "/" + basefolders["dest"] + 
				"/rpmbuild/SRPMS/"

		def distversrcpath = 
				buildoop.globalConfig.buildoop.bomdeploysrc.
						replace("%DIST/%VER", 
								wo["bom"].minus(".bom").split("-")[0] + "/" +
								wo["bom"].minus(".bom").split("-")[1])

		folderOut = buildoop.ROOT + "/" + distversrcpath + "/"
		new File(folderOut).mkdirs()

		new File(folderIn).eachFileRecurse { 
			new File(folderIn + "/" + it.name).
				renameTo(new File(folderOut + "/" + it.name))
		}

	}

	def createRepo(basefolders, buildoop) {
		println "createrepo --simple-md-filenames ."
	}
}
