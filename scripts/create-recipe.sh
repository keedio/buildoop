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

BDROOT=/tmp

usage() {
	echo "Usage: $0 -n RECIPE_NAME -v RECIPE_VERSION -r RECIPE_REVISION "
	echo -e "\nExample:"
	echo -e "$0 -n kafka -v 0.9.0 -r openbus-0.0.1-r1\n"
	exit 1
}

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

[[ $# != 6 ]] && usage

#string with command options
options=$@

# An array with all the arguments
arguments=($options)

# Loop index
index=0

for argument in $options
  do
    # Incrementing index
    index=`expr $index + 1`

    # The conditions
    case $argument in
      -n) RECIPE_NAME=${arguments[index]} ;;
      -v) RECIPE_VERSION=${arguments[index]} ;;
      -r) RECIPE_REVISION=${arguments[index]} ;;
    esac
  done

[[ -z $RECIPE_NAME ]] || 
	[[ -z $RECIPE_VERSION ]] || 
	[[ -z $RECIPE_REVISION ]] && 
	usage

confirm || exit 1

basedir=${BDROOT}/recipes/${RECIPE_NAME}/${RECIPE_NAME}-${RECIPE_VERSION}_${RECIPE_REVISION}/
mkdir -p ${basedir}/rpm/sources
mkdir -p ${basedir}/rpm/specs

cat <<! > ${BDROOT}/recipes/${RECIPE_NAME}/ChangeLog
DD-MM-YYYY User Committer <usercommiter@domain.org>

	* Initial commit.
!

cat <<! > ${BDROOT}/recipes/${RECIPE_NAME}/${RECIPE_NAME}-${RECIPE_VERSION}_${RECIPE_REVISION}.bd
{
	"do_info": {
		"description": "${RECIPE_NAME} description", 
		"homepage":    "http://www.${RECIPE_NAME}.org/",
		"license":     "Apache-2.0",
		"filename":    "${RECIPE_NAME}-${RECIPE_VERSION}_${RECIPE_REVISION}.bd"
	},
	
	"do_download": {
		"src_uri":    "http://ftp.${RECIPE_NAME}.org/${RECIPE_NAME}-${RECIPE_VERSION}-src.tgz",
		"src_md5sum": "46b3e65e38f1bde4b6251ea131d905f4"
	},

	"do_fetch": {
		"download_cmd": "wget"
	},
}
!

tree ${BDROOT}/recipes/${RECIPE_NAME}
exit 0

