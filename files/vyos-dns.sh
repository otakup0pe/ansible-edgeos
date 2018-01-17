#!/bin/vbash
set -eu # you can never be trusted

usage() {
    echo "${0} update <dns> <ip>"
    echo "${0} delete <dns>"
    echo "${0} forward-delete <domain>"
    echo "${0} forward-update <domain> <server>"
    echo "${0} forward-list"
    echo "${0} list"
    exit 1
}

ACTION="$1"
if [ -z "$ACTION" ] ; then
    usage
fi
shift
if [ "$ACTION" == "update" ] || [ "$ACTION" == "delete" ] ; then
    DNS="$1"
fi
if [ "$ACTION" = "update" ] ; then
    IP="$2"
fi
if [ "$ACTION" == "forward-delete" ] ; then
    DOMAIN="$1"
fi
if [ "$ACTION" == "forward-update" ] ; then
    DOMAIN="$1"
    SERVER="$2"
fi

# These are magic scripts which come from VyOS
# shellcheck disable=SC1091
. /opt/vyatta/etc/functions/script-template
configure

if [ "$ACTION" = "update" ] ; then
    EXISTING="$(show system static-host-mapping host-name "$DNS" | head -n 1 | awk '{print $2}')"
    if [ ! -z "$EXISTING" ] && [ "$EXISTING" != "specified" ] && [ "$EXISTING" != "$IP" ] ; then
        echo "Updating ${DNS} ${EXISTING} to ${IP}"
        delete system static-host-mapping host-name "$DNS"
        # VyOS set
        # shellcheck disable=SC2121
        set system static-host-mapping host-name "$DNS" inet "$IP"
        commit
        save
    elif [ "$EXISTING" == "specified" ] ; then
        echo "Updating ${DNS} to ${IP}"
        # VyOS set
        # shellcheck disable=SC2121
        set system static-host-mapping host-name "$DNS" inet "$IP"
        commit
        save
    elif [ "$EXISTING" == "$IP" ] ; then
        echo "${DNS} is ${IP}"
    else
        echo "Unknown state tho"
        exit 1
    fi
elif [ "$ACTION" = "delete" ] ; then
    EXISTING="$(show system static-host-mapping host-name "$DNS" | head -n 1 | awk '{print $2}')"
    if [ ! -z "$EXISTING" ] ; then
        echo "Deleting ${DNS} (${EXISTING})"
        delete system static-host-mapping host-name "$DNS"
        commit
        save
    else
        echo "${DNS} already deleted"
    fi
elif [ "$ACTION" == "list" ] ; then
    show system static-host-mapping | \
        grep -B 1 inet | grep -v '\-\-' | \
        sed -e 's/^[[:space:]]*//' | cut -f 2 -d ' ' | \
        awk '{key=$0; getline; print key " - " $0;}'
elif [ "$ACTION" == "forward-list" ] ; then
    show service dns forwarding | grep "options server" | \
        cut -f 2 -d '=' | sed -e 's!/!!' -e 's!/! - !'
elif [ "$ACTION" == "forward-update" ] ; then
    EXISTING="$(show service dns forwarding | grep "options server" | grep "$DOMAIN" | cut -f 3 -d '/')"
    if [ ! -z "$EXISTING" ] && [ "$EXISTING" != "$SERVER" ] ; then
        echo "Updating forward ${DOMAIN} ${EXISTING} to ${SERVER}"
        delete service dns forwarding options "server=/${DOMAIN}/${EXISTING}"
        set service dns forwarding options "server=/${DOMAIN}/${SERVER}"
        commit
        save
    elif [ -z "$EXISTING" ] ; then
        echo "Updating forward ${DOMAIN} to ${SERVER}"
        set service dns forwarding options "server=/${DOMAIN}/${SERVER}"
        commit
        save
    elif [ "$EXISTING" == "$SERVER" ] ; then
        echo "Forward ${DOMAIN} is already ${SERVER}"
    else
        echo "Unknown state tho"
        exit 1
    fi
elif [ "$ACTION" == "forward-delete" ] ; then
    EXISTING="$(show service dns forwarding | grep "options server" | grep "$DOMAIN" | cut -f 3 -d '/')"
    if [ ! -z "$EXISTING" ] ; then
        echo "Deleting forward ${DOMAIN} (${EXISTING})"
        delete service dns forwarding options "server=/${DOMAIN}/${EXISTING}"
        commit
        save
    else
        echo "Forward ${DOMAIN} already deleted"
    fi
else
    echo "Invalid action"
    exit 1
fi
