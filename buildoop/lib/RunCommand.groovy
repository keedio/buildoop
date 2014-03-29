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
		proc.destroy()

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
}

