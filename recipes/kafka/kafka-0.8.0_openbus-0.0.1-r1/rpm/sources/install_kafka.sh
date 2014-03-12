#!/bin/sh

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
     --build-dir=DIR             path to dist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install Kafka home [/usr/lib/kafka]
     --installed-lib-dir=DIR     path where lib-dir will end up on target system
     --bin-dir=DIR               path to install bins [/usr/bin]
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'lib-dir:' \
  -l 'installed-lib-dir:' \
  -l 'bin-dir:' \
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
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --installed-lib-dir)
        INSTALLED_LIB_DIR=$2 ; shift 2
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

LIB_DIR=${LIB_DIR:-/usr/lib/kafka}
INSTALLED_LIB_DIR=${INSTALLED_LIB_DIR:-/usr/lib/kafka}
BIN_DIR=${BIN_DIR:-/usr/bin}
CONF_DIR=${CONF_DIR:-/etc/kafka/conf.dist}

install -d -m 0755 $PREFIX/$LIB_DIR
install -d -m 0755 $PREFIX/$LIB_DIR/bin

cp -ra ${BUILD_DIR}/core/target/scala-*/*.jar $PREFIX/$LIB_DIR
cp -ra ${BUILD_DIR}/bin/*.sh $PREFIX/$LIB_DIR/bin

# Copy in the configuration files
install -d -m 0755 $PREFIX/$CONF_DIR
cp -a ${RPM_SOURCE_DIR}/conf.dist/* $PREFIX/$CONF_DIR
# cp -a ${BUILD_DIR}/config/* $PREFIX/$CONF_DIR
cd $PREFIX/etc/kafka
ln -s conf.dist conf
cd -
install -d -m 0755 $PREFIX/$BIN_DIR

cat > $PREFIX/$BIN_DIR/kafka <<EOF
#!/bin/sh 

set -e

usage() {
  echo "
usage: \$0 <options>
     --start                     start kafka service
     --stop                      stop kafka service
     --list                      list topics
  "
  exit 1
}

OPTS=\$(getopt \
  -n \$0 \\
  -o '' \\
  -l 'start::' \\
  -l 'stop::' \\
  -l 'list::' -- "\$@")

if [ \$? != 0 ] ; then
    usage
fi

eval set -- "\$OPTS"
while true ; do
    case "\$1" in
        --start)
        START=1 ; shift ; break
        ;;
        --stop)
        STOP=1 ; shift ; break
        ;;
        --list)
        LIST=1 ; shift ; break
        ;;
        --)
        usage
        exit 1
        ;;
        *)
        echo "Unknown option: \$1"
        usage
        exit 1
        ;;
    esac
done

# Autodetect JAVA_HOME if not defined
if [ -f /etc/profile.d/java.sh ]; then
        . /etc/profile.d/java.sh
        [ -z "\$JAVA_HOME" ] && echo "JAVA_HOME is not defined" && exit 1
else
        echo "enviroment not properly set up"
        exit 1
fi

CLASSPATH=$INSTALLED_LIB_DIR/*.jar

if [ ! -z \$START ]; then
  # we consider we have an external zookeeper for production enviroments
  # $LIB_DIR/bin/zookeeper-server-start.sh /etc/kafka/conf/zookeeper.properties&
  $LIB_DIR/bin/kafka-server-start.sh /etc/kafka/conf/server.properties&
  echo \$! > /var/run/kafka/kafka-server.pid
elif [ ! -z \$STOP ]; then
  kill \$(ps -eaf|grep kafka|grep -v grep|awk '{print \$2}')
elif [ ! -z \$LIST ]; then
  $LIB_DIR/bin/kafka-list-topic.sh
fi
EOF
chmod 755 $PREFIX/$BIN_DIR/kafka


