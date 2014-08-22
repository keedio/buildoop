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
%define lib_sqoop /usr/lib/sqoop
%define conf_sqoop %{_sysconfdir}/%{name}/conf
%define conf_sqoop_dist %{conf_sqoop}.dist

%define sqoop_version 1.4.4
%define sqoop_base_version 1.4.4
%define sqoop_release openbus0.0.1_1
%define sqoop_home /usr/lib/sqoop

Name: sqoop
Version: %{sqoop_version}
Release: %{sqoop_release}
Summary:   Sqoop allows easy imports and exports of data sets between databases and the Hadoop Distributed File System (HDFS).
License: APL2
URL: http://incubator.apache.org/sqoop/
Vendor: The Redoop Team
Packager: Marcelo Valle <mvalle@redoop.org>
Group: Development/Libraries
Source0: %{name}-%{sqoop_version}.tar.gz
Source1: rpm-build-stage
Source2: install_%{name}.sh
Source3: sqoop-metastore.sh
Source4: sqoop-metastore.sh.suse
Patch0: sqoop-javaTarget.patch
BuildRequires: asciidoc, xmlto
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
Requires: hadoop-client, avro-libs
Provides: sqoop
Buildarch: noarch

%description 
Sqoop allows easy imports and exports of data sets between databases and the Hadoop Distributed File System (HDFS).

%package metastore
Summary: Shared metadata repository for Sqoop.
URL: http://incubator.apache.org/sqoop/
Group: System/Daemons
Provides: sqoop-metastore
Requires: sqoop = %{version}-%{release} 

%if  %{?suse_version:1}0
 Required for init scripts
Requires: insserv
%endif

%if  0%{?mgaversion}
 Required for init scripts
Requires: initscripts
%endif

# CentOS 5 does not have any dist macro
# So I will suppose anything that is not Mageia or a SUSE will be a RHEL/CentOS/Fedora
%if %{!?suse_version:1}0 && %{!?mgaversion:1}0
# Required for init scripts
Requires: redhat-lsb
%endif


%description metastore
Shared metadata repository for Sqoop. This optional package hosts a metadata
server for Sqoop clients across a network to use.

%prep
%setup -n sqoop-%{sqoop_version}

%patch0 -p1

%build
bash %{SOURCE1}

%clean
rm -fr %{buildroot}


%install
bash %{SOURCE2} \
          --build-dir=$PWD \
          --conf-dir=etc/sqoop/conf.dist \
          --prefix=$RPM_BUILD_ROOT \
	  --lib-dir=usr/lib/sqoop \
          --bin-dir=usr/bin

%pre
getent group sqoop >/dev/null || groupadd -r sqoop
getent passwd sqoop > /dev/null || useradd -c "Sqoop" -s /sbin/nologin \
	-g sqoop -r -d /var/lib/sqoop sqoop 2> /dev/null || :

%post
alternatives --install %{conf_sqoop} %{name}-conf %{conf_sqoop_dist} 30

%preun
if [ "$1" = 0 ]; then
  alternatives --remove %{name}-conf %{conf_sqoop_dist} || :
fi

%post metastore
chkconfig --add sqoop-metastore

%preun metastore
if [ $1 = 0 ] ; then
  service sqoop-metastore stop > /dev/null 2>&1
  chkconfig --del sqoop-metastore
fi

%postun metastore
if [ $1 -ge 1 ]; then
  service sqoop-metastore condrestart > /dev/null 2>&1
fi

%files metastore
%attr(0755,root,root) /etc/init.d/sqoop-metastore
%attr(0755,sqoop,sqoop) /var/lib/sqoop
%attr(0755,sqoop,sqoop) /var/log/sqoop

# Files for main package
%files 
%defattr(0755,sqoop,sqoop)
%{sqoop_home}/*
/usr/bin/*
/etc/sqoop/*
