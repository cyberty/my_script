#!/bin/sh

count=0
IPs='119.29.29.29 223.5.5.5'

for ip in $IPs ; do
    #echo $ip
    ping -c 3 $ip > /dev/null 2>&1
    if [ 0 -eq $? ]; then
        break
    else
        echo $(date +%F_%T%z) $ip 'error.' >> /root/log.redail
        count=$((count+1))
    fi
done

IP_cnt=$(echo $IPs|wc -w)
if [ $count -ge $IP_cnt ]; then
    echo $(date +%F_%T%z) redail >> /root/log.redail
    ifdown wan; sleep 1; ifup wan
fi
echo 'count: ' $count
