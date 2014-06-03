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
%define debug_package %{nil}
%define base_install_dir %{_javadir}{%name}

%define elasticsearch_version 1.2.0
%define elasticsearch_base_version 1.2.0
%define elasticsearch_release openbus0.0.1_1

Name: elasticsearch
Version: %{elasticsearch_version}
Release: %{elasticsearch_release}
Summary: A distributed, highly available, RESTful search engine
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: System Environment/Daemons
License: ASL 2.0
URL: http://www.elasticsearch.com
Source0: elasticsearch.git.tar.gz
Source1: rpm-build-stage
Source2: install_elasticsearch.sh
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires(post): chkconfig initscripts
Requires(pre):  chkconfig initscripts
Requires(pre):  shadow-utils

%description
A distributed, highly available, RESTful search engine

%prep
%setup -n  elasticsearch.git

%build
bash %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE2} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT
%pre
# create elasticsearch group
if ! getent group elasticsearch >/dev/null; then
        groupadd -r elasticsearch
fi

# create elasticsearch user
if ! getent passwd elasticsearch >/dev/null; then
        useradd -r -g elasticsearch -d %{_javadir}/%{name} \
            -s /sbin/nologin -c "You know, for search" elasticsearch
fi

%post
/sbin/chkconfig --add elasticsearch

%preun
if [ $1 -eq 0 ]; then
  /sbin/service elasticsearch stop >/dev/null 2>&1
  /sbin/chkconfig --del elasticsearch
fi

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%{_initddir}/elasticsearch
%config(noreplace) %{_sysconfdir}/sysconfig/elasticsearch
%{_sysconfdir}/logrotate.d/elasticsearch
%dir /usr/share/elasticsearch
/usr/share/elasticsearch/bin/*
/usr/share/elasticsearch/lib/*
%dir /usr/share/elasticsearch/plugins
%config(noreplace) %{_sysconfdir}/elasticsearch
%doc LICENSE.txt  NOTICE.txt  README.textile
%defattr(-,elasticsearch,elasticsearch,-)
%dir %{_localstatedir}/lib/elasticsearch
%{_localstatedir}/run/elasticsearch
%dir %{_localstatedir}/log/elasticsearch

%changelog
* Tue Jun 03 2014 Javi Roman <javiroman@redoop.org>
- Rework for buildoop builder system.

* Fri Aug 09 2013 Matt Dainty <matt@bodgit-n-scarper.com> - 0.20.6-2
- Add ulimit call to allow unlimited memory locking

* Fri Aug 09 2013 Matt Dainty <matt@bodgit-n-scarper.com> - 0.20.6
- Updated to version 0.20.6

* Wed May 08 2013 Matt Dainty <matt@bodgit-n-scarper.com> - 0.20.5
- Updated to version 0.20.5

* Sat Jan 19 2013 Richard Pijnenbrug <richard@ispavailability.com> - 0.20.2
- Updated to version 0.20.2
- Modified source0 path for elasticsearch

* Sat Dec 08 2012 Richard Pijnenburg <richard@ispavailability.com> - 0.20.1
- Forked data from https://github.com/tavisto
- Updated to newest version
