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

%define confdir /etc/%{name}/conf
%define kibana_name kibana
%define kibana_home /usr/lib/kibana
%define kibana_user kibana
%define kibana_group kibana
%define kibana_user_home /var/lib/%{kibana_user}

%define kibana_version 3.1.0
%define kibana_release elk0.0.1_1

Name:           %{kibana_name}
Version:        %{kibana_version}
Release:        %{kibana_release}
Summary:        Kibana is a web tool to visualize and represent elasticsearch data

Group:          Applications/web
License:        ASL 2.0
URL:            http://www.elasticsearch.org/overview/kibana/
Vendor:		The Redoop Team
Packager:	Marcelo Valle <mvalle@redoop.org>
Source0:        %{kibana_name}-%{kibana_version}.tar.gz

#Patch0: 	kibana-scripts-paths.patch
Source1:	install_kibana.sh
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-%(%{__id_u} -n)
BuildArch:      noarch

#AutoReqProv: 	no

%description
Kibana is a web tool to visualize and represent elasticsearch data

%prep
%setup
#%patch0 -p1

%build

%clean
rm -rf %{buildroot}

%install
bash %{SOURCE1} \
          --prefix=$RPM_BUILD_ROOT \
	   --build-dir=$PWD

%pre
# create kibana group
if ! getent group kibana >/dev/null; then
  groupadd -r kibana
fi

# create kibana user
if ! getent passwd kibana >/dev/null; then
  useradd -r -g kibana -d %{kibana_user_home} -s /sbin/nologin -c "Kibana user" -M -r -g %{kibana_group} --home %{kibana_user_home} %{kibana_user}
fi

%post

%preun

%files
%defattr(-,%{kibana_user},%{kibana_group})
%dir %attr(755, %{kibana_user},%{kibana_group}) %{kibana_home}
%dir %attr(755, %{kibana_user},%{kibana_group}) /etc/kibana
%dir %attr(755, %{kibana_user},%{kibana_group}) %{kibana_user_home}
/etc/kibana/conf
%{kibana_home}
%{kibana_user_home}

%changelog
