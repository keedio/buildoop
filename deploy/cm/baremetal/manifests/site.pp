$extlookup_datadir="/etc/puppet/manifests/extdata"
$extlookup_precedence = ["site", "default"]
$puppetserver = 'mncarsnas.condor.local'
$default_buildoop_yumrepo_uri = "http://192.168.33.1:8080/"
$jdk_package_name = extlookup("jdk_package_name", "jdk")

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

#import cluster

node default {
    $hadoop_datanodes = extlookup("hadoop_datanodes")
    $hadoop_resourcemanager = extlookup("hadoop_resourcemanager")
    $hadoop_client = extlookup("hadoop_client")
    $hadoop_gateway = extlookup("hadoop_gateway")

    if $::fqdn in $hadoop_datanodes {
    	info("Hadoop NameNode: ${fqdn}")
	exec { "touch MIERDA":
  			command => "/bin/touch /tmp/MIERDA",
	}
    } else {
        case $::fqdn {
            $hadoop_resourcemanager: {
    		info("Hadoop ResourceManager: ${fqdn}")
	    }
	    $hadoop_client: {
    		info("Hadoop Client: ${fqdn}")
	    }
	   $hadoop_gateway: {
    		info("Hadoop Gateway: ${fqdn}")
	    }
	   default: {
    		info("Hadoop Worker: ${fqdn}")
	    }
        }
   }
}


