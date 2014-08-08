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

%define lib_storm_elasticsearch %{_usr}/lib/storm

%define storm_elasticsearch_version 0.1.3
%define storm_elasticsearch_base_version 0.1.3
%define storm_elasticsearch_release openbus0.0.1_1
%define storm_user storm
%define storm_group storm

%define storm_home /usr/lib/storm

Name: storm-elasticsearch
Version: %{storm_elasticsearch_version}
Release: %{storm_elasticsearch_release}
Summary: Storm to ElasticSearch connector
URL: https://github.com/mvalle/storm-elasticsearch
Vendor: The Redoop Team
Packager: Marcelo Valle <mvalle@redoop.org>
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{storm_elasticsearch_version}-%{storm_elasticsearch_release}-XXXXXX)
License: ASL 2.0
# Source from commit 3aa7020d84dc158537eb9c95fb26697d686ebbde
Source0: storm-elasticsearch.git.tar.gz
Source1: rpm-build-stage
Source2: install_storm-elasticsearch.sh

%description
Storm to ElasticSearch connector fork from M. Valle Avila

%prep
%setup -n storm-elasticsearch.git

%build
bash %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
bash %{SOURCE2} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT

%files
%defattr(-,%{storm_user},%{storm_group})
%{lib_storm_elasticsearch}

%post
ln -s %{storm_home}/external/storm-elasticsearch/storm-elasticsearch-0.1.3.jar \
        %{storm_home}/lib/storm-elasticsearch-0.1.3.jar
chown -h %{storm_user}:%{storm_group} %{storm_home}/lib/storm-elasticsearch-0.1.3.jar

%changelog
* Sun Aug 07 2014 Marcelo Valle <mvalle@redoop.org>
- First package version released.

