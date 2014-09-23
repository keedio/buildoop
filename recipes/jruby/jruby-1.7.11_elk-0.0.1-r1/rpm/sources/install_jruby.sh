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
     --target=TARGET		 target path to install jruby
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'build-dir:' \
  -l 'target-dir:' \
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
        --target-dir)
        TARGET_DIR=$2 ; shift 2
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


TARGET_DIR=${TARGET_DIR:-$PREFIX/usr/share/jruby}


install -d -m 755 ${TARGET_DIR}/bin
install    -m 644 ${BUILD_DIR}/bin/* ${TARGET_DIR}/bin

install -d -m 755 ${TARGET_DIR}/lib/jni/x86_64-Linux
install    -m 644 ${BUILD_DIR}/lib/jni/x86_64-Linux/* ${TARGET_DIR}/lib/jni

install -d -m 755 ${TARGET_DIR}/lib/ruby
cp -r ${BUILD_DIR}/lib/ruby/* ${TARGET_DIR}/lib/ruby
install    -m 644 ${BUILD_DIR}/lib/jruby.jar ${TARGET_DIR}/lib

install -d -m 755 ${TARGET_DIR}/lib
install    -m 644 ${BUILD_DIR}/maven/jruby-complete/target/jruby-complete-1.7.11.jar ${TARGET_DIR}/lib
