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
%define storm_name storm
%define release_version 4
%define storm_home /usr/lib/storm
%define etc_storm /etc/%{name}
%define config_storm %{etc_storm}/conf
%define storm_user storm
%define storm_group storm
%define storm_user_home /var/lib/%{storm_name}
%global initd_dir %{_sysconfdir}/rc.d/init.d
# prevent binary stripping - not necessary at all.
# Only for prevention.
%global __os_install_post %{nil}

%define storm_version 0.9.2
%define storm_base_version 0.9.2
%define storm_release openbus0.0.1_1

%define kafka_version 0.8.0

Name: %{storm_name}
Version: %{storm_version}
Release: %{storm_release}
Summary: Storm is a distributed realtime computation system.
License: Eclipse Public License 1.0
URL: https://github.com/nathanmarz/storm/
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
Source0: apache-%{storm_name}-%{storm_version}-incubating-src.tar.gz
Source1: cluster.xml
Source2: storm-ui.init
Source3: storm-supervisor.init
Source4: storm
Source5: storm.nofiles.conf
Source6: storm-nimbus.init
Source7: storm-drpc.init
Source8: rpm-build-stage
Source9: install_storm.sh
Source10: storm-logviewer.init
Patch0: storm-kafka-dependencies.patch
Patch1: storm-bin.patch
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
Requires: sh-utils, textutils, /usr/sbin/useradd, /usr/sbin/usermod, /sbin/chkconfig, /sbin/service
Provides: storm
BuildArch: noarch

%description
Storm is a distributed realtime computation system. Similar to how Hadoop
provides a set of general primitives for doing batch processing, Storm provides
a set of general primitives for doing realtime computation. 

It's a distributed real-time computation system for processing fast, 
large streams of data. Storm adds reliable real-time data processing 
capabilities to Apache Hadoop 2.x. Storm in Hadoop helps capture new 
business opportunities with low-latency dashboards, security alerts, 
and operational enhancements integrated with other applications 
running in their Hadoop cluster.

%package nimbus
Summary: The Storm Nimbus node manages the Storm cluster.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}, jdk
BuildArch: noarch
%description nimbus
Nimbus role is the Master Node of Storm, is responsible for distributing code 
around the Storm cluster, assigning tasks to machines, and monitoring for failures. 

%package ui
Summary: The Storm UI exposes metrics for the Storm cluster.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}, jdk
BuildArch: noarch
%description ui
The Storm UI exposes metrics on a web interface on port 8080 to give you
a high level view of the cluster.

%package supervisor
Summary: The Storm Supervisor is a worker process of the Storm cluster.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}, jdk
BuildArch: noarch
%description supervisor
The Supervisor role is the Worker Node, listens for work assigned to its 
machine and starts and stops worker processes as necessary based on what 
Nimbus has assigned to it. Each worker node executes a subset of a topology. 
A topology in Storm runs across many worker nodes on different machines.

%package drpc
Summary: Storm Distributed RPC daemon.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}, jdk
BuildArch: noarch
%description drpc
The DRPC server coordinates receiving an RPC request, sending the request to
the Storm topology, receiving the results from the Storm topology, and sending
the results back to the waiting client. 

%package kafka
Summary: Storm Kafka Connector.
Group: Libraries
Requires: %{name} = %{version}-%{release}, jdk
BuildArch: noarch
%description kafka
Storm-kafka is a connector to support the submit of topologies with
kafka spouts 

%package logviewer
Summary: The Storm LogViewer daemon
Group: System/Daemons
Requires: %{name} = %{version}-%{release}, jdk
BuildArch: noarch
%description logviewer
New feature for debugging and monitoring topologies: The logviewer daemon.

In earlier versions of Storm, viewing worker logs involved determining a 
worker’s location (host/port), typically through Storm UI, then sshing 
to that host and tailing the corresponding worker log file. With the new 
log viewer. You can now easily access a specific worker’s log in a web 
browser by clicking on a worker’s port number right from Storm UI.

