#!/bin/bash -x
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

set -ex

exit 0
usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to hive/build/dist
     --prefix=PREFIX             path to install into
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'build-dir:' \
  -l 'man-dir:' \
  -l 'bin-dir:' \
  -l 'doc-dir:' \
  -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
while true ; do
    case "$1" in
        --prefix)
        PREFIX=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --man-dir)
        MAN_DIR=$2 ; shift 2
        ;;
        --bin-dir)
        BIN_DIR=$2 ; shift 2
        ;;
        --doc-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --)
        shift ; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

for var in PREFIX BUILD_DIR; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

STORM_HOME=${STORM_HOME:-$PREFIX/usr/lib/storm}
BIN_DIR=${BIN_DIR:-$PREFIX/usr/bin}
STORM_ETC_DIR=${STORM_ETC_DIR:-$PREFIX/etc/storm}

#install -d -m 0755 ${PREFIX}/${DOC_DIR}
#cp ${BUILD_DIR}/*.txt  ${PREFIX}/${DOC_DIR}/
#cp ${BUILD_DIR}/README  ${PREFIX}/${DOC_DIR}/

install -d -m 755 ${STORM_HOME}
install    -m 644 ${BUILD_DIR}/apache-storm-0.9.1-incubating/CHANGELOG.md ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/apache-storm-0.9.1-incubating/DISCLAIMER ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/apache-storm-0.9.1-incubating/LICENSE ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/apache-storm-0.9.1-incubating/NOTICE ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/apache-storm-0.9.1-incubating/RELEASE ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/apache-storm-0.9.1-incubating/README.markdown ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/apache-storm-0.9.1-incubating/lib/*.jar ${STORM_HOME}/

#install -d -m 755 %{buildroot}/%{storm_home}/bin/
#install    -m 755 %{_builddir}/%{storm_name}-%{storm_version}/bin/*.sh         %{buildroot}/%{storm_home}/bin
#install    -m 755 %{_builddir}/%{storm_name}-%{storm_version}/bin/storm        %{buildroot}/%{storm_home}/bin
#
#install -d -m 755 %{buildroot}/%{storm_home}/conf/
#install    -m 644 %{_builddir}/%{storm_name}-%{storm_version}/conf/*           %{buildroot}/%{storm_home}/conf
#
#install -d -m 755 %{buildroot}/%{storm_home}/lib/
#install    -m 644 %{_builddir}/%{storm_name}-%{storm_version}/lib/*            %{buildroot}/%{storm_home}/lib
#
#install -d -m 755 %{buildroot}/%{storm_home}/logback/
#install    -m 644 %_sourcedir/cluster.xml                                      %{buildroot}/%{storm_home}/logback/cluster.xml
#
#install -d -m 755 %{buildroot}/%{storm_home}/logs/
#
#install -d -m 755 %{buildroot}/%{storm_home}/public/
#
#install -d -m 755 %{buildroot}/%{storm_home}/public/css/
#install    -m 644 %{_builddir}/%{storm_name}-%{storm_version}/public/css/*     %{buildroot}/%{storm_home}/public/css/
#
#install -d -m 755 %{buildroot}/%{storm_home}/public/js/
#install    -m 644 %{_builddir}/%{storm_name}-%{storm_version}/public/js/*      %{buildroot}/%{storm_home}/public/js/
#
#cd %{buildroot}/opt/
#ln -s %{storm_name}-%{storm_version} %{storm_name}
#cd -
#
#install -d -m 755 %{buildroot}/etc/
#cd %{buildroot}/etc
#ln -s %{storm_home}/conf %{storm_name}
#cd -
#
#install -d -m 755 %{buildroot}/%{_initrddir}
#install    -m 755 %_sourcedir/storm-nimbus     %{buildroot}/%{_initrddir}/storm-nimbus
#install    -m 755 %_sourcedir/storm-ui         %{buildroot}/%{_initrddir}/storm-ui
#install    -m 755 %_sourcedir/storm-supervisor %{buildroot}/%{_initrddir}/storm-supervisor
#install    -m 755 %_sourcedir/storm-drpc       %{buildroot}/%{_initrddir}/storm-drpc
#install -d -m 755 %{buildroot}/%{_sysconfdir}/sysconfig
#install    -m 644 %_sourcedir/storm            %{buildroot}/%{_sysconfdir}/sysconfig/storm
#install -d -m 755 %{buildroot}/%{_sysconfdir}/security/limits.d/
#install    -m 644 %_sourcedir/storm.nofiles.conf %{buildroot}/%{_sysconfdir}/security/limits.d/storm.nofiles.conf
#
#install -d -m 755 %{buildroot}/usr/bin/
#cd %{buildroot}/usr/bin
#ln -s %{storm_home}/bin/%{storm_name} %{storm_name}
#cd -
#
#install -d -m 755 %{buildroot}/var/log/
#cd %{buildroot}/var/log/
#ln -s %{storm_home}/logs %{storm_name}
#cd -
#
#install -d -m 755 %{buildroot}/var/run/storm/
#
#install -d -m 755 %{buildroot}/%{storm_home}/local/
#echo 'storm.local.dir: "/opt/storm/local/"' >> %{buildroot}/%{storm_home}/conf/storm.yaml.example
#

