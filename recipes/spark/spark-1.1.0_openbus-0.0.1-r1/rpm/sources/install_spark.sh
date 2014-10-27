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
     --build-dir=DIR             path to dist.dir
     --source-dir=DIR            path to package shared files dir
     --prefix=PREFIX             path to install into

  Optional options:
     --doc-dir=DIR               path to install docs into [/usr/share/doc/spark]
     --lib-dir=DIR               path to install Spark home [/usr/lib/spark]
     --installed-lib-dir=DIR     path where lib-dir will end up on target system
     --bin-dir=DIR               path to install bins [/usr/bin]
     --examples-dir=DIR          path to install examples [doc-dir/examples]
     --pyspark-python            executable to use for Python interpreter [python]
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'doc-dir:' \
  -l 'lib-dir:' \
  -l 'installed-lib-dir:' \
  -l 'bin-dir:' \
  -l 'source-dir:' \
  -l 'examples-dir:' \
  -l 'pyspark-python:' \
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
        --source-dir)
        SOURCE_DIR=$2 ; shift 2
        ;;
        --doc-dir)
        DOC_DIR=$2 ; shift 2
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
        --examples-dir)
        EXAMPLES_DIR=$2 ; shift 2
        ;;
        --pyspark-python)
        PYSPARK_PYTHON=$2 ; shift 2
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

for var in PREFIX BUILD_DIR SOURCE_DIR; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

if [ -z "${SCALA_HOME}" ]; then
    echo Missing env. var SCALA_HOME
    usage
fi

MAN_DIR=${MAN_DIR:-/usr/share/man/man1}
DOC_DIR=${DOC_DIR:-/usr/share/doc/spark}
LIB_DIR=${LIB_DIR:-/usr/lib/spark}
SPARK_BIN_DIR=${BIN_DIR:-/usr/lib/spark/bin}
INSTALLED_LIB_DIR=${INSTALLED_LIB_DIR:-/usr/lib/spark}
EXAMPLES_DIR=${EXAMPLES_DIR:-$DOC_DIR/examples}
BIN_DIR=${BIN_DIR:-/usr/bin}
CONF_DIR=${CONF_DIR:-/etc/spark/conf}
SCALA_HOME=${SCALA_HOME:-/usr/share/scala}
PYSPARK_PYTHON=${PYSPARK_PYTHON:-python}

install -d -m 0755 $PREFIX/$LIB_DIR
install -d -m 0755 $PREFIX/$LIB_DIR/lib
install -d -m 0755 $PREFIX/$SPARK_BIN_DIR
install -d -m 0755 $PREFIX/$LIB_DIR/sbin
install -d -m 0755 $PREFIX/$DOC_DIR

install -d -m 0755 $PREFIX/var/lib/spark/
install -d -m 0755 $PREFIX/var/log/spark/
install -d -m 0755 $PREFIX/var/run/spark/
install -d -m 0755 $PREFIX/var/run/spark/work/
ln -s /usr/lib/spark/logs $PREFIX/var/log/spark/logs

#tar --wildcards -C $PREFIX/$LIB_DIR -zxf ${BUILD_DIR}/assembly/target/spark-assembly*-dist.tar.gz 'lib/*'

#for comp in core repl bagel mllib streaming; do
#  install -d -m 0755 $PREFIX/$LIB_DIR/$comp/lib
#  tar --wildcards -C $PREFIX/$LIB_DIR/$comp/lib -zxf ${BUILD_DIR}/assembly/target/spark-assembly*-dist.tar.gz spark-$comp\*
#done
install   -m 0644  ${BUILD_DIR}/assembly/target/scala-2.10/spark-assembly*.jar \
		   $PREFIX/$LIB_DIR/lib

install   -m 0644  ${BUILD_DIR}/lib_managed/jars/datanucleus-*.jar $PREFIX/$LIB_DIR/lib

## FIXME: Spark maven assembly needs to include examples into it.
install -d -m 0755 $PREFIX/$LIB_DIR/examples
cp ${BUILD_DIR}/examples/target/spark-examples*${SPARK_VERSION}.jar $PREFIX/$LIB_DIR/examples
cp ${BUILD_DIR}/examples/target/scala-2.10/spark-examples*${SPARK_VERSION}.jar $PREFIX/$LIB_DIR/examples

