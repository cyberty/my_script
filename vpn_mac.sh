#!/bin/bash

function isnt_connected () {
    scutil --nc status "$vpn" | head -1 | grep -qv Connected
}

function isnt_disconnected () {
    scutil --nc status "$vpn" | head -1 | grep -qv Disconnected
}

function setdns() {
    TMPFILE="/tmp/setdns_tmp"
    echo "d.init" > $TMPFILE
    echo "d.add ServerAddresses * 127.0.0.1" >> $TMPFILE

    SERVICES=$(echo "list State:/Network/Service/[^/]+/PPP" | scutil | cut -c 16- | cut -d / -f 1-4)
    for SERVICE in $SERVICES
    do
        echo "set $SERVICE/DNS" >> $TMPFILE
    done

    scutil < $TMPFILE
}

function cleardnscache() {
    PRODUCT_VERSION=`/usr/bin/sw_vers -productVersion | cut -f 1-2 -d .`

    if [ "$PRODUCT_VERSION" = "10.10" ] ; then
      dscacheutil -flushcache

      if [ -e /usr/sbin/discoveryutil ]; then
        discoveryutil udnsflushcaches
      fi

      if [ -e /usr/sbin/mDNSResponder ]; then
        killall -HUP mDNSResponder
      fi
    elif [ "$PRODUCT_VERSION" = "10.9" ] ; then
      dscacheutil -flushcache
      killall -HUP mDNSResponder
    elif [ "$PRODUCT_VERSION" = "10.8" ] ; then
      killall -HUP mDNSResponder
    elif [ "$PRODUCT_VERSION" = "10.7" ] ; then
      killall -HUP mDNSResponder
    else
      dscacheutil -flushcache
    fi
}

vpnlist=(
    '云梯 香港2号 L2TP'
    '云梯 香港1号 L2TP'
    '云梯 新加坡1号 L2TP'
    '云梯 新加坡2号 L2TP'
    '云梯 新加坡1号 PPTP'
    '云梯 新加坡2号 PPTP'
    '云梯 台湾1号 L2TP'
    '云梯 台湾1号 PPTP'
    '云梯 日本2号 L2TP'
    )
for ((i=0; i < ${#vpnlist[*]}; i++)); do
	vpn=${vpnlist[$i]}
    echo ${vpn} "Connecting..."
    scutil --nc start "${vpn}" --secret 'VPNCloudMakesVPNEasy'
    let loops=0
    let maxloops=15
    while isnt_connected "$vpn"; do
        sleep 1
        let loops=$loops+1
        [ $loops -gt $maxloops ] && break
    done

    if [ $loops -le $maxloops ]; then
        networksetup -setdnsservers "${vpn}" 127.0.0.1
        sed -i -e '/^nameserver/d' /etc/resolv.conf && echo "nameserver 127.0.0.1" >> /etc/resolv.conf
        setdns
        cleardnscache
        echo "Success!"
        exit
    else
        scutil --nc stop "${vpn}"
        let loops=0
        let maxloops=20
        while isnt_disconnected "$vpn"; do
            sleep 1
            let loops=$loops+1
            [ $loops -gt $maxloops ] && break
        done
    fi

done
