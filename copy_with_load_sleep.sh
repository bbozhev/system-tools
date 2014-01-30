#!/bin/bash
#list of files
list=$1
for i in $list

do
    LOAD=$(uptime | awk '{ sub(/,.*/, "", $9); print $9 * 100.0  }' )

    if [ $LOAD -lt 85 ]
    then
        echo "copy $i to wherever"
    else
        echo "sleep since load is $LOAD"
        sleep 5
    fi 
done
