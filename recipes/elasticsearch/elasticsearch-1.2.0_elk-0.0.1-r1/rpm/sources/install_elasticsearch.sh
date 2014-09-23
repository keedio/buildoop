#!/bin/bash

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

set -e

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to Whirr dist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --doc-dir=DIR               path to install docs into [/usr/share/doc/whirr]
     --lib-dir=DIR               path to install Whirr home [/usr/lib/whirr]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'doc-dir:' \
  -l 'lib-dir:' \
  -l 'build-dir:' -- "$@")

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
        --doc-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --lib-dir)
        LIB_DIR=$2 ; shift 2
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

for var in PREFIX BUILD_DIR ; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

TARGET_RELEASE=target/releases/elasticsearch-1.2.0.tar.gz
ELASTICSEARCH_HOME=${ELASTICSEARCH_HOME:-/usr/lib/elasticsearch}
SRC=${BUILD_DIR}/working/elasticsearch-1.2.0

mkdir ${BUILD_DIR}/working
tar xzf ${BUILD_DIR}/${TARGET_RELEASE} -C ${BUILD_DIR}/working

install -d -m 755 ${PREFIX}/${ELASTICSEARCH_HOME}

install -d -m 755  ${PREFIX}/${ELASTICSEARCH_HOME}/bin
install -m 755 ${SRC}/bin/elasticsearch ${PREFIX}/${ELASTICSEARCH_HOME}/bin
install -m 644 ${SRC}/bin/elasticsearch.in.sh ${PREFIX}/${ELASTICSEARCH_HOME}/bin
install -m 755 ${SRC}/bin/plugin ${PREFIX}/${ELASTICSEARCH_HOME}/bin

#libs
install -d -m 755 ${PREFIX}/${ELASTICSEARCH_HOME}/lib/sigar
install  -m 644 ${SRC}/lib/*.jar ${PREFIX}/${ELASTICSEARCH_HOME}/lib
install  -m 644 ${SRC}/lib/sigar/*.jar ${PREFIX}/${ELASTICSEARCH_HOME}/lib/sigar
install  -m 644 ${SRC}/lib/sigar/libsigar-amd64-linux.so ${PREFIX}/${ELASTICSEARCH_HOME}/lib/sigar

# config
install -d -m 755  ${PREFIX}/etc/elasticsearch/conf
install -m 644 ${SRC}/config/elasticsearch.yml ${PREFIX}/etc/elasticsearch/conf
install -m 644 ${SRC}/config/logging.yml ${PREFIX}/etc/elasticsearch/conf

# readme and license
install -m 644 ${SRC}/*.txt  ${PREFIX}/${ELASTICSEARCH_HOME}
install -m 644 ${SRC}/README.textile  ${PREFIX}/${ELASTICSEARCH_HOME}/README.txt


# data
install -d -m 755 ${PREFIX}/var/lib/elasticsearch
install -d -m 755 ${PREFIX}/${ELASTICSEARCH_HOME}/plugins

# logs
install -d -m 755 ${PREFIX}/var/log/elasticsearch
install -d -m 755 ${PREFIX}/etc/logrotate.d/
install -m 644 ${RPM_SOURCE_DIR}/elasticsearch.logrotate ${PREFIX}/etc/logrotate.d/elasticsearch

# sysconfig and init
install -d -m 755 ${PREFIX}/etc/rc.d/init.d
install -d -m 755 ${PREFIX}/etc/sysconfig
install -m 755 ${RPM_SOURCE_DIR}/elasticsearch.init ${PREFIX}/etc/rc.d/init.d/elasticsearch
install -m 755 ${RPM_SOURCE_DIR}/elasticsearch.sysconfig ${PREFIX}/etc/sysconfig/elasticsearch

install -d -m 755 ${PREFIX}/var/run/elasticsearch
install -d -m 755 ${PREFIX}/var/lib/elasticsearch
install -d -m 755 ${PREFIX}/lock/subsys/elasticsearch


