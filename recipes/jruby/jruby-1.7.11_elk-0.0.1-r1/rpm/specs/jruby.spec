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

%define jruby_name jruby

%define jruby_version 1.7.11
%define jruby_release elk0.0.1_1

Name:           %{jruby_name}
Version:        %{jruby_version}
Release:        %{jruby_release}
Summary:        Jruby package
 
Group:          Development/Languages 
License:        ASL 2.0
URL:            http://http://jruby.org/
Vendor:		The Redoop Team
Packager:	Marcelo Valle <mvalle@redoop.org>
Source0:        jruby-src-%{jruby_version}.tar.gz
Source1:	rpm-build-stage 
Source2:	install_jruby.sh

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
BuildArch:      x86_64

Provides:	jruby

%description
Jruby package

%package complete
Summary: Jruby complete jar to resolve other tools dependencies
Group: System Environment/Libraries
BuildArch: noarch
%description complete
jruby-complete.jar library to satisfy tool dependences

%prep
%setup

%build
bash %{SOURCE1}

%clean
rm -rf %{buildroot}

%install
bash %{SOURCE2} \
          --prefix=$RPM_BUILD_ROOT \
	  --build-dir=$PWD \
	  --target-dir=$RPM_BUILD_ROOT/usr/share/jruby

%pre

%post

%preun

%files
%defattr(-,root,root)
%dir %attr(755, root,root) /usr/share/jruby
/usr/share/jruby/bin/*
/usr/share/jruby/lib/*
%exclude /usr/share/jruby/bin/*.bat
%exclude /usr/share/jruby/lib/jruby-complete-%{jruby_version}.jar

%files complete
%defattr(-,root,root)
%dir %attr(755, root,root) /usr/share/jruby
/usr/share/jruby/lib/jruby-complete-%{jruby_version}.jar

%changelog
