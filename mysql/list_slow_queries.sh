#!/bin/bash
slowlog=`$1`
grep "User@Host" $slowlog |gawk -F " " {'print $3'} |sort -n |uniq -c |sort -n
