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
 * This class is for building native or stagging tools
 * which are not necessaries to fecth in a RPM/DEB package.
 *
 * If you have to make a RPM/DEB package you have to use
 * the class PackageBuilder.
 *
 * @author Javi Roman <javiroman@redoop.org>
 */
class SourceBuilder {
	def LOG

	def SourceBuilder(log) {
		LOG = log
        	LOG.info "[SourceBuilder] constructor"
	}
}
