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
import java.security.MessageDigest

/**
 * Class for download the source files
 *
 * This class implements methods for HTTP, FTP,
 * GIT, SVN source code downloads.
 *
 * @author Javi Roman <javiroman@redoop.org>
 *
 */
class RepositoryDownloader {
	def BDROOT
	def LOG
	def globalConfig
	def runCommand

	def RepositoryDownloader(buildoop) {
		LOG = buildoop.log
		BDROOT = buildoop.ROOT
		globalConfig = buildoop.globalConfig
        LOG.info "[RepositoryDownloader] constructor, checking enviroment"

		String[] roots = [globalConfig.buildoop.classfolder]
		def engine = new GroovyScriptEngine(roots)
		def RunCommandClass = engine.loadScriptByName('RunCommand.groovy')
		runCommand = RunCommandClass.newInstance(buildoop.log)
	}

	def showVersions(url) {
		def repositoryFolder =  BDROOT + "/" + globalConfig.buildoop.remoterepodata +
						"/" + url.split('/')[-2] + "/" + url.split('/')[-1] 
		
		//downloadMetadata(url, repositoryFolder)

		println "YEEEEEEEHAAA --> " + repositoryFolder	
	}

	def downloadMetada(url, repositoryFolder) {
	
		new File(repositoryFolder).mkdir()

		def command = "git clone -n " + url + " " + repositoryFolder
                
		//new AntBuilder().delete(dir: repositoryFolder)

		println "Cloning repository metadata: " +  command
		runCommand.runCommand(["bash", "-c", command])

		return 0
	}
}
