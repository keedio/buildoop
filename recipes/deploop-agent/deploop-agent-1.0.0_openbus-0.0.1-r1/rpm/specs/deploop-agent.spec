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

global initd_dir %{_sysconfdir}/rc.d/init.d
# prevent binary stripping - not necessary at all.
# Only for prevention.
%global __os_install_post %{nil}

%define deploop_agent_name mcollective-deploop-agent
%define deploop_agent_version 1.0.0
%define deploop_agent_base_version 1.0.0
%define deploop_agent_release openbus0.0.1_1

Name: %{deploop_agent_name}
Version: %{deploop_agent_version}
Release: %{deploop_agent_release}
Summary: Storm is a distributed realtime computation system.
License: ASL 2.0
URL: https://github.com/deploop/mcollective-deploop-agent
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
Source0: mcollective-deploop-agent.git.tar.gz
Source1: rpm-build-stage
Source2: install_deploop-agent.sh
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
Group: System Tools
Requires: mcollective-common >= 2.2.1
Requires: mcollective-deploop-common >= 1.0.0
BuildArch: noarch

%description
Deploop MCollective Agent.

%package mcollective-deploop-common
Summary: The Storm Nimbus node manages the Storm cluster.
Group: System/Daemons
Requires: %{name} = %{version}-%{release}, jdk
BuildArch: noarch
%description nimbus
Nimbus role is the Master Node of Storm, is responsible for distributing code 
around the Storm cluster, assigning tasks to machines, and monitoring for failures. 

%prep
%setup 

%build
bash %{SOURCE1}

%clean
rm -rf %{buildroot}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE9} \
          --build-dir=build \
	  --build-dir=$PWD/build \
	  --initd-dir=$RPM_BUILD_ROOT%{initd_dir} \
          --prefix=$RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/libexec/mcollective/mcollective/agent/deploop.rb

%files mcollective-deploop-common
%defattr(-,root,root,-)
/usr/libexec/mcollective/mcollective/agent/deploop.ddl

%changelog
* Thu Feb 21 2013 Javi Roman <javiroman@redoop.org> - 1.0.0-1
- Built Package mcollective-deploop-agent

