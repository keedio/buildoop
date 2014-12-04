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
%define lib_pig /usr/lib/pig
%define conf_pig %{_sysconfdir}/%{name}/conf

%define pig_version 0.14.0
%define pig_base_version 0.14.0
%define pig_release openbus1.0.0_1
%define pig_home /usr/lib/pig

Name: pig
Version: %{pig_version}
Release: %{pig_release}
Summary: Apache Pig is a platform for analyzing large data sets that consists of a high-level language
License: APL2
URL: http://pig.apache.org/
Vendor: The Redoop Team
Packager: Marcelo Valle <mvalle@redoop.org>
Group: Development/Libraries
Source0: %{name}-%{pig_version}-src.tar.gz
Source1: rpm-build-stage
Source2: install_%{name}.sh
Patch0: pig-%{pig_version}.patch
BuildRequires: ant
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
Requires: hadoop-client
Provides: pig
Buildarch: noarch

%description 
Apache Pig is a platform for analyzing large data sets that consists of a high-level language

%prep
%setup -n pig-%{pig_version}-src

%patch0 -p1

%build
bash %{SOURCE1}

%clean
rm -fr %{buildroot}


%install
bash %{SOURCE2} \
          --build-dir=$PWD \
          --conf-dir=etc/pig/conf \
          --prefix=$RPM_BUILD_ROOT \
	  --lib-dir=usr/lib/pig \
          --bin-dir=usr/bin

%pre
getent group pig >/dev/null || groupadd -r pig
getent passwd pig > /dev/null || useradd -c "Pig" -s /sbin/nologin \
	-g pig -r -d /var/lib/pig pig 2> /dev/null || :

# Files for main package
%files 
%defattr(0755,pig,pig)
%{pig_home}/*
/usr/bin/*
/etc/pig/*
