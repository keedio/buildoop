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

# Check Usage
usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --prefix=PREFIX             path to install into
  "
  exit 1
}

#check opts
OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'build-dir:' \
  -l 'man-dir:' \
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

LOGSTASH_HOME=${LOGSTASH_HOME:-$PREFIX/usr/lib/logstash}
LOGSTASH_ETC_DIR=${LOGSTASH_ETC_DIR:-$PREFIX/etc/logstash}
LOGSTASH_WEB_ETC_DIR=${LOGSTASH_WEB_ETC_DIR:-$PREFIX/etc/logstash-web}


install -d -m 755 ${LOGSTASH_HOME}
install    -m 644 ${BUILD_DIR}/LICENSE ${LOGSTASH_HOME}
install    -m 644 ${BUILD_DIR}/README.md ${LOGSTASH_HOME}
install    -m 755 $RPM_SOURCE_DIR/readmeExampleConf.txt ${LOGSTASH_HOME}

install -d -m 755 ${LOGSTASH_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/* ${LOGSTASH_HOME}/bin

install -d -m 755 ${LOGSTASH_HOME}/lib
cp -Rpd ${BUILD_DIR}/lib/* ${LOGSTASH_HOME}/lib

install -d -m 755 ${LOGSTASH_HOME}/locales
install    -m 644 ${BUILD_DIR}/locales/* ${LOGSTASH_HOME}/locales

install -d -m 755 ${LOGSTASH_HOME}/patterns
install    -m 644 ${BUILD_DIR}/patterns/* ${LOGSTASH_HOME}/patterns

install -d -m 755 ${LOGSTASH_HOME}/spec
cp -Rpd ${BUILD_DIR}/spec/* ${LOGSTASH_HOME}/spec

install -d -m 755 ${LOGSTASH_HOME}/vendor/bundle
cp -Rpd ${BUILD_DIR}/vendor/bundle/* ${LOGSTASH_HOME}/vendor/bundle

install -d -m 755 ${LOGSTASH_HOME}/vendor/collectd
cp -Rpd ${BUILD_DIR}/vendor/collectd/* ${LOGSTASH_HOME}/vendor/collectd

install -d -m 755 ${LOGSTASH_HOME}/vendor/geoip
cp -Rpd ${BUILD_DIR}/vendor/geoip/* ${LOGSTASH_HOME}/vendor/geoip

install -d -m 755 ${LOGSTASH_HOME}/vendor/ua-parser
cp -Rpd ${BUILD_DIR}/vendor/ua-parser/* ${LOGSTASH_HOME}/vendor/ua-parser

# Config
install -d -m 755 ${LOGSTASH_ETC_DIR}/conf
install    -m 755 $RPM_SOURCE_DIR/logstash.conf     ${LOGSTASH_ETC_DIR}/conf
install -d -m 755 ${LOGSTASH_WEB_ETC_DIR}/conf

# Init script
echo ${INITD_DIR}
install -d -m 755 ${INITD_DIR}
install    -m 755 $RPM_SOURCE_DIR/logstash.init     ${INITD_DIR}/logstash
install    -m 755 $RPM_SOURCE_DIR/logstash-web.init     ${INITD_DIR}/logstash-web


# Logs
install -d -m 755 ${PREFIX}/var/log/logstash

# Create daemons directory
install -d -m 755 ${PREFIX}/var/run/logstash
install -d -m 755 ${PREFIX}/var/run/logstash-web

# Create Auxiliary directory
install -d -m 755 ${PREFIX}/var/lib/logstash

# Symbolic links to external dependencies
ln -s /usr/share/jruby/lib ${LOGSTASH_HOME}/vendor/jar
install -d -m 755 ${LOGSTASH_HOME}/vendor/elasticsearch
ln -s /usr/lib/elasticsearch/lib ${LOGSTASH_HOME}/vendor/elasticsearch
ln -s /usr/lib/kibana ${LOGSTASH_HOME}/vendor/kibana
ln -s /usr/lib/logstash/vendor/kibana/config.js ${LOGSTASH_WEB_ETC_DIR}/conf/config.js
