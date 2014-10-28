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
     --build-dir=DIR             path to hive/build/dist
     --prefix=PREFIX             path to install into
     --source-dir		 path of source files
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'build-dir:' \
  -l 'source-dir:' \
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
	--source-dir)
        SOURCE_DIR=$2 ; shift 2
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


CASSANDRA_HOME=${CASSANDRA_HOME:-$PREFIX/usr/lib/cassandra}

install -d -m 755 ${CASSANDRA_HOME}/
install    -m 644 ${BUILD_DIR}/CHANGES.txt ${CASSANDRA_HOME}/
install    -m 644 ${BUILD_DIR}/LICENSE.txt ${CASSANDRA_HOME}/
install    -m 644 ${BUILD_DIR}/NEWS.txt ${CASSANDRA_HOME}/
install    -m 644 ${BUILD_DIR}/NOTICE.txt ${CASSANDRA_HOME}/

install -d -m 755 ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/cassandra ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/cassandra-cli ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/cqlsh ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/debug-cql ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/nodetool ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/sstablekeys ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/sstableloader ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/sstablescrub ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/sstableupgrade ${CASSANDRA_HOME}/bin
install    -m 755 ${BUILD_DIR}/bin/stop-server ${CASSANDRA_HOME}/bin

install -d -m 755 ${CASSANDRA_HOME}/lib
install    -m 644 ${BUILD_DIR}/lib/*.jar ${CASSANDRA_HOME}/lib
install    -m 644 ${BUILD_DIR}/lib/*.zip ${CASSANDRA_HOME}/lib
install    -m 644 ${BUILD_DIR}/build/apache-cassandra-thrift-2.1.0-SNAPSHOT.jar ${CASSANDRA_HOME}/lib/apache-cassandra-thrift-2.1.0.jar
install    -m 644 ${BUILD_DIR}/build/apache-cassandra-clientutil-2.1.0-SNAPSHOT.jar ${CASSANDRA_HOME}/lib/apache-cassandra-clientutil-2.1.0.jar
install    -m 644 ${BUILD_DIR}/build/apache-cassandra-2.1.0-SNAPSHOT.jar ${CASSANDRA_HOME}/lib/apache-cassandra-2.1.0.jar


install -d -m 755 ${CASSANDRA_HOME}/lib/licenses
install    -m 644 ${BUILD_DIR}/lib/licenses/* ${CASSANDRA_HOME}/lib/licenses

install -d -m 755 ${CASSANDRA_HOME}/pylib
install    -m 644 ${BUILD_DIR}/pylib/*.py ${CASSANDRA_HOME}/pylib

install -d -m 755 ${CASSANDRA_HOME}/pylib/cqlshlib
install    -m 644 ${BUILD_DIR}/pylib/cqlshlib/*.py ${CASSANDRA_HOME}/pylib/cqlshlib

install -d -m 755 ${CASSANDRA_HOME}/pylib/cqlshlib/test
install    -m 644 ${BUILD_DIR}/pylib/cqlshlib/test/* ${CASSANDRA_HOME}/pylib/cqlshlib/test

install -d -m 755 ${CASSANDRA_HOME}/interface
install    -m 644 ${BUILD_DIR}/interface/cassandra.thrift ${CASSANDRA_HOME}/interface

install -d -m 755 ${CASSANDRA_HOME}/tools
install    -m 644 ${BUILD_DIR}/tools/*.yaml ${CASSANDRA_HOME}/tools

install -d -m 755 ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/cassandra-stress ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/cassandra-stressd ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/json2sstable ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/sstable2json ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/sstablemetadata ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/sstablerepairedset ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/sstablesplit ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/token-generator ${CASSANDRA_HOME}/tools/bin
install    -m 755 ${BUILD_DIR}/tools/bin/cassandra.in.sh ${CASSANDRA_HOME}/tools/bin


install -d -m 755 ${CASSANDRA_HOME}/tools/lib
install    -m 644 ${BUILD_DIR}/tools/lib/* ${CASSANDRA_HOME}/tools/lib
install    -m 644 ${BUILD_DIR}/build/tools/lib/* ${CASSANDRA_HOME}/tools/lib

install -d -m 755 ${PREFIX}/var/run/cassandra
install -d -m 755 ${PREFIX}/var/log/cassandra
install -d -m 755 ${PREFIX}/var/lib/cassandra/commitlog
install -d -m 755 ${PREFIX}/var/lib/cassandra/data
install -d -m 755 ${PREFIX}/var/lib/cassandra/saved_caches

install -d -m 755 ${PREFIX}/etc/cassandra/conf
install    -m 644 ${BUILD_DIR}/conf/*.properties ${PREFIX}/etc/cassandra/conf
install    -m 644 ${BUILD_DIR}/conf/*.yaml ${PREFIX}/etc/cassandra/conf
install    -m 644 ${BUILD_DIR}/conf/cqlshrc.sample ${PREFIX}/etc/cassandra/conf
install    -m 644 ${BUILD_DIR}/conf/*.xml ${PREFIX}/etc/cassandra/conf
install    -m 644 ${BUILD_DIR}/conf/README.txt ${PREFIX}/etc/cassandra/conf
install    -m 644 ${BUILD_DIR}/conf/*.sh ${PREFIX}/etc/cassandra/conf



install -d -m 755 ${PREFIX}/etc/cassandra/conf/triggers
install    -m 644 ${BUILD_DIR}/conf/triggers/README.txt ${PREFIX}/etc/cassandra/conf

install -d -m 755 ${PREFIX}/etc/rc.d/init.d

install -d -m 755 ${PREFIX}/etc/default
install    -m 644 ${SOURCE_DIR}/cassandra-default ${PREFIX}/etc/default/cassandra
