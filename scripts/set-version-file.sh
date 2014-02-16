#!/bin/sh

#

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

