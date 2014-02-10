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

    def copyBuildFiles(basefolder) {
        println "copy source code to " + basefolder + "/rpmbuild/SOURCES"
        println "copy spec file to " + basefolder + "/rpmbuild/SPECS"
    }

    def execRpmBuild(basefolder) {
        println "executing rpmbuild -ba -D'_topdir " +
            basefolder + "/rpmbuild" + "' " +
            basefolder + "/rpmbuild/SPECS" + "/flume.spec"
                


    }
}

















