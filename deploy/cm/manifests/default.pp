yumrepo { "epel-repo":
   baseurl => "http://mirror.uv.es/mirror/fedora-epel/6/x86_64/",
   descr => "Epel repo",
   enabled => 1,
   gpgcheck => 0,
}

yumrepo { "buildoop":
   baseurl => "http://192.168.33.1:8080/",
   descr => "Buildoop Hadoop Ecosystem",
   enabled => 1,
   gpgcheck => 0,
}

exec { "yum update":
  command => "/usr/bin/yum -y update",
  require => Yumrepo["epel-repo"]
}

exec { "yum makecache":
  command => "/usr/bin/yum makecache",
  require => Yumrepo["buildoop"]
}

#package { "package_name"
#   require => Exec["yum update"]
#}

#service { "service_name"
#   require => Package["package_name"],
#   ensure => running
#}
