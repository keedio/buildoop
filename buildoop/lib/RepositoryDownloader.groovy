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
	def runCommandInstance
	def _buildoop

	def RepositoryDownloader(buildoop) {
		_buildoop = buildoop
		LOG = buildoop.log
		BDROOT = buildoop.ROOT
		globalConfig = buildoop.globalConfig
        LOG.info "[RepositoryDownloader] constructor, checking enviroment"

		String[] roots = [globalConfig.buildoop.classfolder]
		def engine = new GroovyScriptEngine(roots)
		def RunCommandClass = engine.loadScriptByName('RunCommand.groovy')
		runCommandInstance = RunCommandClass.newInstance(buildoop.log)
	}

	def showVersions(url) {

		def showVersionsOutput = ""		

		def repositoryMetaFolder = getRepositoryMetaFolder(url)		

		downloadMetadata(url, repositoryMetaFolder)

		// Get current tags in github repository
		showVersionsOutput += _buildoop.userMessage("OK", "\nRepository release versions:\n")

		def command = "git --git-dir " + repositoryMetaFolder + "/.git tag"
		showVersionsOutput += runCommand(command)

		// Get current branches in github repository (development branches)
		showVersionsOutput += _buildoop.userMessage("OK", "\nRepository development versions:\n")

		command = "git --git-dir " + repositoryMetaFolder + "/.git/ branch -a | cut -f 3 -d '/' | tail -n +3"
		showVersionsOutput += runCommand(command)

		println showVersionsOutput
		return 0
	}

	def downloadMetadata(url, repositoryMetaFolder) {
	
		new File(repositoryMetaFolder).mkdir()

		// download only metadata information from github
		def command = "git clone -n " + url + " " + repositoryMetaFolder
                
		new AntBuilder().delete(dir: repositoryMetaFolder)

		println "Cloning repository metadata: " +  command
		println runCommand(command)
	}
	
	def downloadRepo(url, version) {

		def release = "release" 	
		def repositoryMetaFolder = getRepositoryMetaFolder(url)
		
		// downloadMetadata
		downloadMetadata(url, repositoryMetaFolder)

		// check if version exists in tags
		def command = "git --git-dir " + repositoryMetaFolder + "/.git tag"

		if (!versionExists(version, command)) {
			// if not exists in  tags check if version exists in branches
			command = "git --git-dir " + repositoryMetaFolder + 
						"/.git/ branch -a | cut -f 3 -d '/' | tail -n +3"

			if (!versionExists(version, command)) {
				println _buildoop.userMessage("ERROR", "\nRepository version '" + version + "' not exits, " +
								"use -remoterepo to ensure you are choosing a correct one")
				return
			}
			else{
				release = "development"
			}
		}

		def recipesDir = getRecipesFolder() + "/" + version
		def bomsDir = getBomsFolder()
		def ant = new AntBuilder();
		File bomFile = new File(recipesDir + "/" + version + ".bom")

		println _buildoop.userMessage("INFO", "\nDownloading recipes " + release + " '" + version + "'......")
		
		ant.delete(dir: recipesDir)
		command = "git clone " + url + " " + recipesDir
		runCommand(command)
		command = "git --work-tree " + recipesDir + " --git-dir " + recipesDir + "/.git checkout " + version
		runCommand(command)

		if (!bomFile.exists()){
			ant.delete(dir: recipesDir)
			println _buildoop.userMessage("ERROR", "\n'" + version + 
								".bom' file doesn't exists in repository project, check your project!!")
			return
		}
		
		// copy bom file to buildoop conf bom directory
		ant.copy(file: recipesDir + "/" + version + ".bom", todir: bomsDir)

		// if release version is downloaded	.git directory is deleted to avoid commits
		if (release == "release"){
			ant.delete(dir: recipesDir + "/.git")
		}
		println _buildoop.userMessage("OK", "\nRecipes " + release + " version '" + version + "' correctly download!!")

	}

	def versionExists(version, command) {
 		def versionsList = runCommand(command).readLines()
		
		for (i in versionsList){
			if (i == version){
				return true
			}
		}
		return false;
	}

	def getRepositoryMetaFolder(url){
		if (url.startsWith("https://"))
        	return  BDROOT + "/" + globalConfig.buildoop.remoterepodata +
                         "/" + url.split('/')[-2] + "/" + url.split('/')[-1]
        if (url.startsWith("git@"))
            return  BDROOT + "/" + globalConfig.buildoop.remoterepodata +
                         "/" + url.split(':')[1].split('/')[0] + "/" + url.split(':')[1].split('/')[1]
	}

	def getRecipesFolder(){
		return BDROOT + "/" + globalConfig.buildoop.recipes
	}

	def getBomsFolder(){
		return BDROOT + "/" + globalConfig.buildoop.bomfiles
	}

	def runCommand(command){
		runCommandInstance.runCommand(["bash", "-c", command])
	}
}
