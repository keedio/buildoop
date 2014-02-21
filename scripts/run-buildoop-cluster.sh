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

vagrantfileFolder=${BDROOT}/build/vagrant/vm/buildoop-cluster/
lockfile=/tmp/buildoop-cluster.lock

start() {
    echo -n $"Starting $prog: "
    if [ -f $lockfile ] ; then
        echo "buildoop-cluster running"
        exit 0
    fi

    cd $vagrantfileFolder
    vagrant up manager
    vagrant provision manager
    vagrant up node1
    vagrant provision node1
    vagrant up node2
    vagrant provision node2
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
}

stop() {
    echo -n $"Stopping $prog: "
    cd $vagrantfileFolder
    vagrant halt manager
    vagrant halt node1
    vagrant halt node2
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
}

restart() {
    stop
    start
}

reload() {
    restart
}

status() {
    cd $vagrantfileFolder
    vagrant status
}

case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        $1
        ;;
    status)
        $1
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|reload}"
        exit 2
esac
exit $?
