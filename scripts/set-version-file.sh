#!/bin/sh
# vim:set ts=4:sw=4:et:sts=4:ai:tw=80
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -z "$BDROOT" ]; then
	echo "BDROOT is not set"
	exit 1
fi

conffile=${BDROOT}/buildoop/conf/buildoop.conf
string="Buildoop v0.0.1-alpha"
hash=build-$(date +"%m%d20%y")

version=$string-$hash 
a=$(cat ${BDROOT}/VERSION | cut -d'-' -f5)
sum=$(($a + 1))
echo ${version}-$sum > ${BDROOT}/VERSION

sed -i -r "s/buildoop.version.*/buildoop.version=\"$version-$sum\"/g" ${conffile}

