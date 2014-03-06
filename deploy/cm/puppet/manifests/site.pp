# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Base configuration variables

$extlookup_datadir="/etc/puppet/manifests/extdata"
$extlookup_precedence = ["site", "default"]
$puppetserver = 'mncarsnas.condor.local'
$default_buildoop_yumrepo_uri = "http://192.168.33.1:8080/"
$jdk_package_name = extlookup("jdk_package_name", "jdk")

# Base resources for all servers

case $::operatingsystem {
	 /(CentOS|RedHat)/: {
	yumrepo { "buildoop":
   		baseurl => extlookup("buildoop_yumrepo_uri", $default_buildoop_yumrepo_uri),
   		descr => "Buildoop Hadoop Ecosystem",
   		enabled => 1,
   		gpgcheck => 0,
	}
      }
      default: {
	 notify{"WARNING: running on a non-yum platform -- make sure Buildoop repo is setup": }
      }
}
	
package { $jdk_package_name:
	ensure => "installed",
	alias => "jdk",
}

exec { "yum makecache":
  command => "/usr/bin/yum makecache",
  require => Yumrepo["buildoop"]
}

import "cluster.pp"

# Server node roles available:
#   NameNodes
#   ResourceManager
#   Client
#   Gateway
#   HistoryServer
#   Workers
node default {
    $hadoop_datanodes = extlookup("hadoop_datanodes")
    $hadoop_resourcemanager = extlookup("hadoop_resourcemanager")
    $hadoop_client = extlookup("hadoop_client")
    $hadoop_gateway = extlookup("hadoop_gateway")
    $hadoop_historyserver = extlookup("hadoop_historyserver")

    # This node logic has the following assumptions:
    #
    # 1. There is more than one NameNode, so $hadoop_datanodes
    #    is a list of hostnames. This is due to HDFS HA and
    #    Federation.
    # 2. There is only one ResourceManager, no is taken into
    #    account the further YARN HA and horizontal scalability.
    # 3. All the manager nodes (NameNodes, and ResourceManager) 
    #    have a Zookeeper Server.
    # 4. All the NameNodes have a Zookeeper Failover Controller.
    if $::fqdn in $hadoop_datanodes {
    	info("Hadoop NameNode: ${fqdn}")
        include hadoop_datanode
	    exec { "touch MIERDA":
  			    command => "/bin/touch /tmp/MIERDA",
	    }
    } else {
        case $::fqdn {
            $hadoop_resourcemanager: {
    		    info("Hadoop ResourceManager: ${fqdn}")
                include hadoop_resourcemanager
	        }
	        $hadoop_client: {
    		    info("Hadoop Client: ${fqdn}")
                include hadoop_client
	        }
	        $hadoop_gateway: {
    		    info("Hadoop Gateway: ${fqdn}")
                include hadoop_gateway
	        }
	        default: {
    		    info("Hadoop Worker: ${fqdn}")
                include hadoop_worker
	        }
        }
   }
}


