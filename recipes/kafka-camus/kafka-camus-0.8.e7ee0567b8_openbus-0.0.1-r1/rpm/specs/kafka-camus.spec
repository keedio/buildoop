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

%define lib_camus %{_usr}/lib/camus
%define etc_camus /etc/camus/
%define config_camus %{etc_camus}/conf.dist

%define camus_version 0.8.e7ee0567b8
%define camus_base_version 0.8.e7ee0567b8
%define camus_release openbus0.0.1_1

Name: kafka-camus
Version: %{camus_version}
Release: %{camus_release}
Summary: Linkedin Kafka Camus
URL: https://github.com/linkedin/camus
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0 
# Source from commit 3b08d0962e8247bf0373eb3d46cedbe7ee0567b8
Source0: camus.git.tar.gz
Source1: rpm-build-stage
Source2: install_kafka-camus.sh
Patch0: hadoop-client-pom.patch

%description 
Camus is LinkedIn's Kafka->HDFS pipeline. It is a mapreduce job that does distributed data loads out of Kafka.

%prep
%setup -n camus.git

%patch0 -p1

%build
bash %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE2} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT

%pre
getent group camus >/dev/null || groupadd -r camus
getent passwd camus > /dev/null || useradd -c "Camus" -s /sbin/nologin -g camus -r -d %{lib_camus} camus 2> /dev/null || :


%files 
%defattr(-,root,root,755)
%attr(0755,root,root) %{lib_camus}
%config(noreplace) %{config_camus}
%{config_camus}
%{lib_camus}/bin/*

%changelog
* Sun Mar 30 2014 Javi Roman <javiroman@redoop.org> 
- First package version released.


