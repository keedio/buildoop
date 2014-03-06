class hadoop-conf {
	# one resource in this class: one file resource.

	file {"/etc/hadoop/conf.openbus":
  	        recurse => true,
        	owner => 'root',
        	group => 'root',
		mode => 0755,
		source => "puppet://$puppetserver/modules/hadoop-conf/conf.openbus",
	}
}
