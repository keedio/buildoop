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

%define lib_storm_hbase %{_usr}/lib/storm/lib

%define storm_hbase_version 0.9.1.7f79e191ef
%define storm_hbase_base_version 0.9.1.7f79e191ef
%define storm_hbase_release openbus0.0.1_1
%define storm_user storm
%define storm_group storm

Name: storm-hbase
Version: %{storm_hbase_version}
Release: %{storm_hbase_release}
Summary: Hortonworks Storm to HBase connector
URL: https://github.com/ptgoetz/storm-hbase
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{storm_hbase_version}-%{storm_hbase_release}-XXXXXX)
License: ASL 2.0 
# Source from commit a2d48e1a62c6249c8737fc80ff70587f79e191ef
Source0: storm-hbase.git.tar.gz
Source1: rpm-build-stage
Source2: install_storm-hbase.sh

%description 
Storm to HBase connector fork from P. Taylor Goetz (Hortonworks)

%prep
%setup -n storm-hbase.git

%build
bash %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE2} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT

%files
%defattr(-,%{storm_user},%{storm_group})
%{lib_storm_hbase}

%changelog
* Sun Mar 30 2014 Javi Roman <javiroman@redoop.org> 
- First package version released.


