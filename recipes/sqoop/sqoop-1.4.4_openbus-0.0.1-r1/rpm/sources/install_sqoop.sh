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

set -ex

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to sqoopdist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install sqoop home [/usr/lib/sqoop]
     --bin-dir=DIR               path to install bins [/usr/bin]
     --conf-dir=DIR              path to configuration files provided by the package [/etc/sqoop/conf.dist]
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'lib-dir:' \
  -l 'conf-dir:' \
  -l 'bin-dir:' \
  -l 'build-dir:' -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
set -ex
while true ; do
    case "$1" in
        --prefix)
        PREFIX=$2 ; shift 2
        ;;
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --conf-dir)
        CONF_DIR=$2 ; shift 2
        ;;
        --bin-dir)
        BIN_DIR=$2 ; shift 2
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

LIB_DIR=${LIB_DIR:-usr/lib/sqoop}
BIN_DIR=${BIN_DIR:-$PREFIX/usr/bin}
CONF_DIR=${CONF_DIR:-$PREFIX/etc/sqoop/conf.dist}
SQOOP_BUILD_DIR=build/sqoop-1.4.4.bin__hadoop-2.0.4-alpha/

install -d -m 0755 ${PREFIX}/${LIB_DIR}
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/*.jar ${PREFIX}/${LIB_DIR}

install -d -m 0755 ${PREFIX}/${LIB_DIR}/lib
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/lib/* ${PREFIX}/${LIB_DIR}/lib

install -d -m 0755 ${PREFIX}/${LIB_DIR}/testdata
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/testdata/*.txt ${PREFIX}/${LIB_DIR}/testdata

install -d -m 0755 ${PREFIX}/${LIB_DIR}/testdata/hcatalog/conf
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/testdata/hcatalog/conf/* ${PREFIX}/${LIB_DIR}/testdata/hcatalog/conf

install -d -m 0755 ${PREFIX}/${LIB_DIR}/testdata/hive/bin
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/testdata/hive/bin/* ${PREFIX}/${LIB_DIR}/testdata/hive/bin

install -d -m 0755 ${PREFIX}/${LIB_DIR}/testdata/hive/scripts
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/testdata/hive/scripts/* ${PREFIX}/${LIB_DIR}/testdata/hive/scripts

install -d -m 0755 ${PREFIX}/${BIN_DIR}
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/bin/* ${PREFIX}/${BIN_DIR}

install -d -m 0755 ${PREFIX}/${CONF_DIR}
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/conf/* ${PREFIX}/${CONF_DIR}

cd ${PREFIX}/etc/sqoop
ln -s conf.dist conf

# Metastore specific files
install -d -m 0755 ${PREFIX}/etc/init.d
install    -m 0644 ${BUILD_DIR}/${SQOOP_BUILD_DIR}/bin/sqoop-metastore ${PREFIX}/etc/init.d/
install -d -m 0755 ${PREFIX}/var/lib/sqoop
install -d -m 0755 ${PREFIX}/var/log/sqoop