The logviewer daemon runs as a separate process on Storm supervisor nodes.


%prep
%setup -n apache-%{storm_name}-%{storm_version}-incubating

%patch0 -p1
%patch1 -p1

%build
bash %{SOURCE8}

%clean
rm -rf %{buildroot}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE9} \
	  --build-dir=$PWD/build \
	  --initd-dir=$RPM_BUILD_ROOT%{initd_dir} \
	  --prefix=$RPM_BUILD_ROOT 
	  
%pre
getent group %{storm_group} >/dev/null || groupadd -r %{storm_group}
getent passwd %{storm_user} >/dev/null || /usr/sbin/useradd --comment "Storm Daemon User" --shell /sbin/nologin -M -r -g %{storm_group} --home %{storm_user_home} %{storm_user}

%files
%defattr(-,%{storm_user},%{storm_group})
%dir %attr(755, %{storm_user},%{storm_group}) %{storm_home}
%dir %attr(755, %{storm_user},%{storm_group}) /etc/storm
%{storm_home}/CHANGELOG.md
%{storm_home}/DISCLAIMER
%{storm_home}/LICENSE
%{storm_home}/NOTICE
%{storm_home}/README.markdown
%{storm_home}/RELEASE
%{storm_home}/conf/*
%{storm_home}/examples/*
%{storm_home}/lib/*
%{storm_home}/logback/*
/etc/storm/*
/etc/default/storm
/var/log/*
/var/lib/storm/
%attr(755,%{storm_user},%{storm_group}) /usr/bin/*
/usr/bin/storm
/etc/sysconfig/storm
/etc/security/limits.d/storm.nofiles.conf
%attr(644,%{storm_user},%{storm_group}) %{storm_user_home}/.bash_profile


%define service_macro() \
%files %1 \
%defattr(-,root,root) \
%{initd_dir}/%{storm_name}-%1 \
%post %1 \
chkconfig --add %{storm_name}-%1 \
\
%preun %1 \
if [ $1 = 0 ]; then \
  service %{storm_name}-%1 stop > /dev/null 2>&1 \
  chkconfig --del %{storm_name}-%1 \
fi

%service_macro nimbus
%service_macro supervisor
%service_macro drpc
%service_macro logviewer

%files ui
%defattr(-,root,root)
%{initd_dir}/%{storm_name}-ui
%{storm_home}/public/*

%post ui
chkconfig --add %{storm_name}-ui

%preun ui
if [ $1 = 0 ]; then
  service %{storm_name}-ui stop > /dev/null 2>&1
  chkconfig --del %{storm_name}-ui
fi


%files kafka
%defattr(-,%{storm_user},%{storm_group})
%{storm_home}/external/storm-kafka/*

%post kafka
ln -s %{storm_home}/external/storm-kafka/storm-kafka-0.9.2-incubating.jar \
	%{storm_home}/lib/storm-kafka-0.9.2-incubating.jar
chown -h %{storm_user}:%{storm_group} %{storm_home}/lib/storm-kafka-0.9.2-incubating.jar

%postun kafka
rm -f %{storm_home}/lib/storm-kafka-0.9.2-incubating.jar
  

%changelog
* Mon Jul 31 2013 Nathan Milford <nathan@milford.io> - 0.9.0-wip16-4
- Removed postun macro. Caused scriptlet error on uninstall.

* Mon Jul 31 2013 Nathan Milford <nathan@milford.io> - 0.9.0-wip16-3
- Bumped RPM release version.
- Merged DRPC init script and package declaration by Vitaliy Fuks <https://github.com/vitaliyf>
- Merged init script additions by Daniel Damiani <https://github.com/ddamiani>

* Mon May 13 2013 Nathan Milford <nathan@milford.io> - 0.9.0-wip16
- Storm 0.9.0-wip16

* Wed Aug 08 2012 Nathan Milford <nathan@milford.io> - 0.8.0
- Storm 0.8.0
