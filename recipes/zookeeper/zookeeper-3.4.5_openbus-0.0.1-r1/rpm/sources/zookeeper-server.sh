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

# chkconfig: 2345 80 20
# description: Summary: ZooKeeper is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services. All of these kinds of services are used in some form or another by distributed applications. Each time they are implemented there is a lot of work that goes into fixing the bugs and race conditions that are inevitable. Because of the difficulty of implementing these kinds of services, applications initially usually skimp on them ,which make them brittle in the presence of change and difficult to manage. Even when done correctly, different implementations of these services lead to management complexity when the applications are deployed.
# processname: java
# pidfile: /var/run/zookeeper/zookeeper-server.pid
### BEGIN INIT INFO
# Provides:          zookeeper-server
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: ZooKeeper is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services.
### END INIT INFO
. /etc/init.d/functions

# Autodetect JAVA_HOME if not defined
if [ -f /etc/profile.d/java.sh ]; then
        . /etc/profile.d/java.sh
        [ -z "$JAVA_HOME" ] && echo "JAVA_HOME is not defined" && exit 1
else
        echo "enviroment not properly set up"
        exit 1
fi

command="/usr/bin/zookeeper-server"
user="zookeeper"
prog=`basename ${command}`
zookeeper_pidfile=/var/run/zookeeper/zookeeper-server.pid
pidfile=/var/run/zookeeper-server.pid
lockfile=/var/lock/subsys/zookeeper-server

ZOOKEEPER_SHUTDOWN_TIMEOUT=15
: ${ZOOKEEPER_CONF:="/etc/zookeeper/conf/zoo.cfg"}
[ -f $ZOOKEEPER_CONF ] &&  clientPort=`grep clientPort $ZOOKEEPER_CONF | cut -d'=' -f2`
: ${clientPort:=2181}

install -d -m 0755 -o zookeeper -g zookeeper /var/run/zookeeper/

# Checks if the given pid represents a live process.
# Returns 0 if the pid is a live process, 1 otherwise


function status_ext(){
    status -p $pidfile ${command}
    RETVAL=$?
    listening=`/usr/sbin/lsof -nPi | grep ":${clientPort} " | grep "LISTEN" | tr -s ' ' | cut -d' ' -f2`
    [ -f $pidfile ] && pid=`cat $pidfile`
    if [ $RETVAL -eq 3 ] && [ -n "$listening" ]; then
	echo "Port ${clientPort} is being used by ${listening} but ${prog} is stopped"
	RETVAL=150
    elif [ $RETVAL -eq 0 ] && [ -z "$listening" ]; then
	echo "Service running but not listening port ${clientPort}"
	RETVAL=151
    elif [ -n "$listening" ] && [ "${listening}" -ne "${pid}" ]; then
	echo "Process listening $clientPort is ${listening}. Expected: ${pid}"
	RETVAL=152
    fi
    return $RETVAL
}
    
function start() {
    status_ext>/dev/null
    case "$?" in
	0)
	    echo "Service is running."
	    RETVAL=0
	    ;;
	1)
	    echo "program is dead and /var/run pid file exists"
	    RETVAL=1
	    ;;
	2)
	    echo "program is dead and /var/lock lock file exists"
	    RETVAL=1
	    ;;
	3)
	    echo -n $"Starting $prog: "
	    daemon --pidfile=$pidfile --user=${user} --check=$prog ${command} start
	    RETVAL=$?
	    if [ $RETVAL -eq 0 ]; then
		touch $lockfile
		ln $zookeeper_pidfile $pidfile
	    fi
	    ;;
	*)
	    echo "Service is in unknown state. Status: $RETVAL"
            return 1
    esac
    return $RETVAL
}

function stop() {
    echo -n $"Stopping $prog: "

    # This will remove pid and args files from /var/run/zookeeper
    killproc -p $pidfile -d $ZOOKEEPER_SHUTDOWN_TIMEOUT ${command}
    RETVAL=$?

    # Now we want to remove lock file and hardlink of pid file
    [ $RETVAL -eq 0 ] && rm -f $pidfile $lockfile
    echo
    return $RETVAL
}

case "$1" in
    configtest|reload)
	RETVAL=3
	;;
    start)
	start
	RETVAL=$?
	;;
    stop)
	stop 
	RETVAL=$?
	;;
    try-restart|condrestart)
	status_ext>/dev/null || exit 0
	stop 
	start
	;;
    status)
	status_ext
        RETVAL=$?
        ;;
    restart|force-reload)
        stop
	start
	RETVAL=$?
	;;
    init)
	status_ext>/dev/null
	if [ $? != 3 ]; then
	    echo "Error: ${prog} should be stopped." 
	    RETVAL=1
        else
            shift
            su -s /bin/bash ${user} -c "${command}-initialize $*"
	    RETVAL=$?
        fi
	;;
    usage)
	echo "Usage: $0 {start|stop|restart|force-reload|condrestart|try-restart|status|init|usage}" >&2
	RETVAL=0
        ;;	
    *)
	echo "Usage: $0 {start|stop|restart|force-reload|condrestart|try-restart|status|init|usage}" >&2
	RETVAL=2
	;;
esac

exit $RETVAL
