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
     --build-dir=DIR             path to pig dist dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install pig home [/usr/lib/pig]
     --bin-dir=DIR               path to install bins [/usr/bin]
     --conf-dir=DIR              path to configuration files provided by the package [/etc/pig/conf]
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

LIB_DIR=${LIB_DIR:-usr/lib/pig}
BIN_DIR=${BIN_DIR:-$PREFIX/usr/bin}
CONF_DIR=${CONF_DIR:-$PREFIX/etc/pig/conf}

install -d -m 0755 ${PREFIX}/${LIB_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/ivy.xml ${PREFIX}/${LIB_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/LICENSE.txt ${PREFIX}/${LIB_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/NOTICE.txt ${PREFIX}/${LIB_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/*.jar ${PREFIX}/${LIB_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/README.txt ${PREFIX}/${LIB_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/doap_Pig.rdf ${PREFIX}/${LIB_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/autocomplete ${PREFIX}/${LIB_DIR}

install -d -m 0755 ${PREFIX}/${LIB_DIR}/ivy
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/ivy/* ${PREFIX}/${LIB_DIR}/ivy

install -d -m 0755 ${PREFIX}/${LIB_DIR}/legacy
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/legacy/* ${PREFIX}/${LIB_DIR}/legacy

install -d -m 0755 ${PREFIX}/${LIB_DIR}/lib
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/lib/*.jar ${PREFIX}/${LIB_DIR}/lib

install -d -m 0755 ${PREFIX}/${LIB_DIR}/lib/h2
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/lib/h2/* ${PREFIX}/${LIB_DIR}/lib/h2

install -d -m 0755 ${PREFIX}/${LIB_DIR}/license
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/license/* ${PREFIX}/${LIB_DIR}/license

install -d -m 0755 ${PREFIX}/${BIN_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/bin/* ${PREFIX}/${BIN_DIR}

install -d -m 0755 ${PREFIX}/${CONF_DIR}
install    -m 0644 ${BUILD_DIR}/${PIG_BUILD_DIR}/conf/* ${PREFIX}/${CONF_DIR}
