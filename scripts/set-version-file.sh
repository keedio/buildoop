#!/bin/sh

#

if [ -z "$BDROOT" ]; then
	echo "BDROOT is not set"
	return 1
fi

conffile=${BDROOT}/buildoop/conf/buildoop.conf
string="Buildoop v0.0.1-alpha"
hash=$(git rev-parse --short HEAD)

version=$string-$hash 
echo $version > ${BDROOT}/VERSION

sed -i -r "s/buildoop.version.*/buildoop.version=\"$version\"/g" ${conffile}

