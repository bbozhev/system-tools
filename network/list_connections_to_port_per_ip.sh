#!/bin/bash
 if [ "$1" != "" ]
  then
 netstat -tapn |grep :$1 |awk {'print $5'} | cut -d : -f1 |sort| uniq -c |sort -n
  else
 echo "Usage portchk 25/80/465 etc ..."
 fi
