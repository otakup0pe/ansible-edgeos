#!/bin/vbash
set -e # you can never be trusted

usage() {
    echo "${0} networks"
    echo "${0} ip <network> <host>"
    echo "${0} update <network> <host> <mac> <ip>"
    echo "${0} list <network>"
    exit 0
}

ACTION="$1"
if [ -z "$ACTION" ] ; then
    usage
fi
shift

# These are magic scripts which come from VyOS
# shellcheck disable=SC1091
. /opt/vyatta/etc/functions/script-template
configure

if [ "$ACTION" = "networks" ] ; then
    show service dhcp-server | grep shared-network-name | awk '{print $2}'
elif [ "$ACTION" = "ip" ] ; then
    NETWORK="$1"
    HOST="$2"
    if [ -z "$NETWORK" ] || [ -z "$HOST" ] ; then
        usage
    fi
    SUBNET="$(show service dhcp-server shared-network-name "$NETWORK" | grep subnet | awk '{print $2}')"    
    show service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" ip-address | awk '{print $2}'
elif [ "$ACTION" = "update" ] ; then
    NETWORK="$1"
    HOST="$2"
    MAC="$3"
    IP="$4"
    SUBNET="$(show service dhcp-server shared-network-name "$NETWORK" | grep subnet | awk '{print $2}')"
    if [ -z "$SUBNET" ] ; then
        problems "unable to determine subnet"
    fi
    EXISTING_IP="$(show service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" ip-address | awk '{print $2}')"
    EXISTING_MAC="$(show service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" mac-address | awk '{print $2}')"
    if [ "$EXISTING_IP" = "under" ] && [ "$EXISTING_MAC" = "under" ] ; then
        # VyOS set
        echo "Updating ${HOST} - ${MAC} ${IP}"
        # shellcheck disable=SC2121        
        set service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" ip-address "$IP"
        # shellcheck disable=SC2121        
        set service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" mac-address "$MAC"
        commit
        save
    elif { [ "$EXISTING_IP" != "under" ] && [ "$EXISTING_IP" != "$IP" ]; } || \
             { [ "$EXISTING_MAC" != "under" ] && [ "$EXISTING_MAC" != "$MAC" ]; } ; then
        echo "Updating ${HOST} - ${MAC} ${IP} (from ${EXISTING_MAC} ${EXISTING_IP})"
        delete service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST"
        # VyOS set
        # shellcheck disable=SC2121        
        set service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" ip-address "$IP"
        # shellcheck disable=SC2121        
        set service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" mac-address "$MAC"
        commit
        save
    elif { [ "$EXISTING_IP" != "under" ] && [ "$EXISTING_IP" = "$IP" ]; } || \
             { [ "$EXISTING_MAC" != "under" ] && [ "$EXISTING_MAC" = "$MAC" ]; } ; then
        echo "${HOST} - ${MAC} ${IP}"
    else
        echo "Unknown state tho"
        exit 1
    fi
elif [ "$ACTION" = "list" ] ; then
    NETWORK="$1"
    if [ -z "$NETWORK" ] ; then
        usage
    fi
    SUBNET="$(show service dhcp-server shared-network-name "$NETWORK" | grep subnet | awk '{print $2}')"
    show service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" | \
        grep -A 2 static-mapping | grep -v '\-\-' | \
        sed -e 's/^[[:space:]]*//' | cut -f 2 -d ' ' | \
        awk '{host=$0; getline; ip=$0 ; getline ; mac=$0 ; print mac " " ip " - " host;}'
elif [ "$ACTION" = "delete" ] ; then
    NETWORK="$1"
    HOST="$2"
    if [ -z "$NETWORK" ] || [ -z "$HOST" ] ; then
        usage
    fi
        SUBNET="$(show service dhcp-server shared-network-name "$NETWORK" | grep subnet | awk '{print $2}')"    
    EXISTING_IP="$(show service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" ip-address | awk '{print $2}')"
    EXISTING_MAC="$(show service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST" mac-address | awk '{print $2}')"
    if [ "$EXISTING_IP" != "usage" ] && [ "$EXISTING_MAC" != "usage" ] ; then
        echo "Deleting ${HOST} - ${EXISTING_MAC} ${EXISTING_IP}"
        delete service dhcp-server shared-network-name "$NETWORK" subnet "$SUBNET" static-mapping "$HOST"
        commit
        save
    fi
else
    usage

fi
