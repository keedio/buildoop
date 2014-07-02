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
  -l 'initd-dir:' \
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
	--initd-dir)
        INITD_DIR=$2 ; shift 2
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

install -d -m 755 ${STORM_HOME}
install    -m 644 ${BUILD_DIR}/CHANGELOG.md ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/DISCLAIMER ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/LICENSE ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/NOTICE ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/RELEASE ${STORM_HOME}/
install    -m 644 ${BUILD_DIR}/README.markdown ${STORM_HOME}/

install -d -m 755 ${BIN_DIR}/
install    -m 755 ${BUILD_DIR}/bin/storm ${PREFIX}/usr/bin/storm

install -d -m 755 ${STORM_HOME}/conf/
install    -m 644 ${BUILD_DIR}/conf/* ${STORM_HOME}/conf

install -d -m 755 ${STORM_HOME}/lib/
install    -m 644 ${BUILD_DIR}/lib/* ${STORM_HOME}/lib/

install -d -m 755 ${STORM_HOME}/logback/
install    -m 644 $RPM_SOURCE_DIR/cluster.xml ${STORM_HOME}/logback/cluster.xml

install -d -m 755 ${STORM_HOME}/public/css/
install    -m 644 ${BUILD_DIR}/public/css/* ${STORM_HOME}/public/css/

install -d -m 755 ${STORM_HOME}/public/js/
install    -m 644 ${BUILD_DIR}/public/js/* ${STORM_HOME}/public/js/

install -d -m 755 ${STORM_ETC_DIR}
install    -m 644 ${BUILD_DIR}/conf/* ${STORM_ETC_DIR}/

echo ${INITD_DIR}
install -d -m 755 ${INITD_DIR}

install    -m 755 $RPM_SOURCE_DIR/storm-nimbus.init     ${INITD_DIR}/storm-nimbus
install    -m 755 $RPM_SOURCE_DIR/storm-ui.init         ${INITD_DIR}/storm-ui
install    -m 755 $RPM_SOURCE_DIR/storm-supervisor.init ${INITD_DIR}/storm-supervisor
install    -m 755 $RPM_SOURCE_DIR/storm-drpc.init       ${INITD_DIR}/storm-drpc

install -d -m 755 ${PREFIX}/etc/sysconfig
install    -m 644 $RPM_SOURCE_DIR/storm ${PREFIX}/etc/sysconfig/storm

install -d -m 755 ${PREFIX}/etc/default
install    -m 644 $RPM_SOURCE_DIR/storm.default ${PREFIX}/etc/default/storm

install -d -m 755 ${PREFIX}/etc/security/limits.d/
install    -m 644 $RPM_SOURCE_DIR/storm.nofiles.conf ${PREFIX}/etc/security/limits.d/storm.nofiles.conf

install -d -m 755 ${PREFIX}/var/log/storm
install -d -m 755 ${PREFIX}/var/run/storm/

#install -d -m 755 %{buildroot}/usr/bin/
#cd %{buildroot}/usr/bin
#ln -s %{storm_home}/bin/%{storm_name} %{storm_name}
#cd -
#install -d -m 755 %{buildroot}/%{storm_home}/local/
#echo 'storm.local.dir: "/opt/storm/local/"' >> %{buildroot}/%{storm_home}/conf/storm.yaml.example


