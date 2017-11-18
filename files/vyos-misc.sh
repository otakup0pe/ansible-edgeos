#!/bin/vbash

set -e

usage() {
    echo "${0} web restart"
    exit 1
}

if [ $# -lt 1 ] ; then
    usage
fi
ACTION="$1"
shift

if [ "$ACTION" == "web" ] ; then
    SUB_ACTION="$1"
    shift
    if [ "$SUB_ACTION" == "restart" ] ; then
        PID=$(cat /var/run/lighttpd.pid)
        if [ ! -z "$PID" ] ; then
            kill -SIGINT "$PID"
        fi
        /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
    else
        usage
    fi
else
    usage
fi

