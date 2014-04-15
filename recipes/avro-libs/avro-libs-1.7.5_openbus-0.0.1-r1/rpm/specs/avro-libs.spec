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
%{!?python_sitearch: %define python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib(1)")}

%define lib_avro /usr/lib/avro
# disable repacking jars
%define __os_install_post %{nil}

%define avro_version 1.7.5
%define avro_base_version 1.7.5
%define avro_release openbus0.0.1_1

Name: avro-libs
Version: %{avro_version}
Release: %{avro_release}
Summary: A data serialization system
URL: http://avro.apache.org
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/avro-%{version}-%{release}-XXXXXX)
License: ASL 2.0 
Source0: avro-src-%{avro_version}.tar.gz
Source1: rpm-build-stage
Source2: install_avro-libs.sh
Requires: python
BuildRequires: python-devel

%description
 Avro provides rich data structures, a compact & fast binary data format, a
 container file to store persistent data, remote procedure calls (RPC), and a
 simple integration with dynamic languages. Code generation is not required to
 read or write data files nor to use or implement RPC protocols. Code
 generation as an optional optimization, only worth implementing for statically
 typed languages.

%package -n avro-tools
Summary: Command-line utilities to work with Avro files
Group: Development/Tools
Requires: %{name} = %{version}-%{release}

%description -n avro-tools
 Command-line utilities to work with Avro files

%prep
%setup -n avro-src-%{avro_version}

%build
env FULL_VERSION=%{avro_version} bash $RPM_SOURCE_DIR/rpm-build-stage

# Python bindings
(cd lang/py; 
	python setup.py build)

%install
%__rm -rf $RPM_BUILD_ROOT
env FULL_VERSION=%{avro_version} bash $RPM_SOURCE_DIR/install_avro-libs.sh \
          --build-dir=./ \
          --prefix=$RPM_BUILD_ROOT

# Python bindings install
(cd lang/py; sed -i -r "s/@AVRO_VERSION@/%{avro_version}/" setup.py;
	%{__python} setup.py install -O1 \
			--skip-build \
			--root %{buildroot} \
			--install-lib=${buildroot}%{python_sitearch})

#######################
#### FILES SECTION ####
#######################
%files
%defattr(-,root,root,755)
/usr/lib/avro
/usr/bin/avro
%defattr(-,root,root,-)
%{python_sitearch}/*

%files -n avro-tools
/usr/bin/avro-tools

