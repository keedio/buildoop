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

%define zeromq_version 2.1.7
%define zeromq_base_version 2.1.7
%define zeromq_release openbus0.0.1_1

Name: zeromq
Version: %{zeromq_version} 
Release: %{zeromq_release}
Summary:        Lightweight messaging kernel
URL: http://www.zeromq.org/
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
License: LGPL-3.0+
Group: Productivity/Networking/Web/Servers
Source0: %{name}-%{zeromq_version}.tar.gz
Source1: rpm-build-stage
Source2: install_zeromq.sh
BuildRoot: %{_tmppath}/%{name}-%{zeromq_version}-build
%ifarch %ix86 x86_64
%if 0%{?suse_version} >= 1100
%define with_pgm 1
%endif
%endif
BuildRequires:  gcc-c++
%if 0%{?suse_version} && 0%{?suse_version} < 1100
BuildRequires:  e2fsprogs-devel
%else
%if 0%{?rhel} || 0%{?centos_version}
BuildRequires:  e2fsprogs-devel
BuildRequires:  libuuid-devel
%else
%if 0%{?mdkversion} && 0%{?mdkversion} < 201000
BuildRequires:  e2fsprogs-devel
%else
BuildRequires:  libuuid-devel
%endif
%endif
%endif
%if 0%{?with_pgm}
BuildRequires:  pkgconfig
BuildRequires:  python
%if 0%{?suse_version} && 0%{?suse_version} < 1130
BuildRequires:  glib2 >= 2.8
%else
BuildRequires:  pkgconfig(glib-2.0) >= 2.8
%endif
%endif

%description
The 0MQ lightweight messaging kernel is a library which extends the
standard socket interfaces with features traditionally provided by
specialised messaging middleware products. 0MQ sockets provide an
abstraction of asynchronous message queues, multiple messaging patterns,
message filtering (subscriptions), seamless access to multiple transport
protocols and more.

%define lib_name libzmq1
%package -n %{lib_name}
Summary: Shared Library for ZeroMQ
Group: Productivity/Networking/Web/Servers

%description -n %{lib_name}
The 0MQ lightweight messaging kernel is a library which extends the
standard socket interfaces with features traditionally provided by
specialised messaging middleware products. 0MQ sockets provide an
abstraction of asynchronous message queues, multiple messaging patterns,
message filtering (subscriptions), seamless access to multiple transport
protocols and more.

This package holds the shared library part of the ZeroMQ package.

%package devel
Summary: Development files for ZeroMQ
Group: Development/Languages/C and C++
Requires: %{lib_name} = %{zeromq_version}
Provides: libzmq-devel = %{zeromq_version}

%description devel
The 0MQ lightweight messaging kernel is a library which extends the
standard socket interfaces with features traditionally provided by
specialised messaging middleware products. 0MQ sockets provide an
abstraction of asynchronous message queues, multiple messaging patterns,
message filtering (subscriptions), seamless access to multiple transport
protocols and more.

This package holds the development files for ZeroMQ.

%prep
%setup -q

%build
bash %{SOURCE1}

%install
%makeinstall
find %{buildroot} -name \*.la -print0 | xargs -r0 rm -v

%clean
rm -rf %{buildroot}

%post   -n %{lib_name} -p /sbin/ldconfig
%postun -n %{lib_name} -p /sbin/ldconfig

%files -n %{lib_name}
%defattr(-,root,root,-)
%doc AUTHORS ChangeLog COPYING COPYING.LESSER NEWS README
%{_libdir}/libzmq.so.*

%files devel
%defattr(-,root,root,-)
%{_includedir}/zmq*
%{_libdir}/libzmq.so
%{_libdir}/pkgconfig/libzmq.pc
%{_mandir}/man3/zmq*.3*
%{_mandir}/man7/zmq*.7*

%changelog
* Wed Sep 28 2011 saschpe@gmx.de
- Fixed license to LGPL-3.0+ (SPDX style)
* Wed Aug 24 2011 mrueckert@suse.de
- make sure the compiler commandlines are shown (V=1)
- make it build on sle11 again. we dont have pkg-config provides
  there
* Fri Aug 19 2011 saschpe@suse.de
- Use %%makeinstall marcro instead of %%make_install to fix build
  on Mandriva and Fedora
* Fri Aug 19 2011 saschpe@suse.de
- Add libuuid-devel to RedHat BuildRequires to fix build
* Fri Aug 19 2011 saschpe@suse.de
- Update to version 2.1.7:
  * Fixed issue 188, assert when closing socket that had unread multipart
    data still on it (affected PULL, SUB, ROUTER, and DEALER sockets).
  * Fixed issue 191, message atomicity issue with PUB sockets (an old issue).
  * Fixed issue 199 (affected ROUTER/XREP sockets, an old issue).
  * Fixed issue 206, assertion failure in zmq.cpp:223, affected all sockets
    (bug was introduced in 2.1.6 as part of message validity checking).
  * Fixed issue 211, REP socket asserted if sent malformed envelope (old issue
    due to abuse of assertions for error checking).
  * Fixed issue 212, reconnect failing after resume from sleep on Windows
    (due to not handling WSAENETDOWN).
  * Properly handle WSAENETUNREACH on Windows (e.g. if client connects
    before server binds).
  * Fixed memory leak with threads on Windows.
- Changes from previous releases:
  * See https://raw.github.com/zeromq/zeromq2-1/master/NEWS
- Run spec-cleaner, added proper spec license header, shorter file lists
- Split out documentation package
* Wed Dec  1 2010 mrueckert@suse.de
- update to version 2.0.10
  * Upgrade OpenPGM to 2.1.28~dfsg (Martin Lucina)
  * Added a ZMQ_VERSION macro to zmq.h for compile-time API version
    detection (Martin Sustrik, Gonzalo Diethelm, Martin Lucina)
  * Fix memory leak under Windows (Taras Shpot)
  * Makefile.am: Add missing files to distribution, improve
    maintainer-clean (Martin Lucina)
  * Add support for RHEL6 in the spec file (Sebastian Otaegui)
  * configure.in: Do not patch libtool rpath handling (Martin Lucina)
  * Fixing the Red Hat packaging (Martin Sustrik)
  * zmq_msg_move called on uninitialised message in xrep_t::xrecv
  - - fixed (Max Wolf)
  * crash when closing an ypipe -- fixed (Dhammika Pathirana)
  * REQ socket can die when reply is delivered on wrong unerlying
    connection -- fixed (Martin Sustrik)
  * if TSC jumps backwards (in case of migration to a
    different CPU core) latency peak may occur -- fixed
    (Martin Sustrik)
  * values of RATE, RECOVERY_IVL and SWAP options are checked for
    negative values (Martin Sustrik)
- added provides for libzmq-devel
* Mon Sep  6 2010 mrueckert@suse.de
- initial package
