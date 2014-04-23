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
%define lib_avro_schema_repo %{_usr}/lib/avro/%{name} 
%define avro_schema_repo_version 1.7.4
%define avro_schema_repo_base_version 1.7.4
%define avro_schema_repo_release openbus0.0.1_1

Name: avro-schema-repo
Version: %{avro_schema_repo_version}
Release: %{avro_schema_repo_release}
Summary: Apache Tomcat
URL: http://tomcat.apache.org/
Vendor: The Redoop Team
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0 
Source0: avro-schema-repo.git.tar.gz
Source1: rpm-build-stage
Source2: install_avro-schema-repo.sh

%description 
RESTful service for holding schemas.

The overhead of storing the schema with each Avro record is too high unless 
the individual records are very large. This package bundle a server that
basically is a simple REST service that stores and retrieves schemas.

%prep
%setup -n avro-schema-repo.git

%build
bash %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE2} \
          --build-dir=bundle \
          --prefix=$RPM_BUILD_ROOT

%files 
%defattr(644,root,root,755)
%dir %{lib_avro_schema_repo}
%{lib_avro_schema_repo}/*.jar
%{lib_avro_schema_repo}/config.*

%changelog

