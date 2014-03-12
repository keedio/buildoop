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
%define man_dir %{_mandir}

%define jsvc_version 1.0.10
%define jsvc_base_version 1.0.10
%define jsvc_release openbus0.0.1_1

%if  %{?suse_version:1}0
%define bin_jsvc /usr/lib/jsvcdaemon
%define doc_jsvc %{_docdir}/%{name}
%else
%define bin_jsvc /usr/lib/jsvcdaemon
%define doc_jsvc %{_docdir}/%{name}-%{jsvc_version}
%endif

Name: jsvcdaemon
Version: %{jsvc_version}
Release: %{jsvc_release}
Summary: Application to launch java daemon
URL: http://commons.apache.org/daemon/
Vendor: Produban - Santander Group
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
Buildroot: %{_topdir}/INSTALL/%{name}-%{version}
License: ASL 2.0
Source0: commons-daemon-%{jsvc_base_version}-native-src.tar.gz
Source1: rpm-build-stage
Source2: install_jsvc.sh
BuildRequires: autoconf, automake, gcc

%description 
jsvc executes classfile that implements a Daemon interface.

%prep
%setup -n commons-daemon-%{jsvc_base_version}-native-src

%clean
rm -rf $RPM_BUILD_ROOT

%build
bash %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
sh %{SOURCE2} \
          --build-dir=.         \
          --bin-dir=%{bin_jsvc} \
          --doc-dir=%{doc_jsvc} \
          --man-dir=%{man_dir}  \
          --prefix=$RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{bin_jsvc}
%doc %{doc_jsvc}


%changelog

