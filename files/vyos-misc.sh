#!/bin/vbash

set -e
# script-template is alias based...
shopt -s expand_aliases
# These are magic scripts which come from VyOS.
# Interesting to note that this only works with `source`
# and not `.`
# shellcheck disable=SC1091
source /opt/vyatta/etc/functions/script-template
configure

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
elif [ "$ACTION" == "loadkey" ] ; then
    L_USER="$1"
    if [ -z "$L_USER" ] ; then
        echo "must specify username"
        exit 1
    fi
    loadkey "$L_USER" "/home/${L_USER}/.ssh/authorized_keys"
else
    usage
fi

