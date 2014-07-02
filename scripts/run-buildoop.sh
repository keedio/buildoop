#!/bin/bash
#
# Build script for run buildoop from Jenkins.
#

JAVA_HOME=/usr/java/jdk1.7.0_51/
GROOVY_HOME=/opt/groovy-2.2.1
MAVEN_HOME=/usr/share/java/maven
SCALA_HOME=/opt/scala-2.10.3
PATH=$PATH:$GRADLE_HOME/bin:$GROOVY_HOME/bin:$SCALA_HOME/bin:$JAVA_HOME/bin:/usr/local/bin/

export JAVA_HOME GROOVY_HOME MAVEN_HOME SCALA_HOME PATH

pushd /opt/buildoop.git
source set-buildoop-env
buildoop openbus-0.0.1 -build | tee /tmp/buildoop.log
popd
