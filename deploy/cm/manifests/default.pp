yumrepo { "epel-repo":
   baseurl => "http://mirror.uv.es/mirror/fedora-epel/6/x86_64/",
   descr => "Epel repo",
   enabled => 1,
   gpgcheck => 0,
}

exec { "yum update":
  command => "/usr/bin/yum -y update",
  require => Yumrepo["epel-repo"]
}

#package { "package_name"
#   require => Exec["yum update"]
#}

#service { "service_name"
#   require => Package["package_name"],
#   ensure => running
#}
