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
class FileDownloader {
	def BDROOT
	def LOG
	def globalConfig
	def runCommand

	def FileDownloader(buildoop) {
		LOG = buildoop.log
		BDROOT = buildoop.ROOT
		globalConfig = buildoop.globalConfig
        LOG.info "[FileDownloader] constructor, checking enviroment"

		String[] roots = [globalConfig.buildoop.classfolder]
		def engine = new GroovyScriptEngine(roots)
		def RunCommandClass = engine.loadScriptByName('RunCommand.groovy')
		runCommand = RunCommandClass.newInstance(buildoop.log)
	}

	def getMD5sum(file, len) {
		File f = new File(file)
		if (!f.exists() || !f.isFile()) {
				println "Invalid file $f provided"
		}

		def messageDigest = MessageDigest.getInstance("MD5")

		//long start = System.currentTimeMillis()

		f.eachByte(len) { byte[] buf, int bytesRead ->
				messageDigest.update(buf, 0, bytesRead);
		}

		def sha1Hex = new BigInteger(1, messageDigest.digest()).toString(16)

		//long delta = System.currentTimeMillis()-start

		return "$sha1Hex"
	}


	def downloadFromGIT(uri, git_hash, outFile) {

		def repository_folder =  BDROOT + "/" + globalConfig.buildoop.downloads +
						"/" + uri.split('/')[-1]

		new File(repository_folder).mkdir()

		def repository =  repository_folder + "/" + uri.split('/')[-1]

		def command = "git clone " + uri + " " + repository
                
		new AntBuilder().delete(dir: repository_folder)

		println "cloning repository: " +  command
		runCommand.runCommand(["bash", "-c", command])

		command = "git " + "--work-tree " + repository + " --git-dir " + repository + 
				"/.git" + " checkout " +
				git_hash

		println "checking out hash: " +  command
		runCommand.runCommand(["bash", "-c", command])

		new AntBuilder().tar(destfile: outFile,
					basedir: repository_folder,
					longfile: "gnu",
					compression: "gzip",
					excludes: ".git")

		return 0
	}

	def downloadFromURL(address, outFile) {
		def contentLength

		def strUrl = address
		def url = new URL(strUrl)
		def connection = url.openConnection()
		connection.connect()

		// Check if the request is handled successfully  
		if(connection.getResponseCode() / 100 == 2) {
				// size of the file to download (in bytes)  
				contentLength = connection.getContentLength()
		}

		def file = new FileOutputStream(outFile)
		def out = new BufferedOutputStream(file)

		out << new URL(address).openStream()

		out.close()

		return contentLength
	}
}
