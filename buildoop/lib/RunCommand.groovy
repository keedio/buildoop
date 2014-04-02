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

/**
 * Run generic commands
 *
 * This class 
 *
 * @author Javi Roman <javiroman@redoop.org>
 *
 */
class RunCommand {
	def LOG

    def RunCommand(log) {
		LOG = log
        LOG.info "[RunCommand] constructor"
	}

	def runCommand(strList)  { 
		assert (strList instanceof String ||
            (strList instanceof List && strList.each{ it instanceof String }))

        /*
         * -string.execute- currently make use of java.lang.Process 
         * under the covers, the deficiencies of that class must 
         * currently be taken into consideration.
         * http://groovy.codehaus.org/Process+Management
		 *
		 * java.lang.Process: in/out/err streams and exit code.
         */
  		def proc = strList.execute()

		/* 
		 * print InputStream of proc line at a line. This gobble the stdout of
		 * the executed command. The try-catch is the recommended way to use 
		 * the streams in Java. This will make sure, that the system resources 
		 * associated with the stream will be released anyway.
         */ 
		try {
  			proc.in.eachLine { line -> println line }
		} catch (e) {
			println "Stream closed"	 
		} finally {
            proc.in.close()
        }

        /* 
		 * Causes the current thread to wait, if necessary, until the 
         * process represented by this Process object has terminated.
		 */
		println "waitFor process"
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

	def runCommand2(strList) throws IOException {

		Process process = null	
		try {
  			process = strList.execute()
    		def out = new StringBuffer()
    		def err = new StringBuffer()
    		process.consumeProcessOutput(out, err)

  	    	process.in.eachLine { line -> println line }
    		if(out.size() > 0) {
				println "[INFO] Std Out ---------------------------"
				println out
			}
    		if(err.size() > 0) {
				println "[INFO] Std Err ---------------------------"
 				println err
			}
    		process.waitFor()
			print "[INFO runCommand2] ( "
			print "command: " + strList
  			println " )"
		} finally {
			if (process.in != null) {
				try {
					println "[INFO] Clossing inputStream"
					process.in.close()
				} catch(IOException ignored) {
					println "[INFO] catch IOException"
					// failsafe
				}
			}
		}
			

  		if (process.exitValue()) {
    	    println "[ERROR] "
  		}

  		assert !process.exitValue()
	}
}

