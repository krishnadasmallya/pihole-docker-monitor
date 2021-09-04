#!/bin/bash
set -e -x
PIHOLEUP=$(pihole status | grep "Pi-hole" | grep enabled | wc -l)
while : 
do
    if [ $PIHOLEUP -eq 1 ]
    then
        sudo wget -qO - https://v.firebog.net/hosts/lists.php?type=tick |xargs -I {} sudo sqlite3 /etc/pihole/gravity.db "INSERT INTO adlist (Address) VALUES ('{}');"
        pihole -g
        break
    else
        sleep 2
    fi
    PIHOLEUP=$(pihole status | grep "Pi-hole" | grep enabled | wc -l)
done