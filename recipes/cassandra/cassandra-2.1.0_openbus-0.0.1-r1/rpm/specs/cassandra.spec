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

%define cassandra_name cassandra
%define cassandra_home /usr/lib/cassandra
%define cassandra_config /etc/cassandra/conf
%define cassandra_user cassandra
%define cassandra_group cassandra
%define cassandra_user_home /var/lib/%{cassandra_name}
%define cassandra_daemon_run /var/run/%{cassandra_name}
%define cassandra_service cassandra

%global initd_dir %{_sysconfdir}/rc.d/init.d
# prevent binary stripping - not necessary at all.
# Only for prevention.
%global __os_install_post %{nil}

%define cassandra_version 2.1.0
%define cassandra_base_version 2.1.0
%define cassandra_release openbus0.0.1_1

Name: %{cassandra_name}
Version: %{cassandra_version}
Release: %{cassandra_release}
Summary: Cassandra is a scalable and high availabe database without compromising performance.
License: APL2
URL: http://http://cassandra.apache.orgn
Vendor: The Redoop Team
Packager: Marcelo Valle <mvalle@redoop.org>
Group: Applications/Databases
Source0: apache-%{cassandra_name}-%{cassandra_version}-src.tar.gz
Source1: rpm-build-stage
Source2: install_cassandra.sh
Patch0: dataDirectoriesConfig.patch
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
Requires: jdk
Provides: cassandra
BuildArch: noarch

# Required for init scripts
Requires: redhat-lsb

%description
The Apache Cassandra database is the right choice when you need 
scalability and high availability without compromising performance. 
Linear scalability and proven fault-tolerance on commodity hardware 
or cloud infrastructure make it the perfect platform for 
mission-critical data. Cassandra's support for replicating across 
multiple datacenters is best-in-class, providing lower latency for 
your users and the peace of mind of knowing that you can survive regional outages.

%prep
%setup -n apache-%{cassandra_name}-%{cassandra_version}-src
%patch0 -p1

%build
bash %{SOURCE1}

%clean
rm -rf %{buildroot}

%install
bash %{SOURCE2}\
	--build-dir=$PWD \
     	--prefix=%{buildroot} \
	--source-dir=$RPM_SOURCE_DIR

# Install init script
  echo "Installing service: %{cassandra_service}"
  init_file=$RPM_BUILD_ROOT/%{initd_dir}/%{cassandra_service}
  bash $RPM_SOURCE_DIR/init.d.tmpl $RPM_SOURCE_DIR/%{cassandra_service}.svc rpm > $init_file

%pre
getent group %{cassandra_group} >/dev/null || groupadd -r %{cassandra_group}
getent passwd %{cassandra_user} >/dev/null || /usr/sbin/useradd --comment "Cassandra Daemon User" --shell /sbin/nologin -M -r -g %{cassandra_group} --home %{cassandra_user_home} %{cassandra_user}

%preun
  /sbin/service %{cassandra_name} status > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    /sbin/service %{cassandra_name} stop > /dev/null 2>&1
  fi
done

%files
%defattr(-,%{cassandra_user},%{cassandra_group})
%dir %attr(755, %{cassandra_user},%{cassandra_group}) %{cassandra_home}
%dir %attr(755, %{cassandra_user},%{cassandra_group}) /etc/cassandra
%config(noreplace) /etc/cassandra
%dir %attr(755, %{cassandra_user},%{cassandra_group}) /var/lib/cassandra
%dir %attr(755, root,root) /%{initd_dir}
%dir %attr(755, root,root) /etc/default
%attr(0755,root,root)/%{initd_dir}/%{cassandra_service}
%attr(0644,root,root)/etc/default/%{cassandra_service}
%{cassandra_home}/*
/etc/cassandra/*
/var/log/cassandra
/var/lib/cassandra/*
/var/run/cassandra
/etc/rc.d/init.d/*

