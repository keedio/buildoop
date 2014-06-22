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

%define lib_siddhi /usr/lib/siddhi

%define siddhi_version 3.0.0
%define siddhi_base_version 3.0.0
%define siddhi_release openbus0.0.1_1

# Disable post hooks (brp-repack-jars, etc) that just take forever and sometimes cause issues
%define __os_install_post \
    %{!?__debug_package:/usr/lib/rpm/brp-strip %{__strip}} \
%{nil}
%define __jar_repack %{nil}
%define __prelink_undo_cmd %{nil}

# Disable debuginfo package, since we never need to gdb
# our own .sos anyway
%define debug_package %{nil}

Name: siddhi
Version: %{siddhi_version}
Release: %{siddhi_release}
Summary: "WSO2 Siddhi Complex Event Processor"
URL: https://github.com/wso2/siddhi
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{siddhi_version}-%{siddhi_release}-XXXXXX)
License: ASL 2.0 
# Source from commit d853a7a5d033db2d22744345cef8c2c598970dfa
Source0: siddhi.git.tar.gz
Source1: rpm-build-stage
Source2: install_siddhi.sh

%description 
WSO2 Siddhi Complex Event Processor.

%prep
%setup -n siddhi.git

%build
bash %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE2} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT

%files 
%defattr(-,root,root,755)
%attr(0755,root,root) %{lib_siddhi}
%{lib_siddhi}

%changelog
* Sun Mar 30 2014 Javi Roman <javiroman@redoop.org> 
- First package version released.