# ec2 files
install -d -m 0755 $PREFIX/$LIB_DIR/ec2
cp -r ${BUILD_DIR}/ec2/* $PREFIX/$LIB_DIR/ec2

# python files
install -d -m 0755 $PREFIX/$LIB_DIR/python
cp -r ${BUILD_DIR}/python/* $PREFIX/$LIB_DIR/python

# From Cloudera
cp -a ${BUILD_DIR}/bin/*.sh $PREFIX/$LIB_DIR/bin/
cp -a ${BUILD_DIR}/sbin/*.sh $PREFIX/$LIB_DIR/sbin/

cp -a $BUILD_DIR/bin/spark-class $PREFIX/$LIB_DIR/bin/
cp -a $BUILD_DIR/sbin/spark-executor $PREFIX/$LIB_DIR/sbin/
cp -a ${BUILD_DIR}/bin/spark-shell $PREFIX/$LIB_DIR/bin/
cp -a ${BUILD_DIR}/bin/beeline $PREFIX/$LIB_DIR/bin/
cp -a ${BUILD_DIR}/bin/run-example $PREFIX/$LIB_DIR/bin/
cp -a ${BUILD_DIR}/bin/spark-sql $PREFIX/$LIB_DIR/bin/
cp -a ${BUILD_DIR}/bin/spark-submit $PREFIX/$LIB_DIR/bin/
chmod 755 $PREFIX/$LIB_DIR/bin/*
chmod 755 $PREFIX/$LIB_DIR/sbin/*
touch $PREFIX/$LIB_DIR/RELEASE

# Copy in the configuration files
install -d -m 0755 $PREFIX/$CONF_DIR
cp -a ${BUILD_DIR}/conf/* $PREFIX/$CONF_DIR
cp  $PREFIX/$CONF_DIR/spark-env.sh.template $PREFIX/$CONF_DIR/spark-env.sh
ln -s /etc/spark/conf $PREFIX/$LIB_DIR/conf

# Unpack static UI resources into install_dir/spark where it is expected to be
#tar --wildcards -C $PREFIX/$LIB_DIR -zxf ${BUILD_DIR}/assembly/target/spark-assembly*-dist.tar.gz ui-resources/\*

# set correct permissions for exec. files
for execfile in bin/spark-class bin/spark-shell sbin/spark-executor ; do
  chmod 755 $PREFIX/$LIB_DIR/$execfile
done
chmod 755 $PREFIX/$SPARK_BIN_DIR/compute-classpath.sh

# copy default files
install -d -m 0755 $PREFIX/etc/default/
install    -m 0755 ${SOURCE_DIR}/spark-default.sh $PREFIX/etc/default/spark-master
install    -m 0755 ${SOURCE_DIR}/spark-default.sh $PREFIX/etc/default/spark-worker
install    -m 0755 ${SOURCE_DIR}/spark-default.sh $PREFIX/etc/default/spark-history-server

# Copy in the wrappers
install -d -m 0755 $PREFIX/$BIN_DIR
for wrap in sbin/spark-executor bin/spark-shell ; do
  cat > $PREFIX/$BIN_DIR/`basename $wrap` <<EOF


#!/bin/bash 

# Autodetect JAVA_HOME if not defined
if [ -f /etc/profile.d/java.sh ]; then
        . /etc/profile.d/java.sh
        [ -z "\$JAVA_HOME" ] && echo "JAVA_HOME is not defined" && exit 1
else
        echo "enviroment not properly set up"
        exit 1
fi

exec $INSTALLED_LIB_DIR/$wrap "\$@"
EOF
  chmod 755 $PREFIX/$BIN_DIR/`basename $wrap`
done

cat >> $PREFIX/$CONF_DIR/spark-env.sh <<EOF

### Let's run everything with JVM runtime, instead of Scala
export SPARK_LAUNCH_WITH_SCALA=0
export SPARK_LIBRARY_PATH=\${SPARK_HOME}/lib
export SCALA_LIBRARY_PATH=\${SPARK_HOME}/lib
export SPARK_MASTER_WEBUI_PORT=18080
export SPARK_MASTER_PORT=7077

### Comment above 2 lines and uncomment the following if
### you want to run with scala version, that is included with the package
#export SCALA_HOME=\${SCALA_HOME:-$LIB_DIR/scala}
#export PATH=\$PATH:\$SCALA_HOME/bin

### change the following to specify a real cluster's Master host
export STANDALONE_SPARK_MASTER_HOST=hostname

EOF

ln -s /var/run/spark/work $PREFIX/$LIB_DIR/work

cp -r ${BUILD_DIR}/python ${PREFIX}/${INSTALLED_LIB_DIR}/
cp ${BUILD_DIR}/bin/pyspark ${PREFIX}/${INSTALLED_LIB_DIR}/bin
cp ${BUILD_DIR}/bin/pyspark ${PREFIX}/${INSTALLED_LIB_DIR}/
cat > $PREFIX/$BIN_DIR/pyspark <<EOF
#!/bin/bash

# Autodetect JAVA_HOME if not defined
if [ -f /etc/profile.d/java.sh ]; then
        . /etc/profile.d/java.sh
        [ -z "\$JAVA_HOME" ] && echo "JAVA_HOME is not defined" && exit 1
else
        echo "enviroment not properly set up"
        exit 1
fi

export PYSPARK_PYTHON=${PYSPARK_PYTHON}

exec $INSTALLED_LIB_DIR/pyspark "\$@"
EOF
chmod 755 $PREFIX/$BIN_DIR/pyspark

