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

class PackageBuilder {
	def BDROOT
	def LOG
	def globalConfig

    // rpmbuild -ba -D'_topdir /home/jroman/javi' javi/SPECS/flume.spec
	def PackageBuilder(buildoop) {
		LOG = buildoop.log
		BDROOT = buildoop.ROOT
		globalConfig = buildoop.globalConfig
        LOG.info "[PackageBuilder] constructor"
	}

    def makeWorkingFolders(basefolder) {
        LOG.info "[PackageBuilder:makeWorkingFolders] making folders"
		new File(basefolder).mkdir()
		new File(basefolder + "/rpmbuild").mkdir()
		new File(basefolder + "/rpmbuild/SPECS").mkdir()
		new File(basefolder + "/rpmbuild/SOURCES").mkdir()
		new File(basefolder + "/rpmbuild/BUILD").mkdir()
    }


	def copyFile(src,dest) {
 
		def input = src.newDataInputStream()
		def output = dest.newDataOutputStream()
 
		output << input 
 
		input.close()
		output.close()
	}

	def runCommand(strList)  { 
		assert (strList instanceof String ||
            (strList instanceof List && strList.each{ it instanceof String }))

  		def proc = strList.execute()
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

    def copyBuildFiles(basefolder) {
        println "copy source code to " + basefolder + "/rpmbuild/SOURCES"
        println "copy spec file to " + basefolder + "/rpmbuild/SPECS"
 
		def folderIn = 'buildoop.git/recipes/flume/flume-1.4.0_openbus-0.0.1-r1/rpm/sources/'
		def folderOut = 'work/rpmbuild/SOURCES/'

		new File(folderIn).eachFileRecurse { 
			copyFile(new File(folderIn + it.name), 
				 new File(folderOut + it.name))
		}

		srcFile  = new File("buildoop.git/build/downloads/apache-flume-1.4.0-src.tar.gz") 
		destFile = new File("work/rpmbuild/SOURCES/apache-flume-1.4.0-src.tar.gz")

		copyFile(srcFile, destFile)

		srcFile  = new File("buildoop.git/recipes/flume/flume-1.4.0_openbus-0.0.1-r1/rpm/specs/flume.spec") 
		destFile = new File("work/rpmbuild/SPECS/flume.spec")

		copyFile(srcFile, destFile)
    }

    def execRpmBuild(basefolder) {
        println "executing rpmbuild -ba -D'_topdir " +
            basefolder + "/rpmbuild" + "' " +
            basefolder + "/rpmbuild/SPECS" + "/flume.spec"
                
		runCommand(["bash", "-c", 
			"rpmbuild -ba -D\'_topdir /home/jroman/work/rpmbuild\' work/rpmbuild/SPECS/flume.spec"])
		runCommand(["bash", "-c", command])
    }
}

















