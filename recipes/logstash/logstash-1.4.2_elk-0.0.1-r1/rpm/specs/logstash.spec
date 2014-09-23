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

%define bindir /usr/bin
%define confdir /etc/%{name}/conf
%define logstash_name logstash
%define logstash_home /usr/lib/logstash
%define etc_logstash /etc/%{name}
%define config_logstash %{etc_logstash}/conf
%define logstash_user logstash
%define logstash_group logstash
%define logstash_user_home /var/lib/%{logstash_name}
%define logstash_user logstash
%define logstash_group logstash
%global initd_dir %{_sysconfdir}/rc.d/init.d
# prevent binary stripping - not necessary at all.
# Only for prevention.
%global __os_install_post %{nil}

%define logstash_version 1.4.2
%define logstash_release elk0.0.1_1

Name:           %{logstash_name}
Version:        %{logstash_version}
Release:        %{logstash_release}
Summary:        Logstash is a tool for managing events and logs

Group:          System Environment/Daemons
License:        ASL 2.0
URL:            http://logstash.net
Vendor:		The Redoop Team
Packager:	Marcelo Valle <mvalle@redoop.org>
Source0:        %{logstash_name}-%{logstash_version}.tar.gz

Patch0: 	logstash-scripts-paths.patch
Patch1: 	elasticsearch_path.patch
Source1:	install_logstash.sh
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
BuildArch:      noarch

Requires: sh-utils, textutils, /usr/sbin/useradd, /usr/sbin/usermod, /sbin/chkconfig, /sbin/service, jruby-complete, elasticsearch
Provides: logstash
AutoReqProv: 	no

%description
Logstash is a tool for managing events and logs.

%package web
Summary: Logstash web is a Kibana web interface to see logstash activity
Group: System Environment/Daemons
Requires: %{name} = %{version}-%{release}, jdk, kibana
BuildArch: noarch
%description web
Logstash web is a Kibana web interface to see logstash activity

%prep
%setup
%patch0 -p1
%patch1 -p1

%build

%clean
rm -rf %{buildroot}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE1} \
          --build-dir=$PWD \
          --initd-dir=$RPM_BUILD_ROOT%{initd_dir} \
          --prefix=$RPM_BUILD_ROOT


%pre
# create logstash group
if ! getent group logstash >/dev/null; then
  groupadd -r logstash
fi

# create logstash user
if ! getent passwd logstash >/dev/null; then
  useradd -r -g logstash -d %{logstash_user_home} -s /sbin/nologin -c "Logstash service user" -M -r -g %{logstash_group} --home %{logstash_user_home} %{logstash_user}
fi

%post
/sbin/chkconfig --add logstash

%preun
if [ $1 -eq 0 ]; then
  /sbin/service logstash stop >/dev/null 2>&1
  /sbin/chkconfig --del logstash
fi

%post web
/sbin/chkconfig --add logstash-web

%preun web
if [ $1 -eq 0 ]; then
  /sbin/service logstash-web stop >/dev/null 2>&1
  /sbin/chkconfig --del logstash-web
fi

%files
%defattr(-,%{logstash_user},%{logstash_group})
%dir %attr(755, %{logstash_user},%{logstash_group}) %{logstash_home}
%dir %attr(755, %{logstash_user},%{logstash_group}) /etc/logstash
/etc/logstash/conf
%{logstash_home}
%exclude %{logstash_home}/bin/logstash-web
%exclude %{logstash_home}/bin/logstash.bat
%{logstash_user_home}
%dir %attr(755, root,root) /etc/rc.d/init.d/logstash
/var/log/logstash
/var/lib/logstash
/var/run/logstash

%files web
%{logstash_home}/bin/logstash-web
/etc/rc.d/init.d/logstash-web
/var/run/logstash-web
/etc/logstash-web/conf

%changelog
* Mon Feb 06 2014 lars.francke@gmail.com 1.3.3-2
- Start script now allows multiple server types (web & agent) at the same time (Thanks to Brad Quellhorst)
- Logging can be configured via LOGSTASH_LOGLEVEL flag in /etc/sysconfig/logstash
- Default log level changed from INFO TO WARN

* Mon Jan 20 2014 dmaher@mozilla.com 1.3.3-1
- Update logstash to version 1.3.3

* Fri Jan 10 2014 lars.francke@gmail.com 1.3.2-1
- Update logstash to version 1.3.2 (Thanks to Brad Quellhorst)

* Thu Dec 12 2013 lars.francke@gmail.com 1.3.1-1
- Update logstash to version 1.3.1
- Fixed Java version to 1.7 as 1.5 does not work

* Wed Dec 11 2013 lars.francke@gmail.com 1.2.2-2
- Fixed reference to removed jre7 package
- Fixed rpmlint warning about empty dummy.rb file
- Fixes stderr output not being captured in logfile
- Fixed home directory location (now in /var/lib/logstash)

* Mon Oct 28 2013 lars.francke@gmail.com 1.2.2-1
- Update logstash version to 1.2.2
- Change default log level from WARN to INFO

* Wed Jun 12 2013 lars.francke@gmail.com 1.1.13-1
- Update logstash version to 1.1.13

* Thu May 09 2013 dmaher@mozilla.com 1.1.12-1
- Update logstash version to 1.1.12

* Thu Apr 25 2013 dmaher@mozilla.com 1.1.10-1
- Use flatjar instead of monolithic
- Update logstash version to 1.1.10

* Tue Jan 22 2013 dmaher@mozilla.com 1.1.9-1
- Add chkconfig block to init
- Update logstash version to 1.1.9

* Tue Jan 11 2013 lars.francke@gmail.com 1.1.5-1
- Initial version

