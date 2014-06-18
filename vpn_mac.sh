#!/bin/bash

function isnt_connected () {
    scutil --nc status "$vpn" | head -1 | grep -qv Connected
}


vpnlist=('VPN1' 'VPN2' 'VPN3')
for ((i=0; i < ${#vpnlist[*]}; i++)); do
	vpn=${vpnlist[$i]}
    echo ${vpn} "Connecting..."
    scutil --nc start "${vpn}" --secret 'VPNCloudMakesVPNEasy' 
    let loops=0
    while isnt_connected "$vpn"; do
    	sleep 1
    	let loops=$loops+1
    	[ $loops -gt 10 ] && break
    done
    [ $loops -lt 10 ] && networksetup -setdnsservers "${vpn}" 192.168.100.1 10.0.1.1
done
