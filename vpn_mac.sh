#!/bin/bash

function isnt_connected () {
    scutil --nc status "$vpn" | head -1 | grep -qv Connected
}

function isnt_disconnected () {
    scutil --nc status "$vpn" | head -1 | grep -qv Disconnected
}

#vpnlist=('云梯 新加坡1号 L2TP')
vpnlist=('云梯 新加坡1号 L2TP' '云梯 新加坡2号 L2TP' '云梯 台湾1号 L2TP' '云梯 香港1号 L2TP' '云梯 香港2号 L2TP')
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
