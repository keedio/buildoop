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

class MainController {
	def LOG
	def wo
	def env
	def BDROOT

	def getTargets() {
		println "Available build targets:\n"
		new File(BDROOT + "/conf/targets/targets.conf").eachLine { 
			line -> 
			if (!((line.trim().size() == 0) || (line[0] == '#'))) {
					println line
			}
		}
	}

	def getVersion() {
		new File(BDROOT + "/VERSION").eachLine { 
			line -> println line
		}
	}

	def getBoms() {
		println "Available build targets:\n"

	}

	def checkEnv() {
		println "Check minimal system tools for buildoop"

	}

	def getInfo() {
		println "information about this buildoop version"

	}

	def MainController(wo, log) {
		LOG = log
		env = System.getenv()
		BDROOT = env["BDROOT"]

		switch (wo["arg"]) {
			case "-version":
				getVersion()
				break

			case "-targets":
				getTargets()
				break

			case "-boms":
				getBoms()
				break

			case "-checkenv":
				checkEnv()
				break

			case "-info":
				if ((wo["bom"] == "") && (wo["pkg"] == "")) {
					getInfo()
				}
				break

			default:
				break
		}

	}
}
