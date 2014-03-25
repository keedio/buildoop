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

%define jzmqstorm_version 2.1.0.dd3327d620
%define jzmqstorm_base_version 2.1.0.dd3327d620
%define jzmqstorm_release openbus0.0.1_1

Name: jzmqstorm
Version: 2.1.0.dd3327d620
Release: storm1%{?dist}
Summary: The Java ZeroMQ bindings
Group: Applications/Internet
License: LGPLv3+
URL: http://www.zeromq.org/
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Source0: master.zip
Source1: rpm-build-stage
Source2: install_jzmqstorm.sh
Prefix: %{_prefix}
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: gcc, make, gcc-c++, libstdc++-devel, libtool, zeromq-devel
Requires: libstdc++, zeromq

%description
The 0MQ lightweight messaging kernel is a library which extends the
standard socket interfaces with features traditionally provided by
specialised messaging middleware products. 0MQ sockets provide an
abstraction of asynchronous message queues, multiple messaging
patterns, message filtering (subscriptions), seamless access to
multiple transport protocols and more.

This package contains the Java Bindings for ZeroMQ.

%package devel
Summary:  Development files and static library for the Java Bindings for the ZeroMQ library.
Group:    Development/Libraries
Requires: %{name} = %{version}-%{release}, pkgconfig, zeromq

%description devel
The 0MQ lightweight messaging kernel is a library which extends the
standard socket interfaces with features traditionally provided by
specialised messaging middleware products. 0MQ sockets provide an
abstraction of asynchronous message queues, multiple messaging
patterns, message filtering (subscriptions), seamless access to
multiple transport protocols and more.

This package contains Java Bindings for ZeroMQ related development libraries and header files.

%prep
%setup -n jzmq-master

%build
bash %{SOURCE1}

%{__make}

%install
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}

# Install the package to build area
%makeinstall

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%clean
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)

# docs in the main package
%doc AUTHORS ChangeLog COPYING COPYING.LESSER NEWS README

# libraries
%{_libdir}/libjzmq.so*
/usr/share/java/zmq.jar

%files devel
%defattr(-,root,root,-)
%{_libdir}/libjzmq.la
%{_libdir}/libjzmq.a

%changelog
* Mon Jun 11 2012 Nathan Milford <nathan@milford.io>
- Tweaked to work with Nathan Marz's github fork for use with Storm.
* Thu Dec 09 2010 Alois Belaska <alois.belaska@gmail.com>
- version of package changed to 2.1.0
* Tue Sep 21 2010 Stefan Majer <stefan.majer@gmail.com> 
- Initial packaging
