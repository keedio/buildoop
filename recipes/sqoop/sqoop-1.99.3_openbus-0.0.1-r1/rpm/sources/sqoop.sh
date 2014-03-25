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

# Autodetect JAVA_HOME if not defined
if [ -f /etc/profile.d/java.sh ]; then
        . /etc/profile.d/java.sh
        [ -z "$JAVA_HOME" ] && echo "JAVA_HOME is not defined" && exit 1
else
        echo "enviroment not properly set up"
        exit 1
fi


LIB_DIR=/usr/lib/sqoop
BIN_DIR=${LIB_DIR}/bin

CLASSPATH=$CLASSPATH:$(echo "$LIB_DIR"/client-lib/*.jar | tr ' ' ':')

env CLASSPATH=$CLASSPATH $BIN_DIR/sqoop.sh client $@

