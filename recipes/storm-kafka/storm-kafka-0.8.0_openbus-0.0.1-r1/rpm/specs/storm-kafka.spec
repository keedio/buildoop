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

%define lib_storm /usr/lib/storm/lib

%define storm_kafka_version 0.8.0
%define storm_kafka_base_version 0.8.0
%define storm_kafka_release openbus0.0.1_1

# Disable post hooks (brp-repack-jars, etc) that just take forever and sometimes cause issues
%define __os_install_post \
    %{!?__debug_package:/usr/lib/rpm/brp-strip %{__strip}} \
%{nil}
%define __jar_repack %{nil}
%define __prelink_undo_cmd %{nil}

# Disable debuginfo package, since we never need to gdb
# our own .sos anyway
%define debug_package %{nil}

Name: storm-kafka
Version: %{storm_kafka_version}
Release: %{storm_kafka_release}
Summary: "Storm to Kafka consummer spout"
URL: https://github.com/wso2/siddhi
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{storm_kafka_version}-%{storm_kafka_release}-XXXXXX)
License: ASL 2.0 
# Source from commit 09ae97303d3faa0b4b837a3bbe18b996854d2733
Source0: storm-kafka.git.tar.gz
Source1: rpm-build-stage
Source2: install_storm-kafka.sh

%description 
Storm spout kafka comsummer.

%prep
%setup -n storm-kafka.git

%build
bash %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE2} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT

%files 
%defattr(-,root,root,755)
%attr(0755,root,root) %{lib_storm}
%{lib_storm}

%changelog
* Sun Mar 30 2014 Javi Roman <javiroman@redoop.org> 
- First package version released.


