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
# description: Summary: Kafka is a high-throughput distributed messaging system designed for persistent messages as the common case. Throughput rather than features are the primary design constraint.  State about what has been consumed is maintained as part of the consumer not the server. Kafka is explicitly distributed. It is assumed that producers, brokers, and consumers are all spread over multiple machines.
# processname: java
# pidfile: /var/run/kafka/kafka-server.pid
### BEGIN INIT INFO
# Provides:          kafka-server
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Kafka is a high-throughput distributed messaging system designed for persistent messages as the common case.
### END INIT INFO
set -e

# Autodetect JAVA_HOME if not defined
if [ -f /etc/profile.d/java.sh ]; then
        . /etc/profile.d/java.sh
        [ -z "\$JAVA_HOME" ] && echo "JAVA_HOME is not defined" && exit 1
else
        echo "enviroment not properly set up"
        exit 1
fi

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON_SCRIPT="/usr/bin/kafka"

NAME=kafka-server
DESC="Kafka daemon"
PID_FILE=/var/run/kafka/kafka-server.pid
install -d -m 0755 -o kafka -g kafka /var/run/kafka/
install -d -m 0755 -o kafka -g kafka /var/run/kafka/
install -d -m 0755 -o kafka -g kafka /var/log/kafka/
install -d -m 0755 -o kafka -g kafka /var/lib/kafka/
install -d -m 0755 -o kafka -g kafka /var/lib/kafka-zookeeper

DODTIME=3

# Checks if the given pid represents a live process.
# Returns 0 if the pid is a live process, 1 otherwise
is_process_alive() {
  local pid="$1" 
  ps -fp $pid | grep $pid | grep kafka > /dev/null 2>&1
}

check_pidfile() {
    local pidfile="$1" # IN
    local pid

    pid=`cat "$pidfile" 2>/dev/null`
    if [ "$pid" = '' ]; then
    # The file probably does not exist or is empty. 
	return 1
    fi
    
    set -- $pid
    pid="$1"

    is_process_alive $pid
}

process_kill() {
    local pid="$1"    # IN
    local signal="$2" # IN
    local second

    kill -$signal $pid 2>/dev/null

   # Wait a bit to see if the dirty job has really been done
    for second in 0 1 2 3 4 5 6 7 8 9 10; do
	if is_process_alive "$pid"; then
         # Success
	    return 0
	fi

	sleep 1
    done

   # Timeout
    return 1
}

stop_pidfile() {
    local pidfile="$1" # IN
    local pid

    pid=`cat "$pidfile" 2>/dev/null`
    if [ "$pid" = '' ]; then
      # The file probably does not exist or is empty. Success
	return 0
    fi
    
    set -- $pid
    pid="$1"

   # First try the easy way
    if process_kill "$pid" 15; then
	return 0
    fi

   # Otherwise try the hard way
    if process_kill "$pid" 9; then
	return 0
    fi

    return 1
}

start() {
    su -s /bin/sh kafka -c "${DAEMON_SCRIPT} --start"
}

stop() {
	if check_pidfile $PID_FILE ;  then
        su -s /bin/sh kafka -c "${DAEMON_SCRIPT} --stop"
	fi
}

case "$1" in
    start)
	start
	;;
    stop)
	stop 
	;;
    force-stop)
        echo -n "Forcefully stopping $DESC: "
        stop_pidfile $PID_FILE
        if check_pidfile $PID_FILE ; then
            echo "$NAME."
        else
            echo " ERROR."
        fi
	;;
    force-reload|condrestart|try-restart)
  # check wether $DAEMON is running. If so, restart
        check_pidfile $PID_FILE && $0 restart
	;;
    restart|reload)
        echo -n "Restarting $DESC: "
        stop
        [ -n "$DODTIME" ] && sleep $DODTIME
        $0 start
	;;
    status)
	echo -n "$NAME is "
	if check_pidfile $PID_FILE ;  then
	    echo "running"
	else
	    echo "not running."
	    exit 1
	fi
	;;
    *)
	N=/etc/init.d/$NAME
  # echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
	echo "Usage: $N {start|stop|restart|force-reload|status|force-stop|condrestart|try-restart}" >&2

	exit 1
	;;
esac

exit 0


