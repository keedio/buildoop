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

KIBANA_HOME=${KIBANA_HOME:-$PREFIX/usr/lib/kibana}
KIBANA_ETC_DIR=${KIBANA_ETC_DIR:-$PREFIX/etc/kibana}
KIBANA_USER_HOME=${KIBANA_USER_HOME:-$PREFIX/var/lib/kibana}

install -d -m 755 ${KIBANA_HOME}
install    -m 644 ${BUILD_DIR}/README.md ${KIBANA_HOME}
install    -m 644 ${BUILD_DIR}/build.txt ${KIBANA_HOME}
install    -m 644 ${BUILD_DIR}/index.html ${KIBANA_HOME}
install    -m 644 ${BUILD_DIR}/LICENSE.md ${KIBANA_HOME}
install    -m 644 ${BUILD_DIR}/favicon.ico ${KIBANA_HOME}

install -d -m 755 ${KIBANA_HOME}/app
cp -Rpd ${BUILD_DIR}/app/* ${KIBANA_HOME}/app

install -d -m 755 ${KIBANA_HOME}/css
cp -Rpd ${BUILD_DIR}/css/* ${KIBANA_HOME}/css

install -d -m 755 ${KIBANA_HOME}/font
cp -Rpd ${BUILD_DIR}/font/* ${KIBANA_HOME}/font

install -d -m 755 ${KIBANA_HOME}/img
cp -Rpd ${BUILD_DIR}/img/* ${KIBANA_HOME}/img

install -d -m 755 ${KIBANA_HOME}/vendor
cp -Rpd ${BUILD_DIR}/vendor/* ${KIBANA_HOME}/vendor

install -d -m 755 ${KIBANA_ETC_DIR}/conf
install    -m 644 ${BUILD_DIR}/config.js ${KIBANA_ETC_DIR}/conf
ln -s /etc/kibana/conf/config.js ${KIBANA_HOME}/config.js

install -d -m 755 ${KIBANA_USER_HOME}
