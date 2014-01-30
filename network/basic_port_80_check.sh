#/bin/bash
netstat -tapn |grep :80 |awk {'print $5 '} | cut -d : -f1 |uniq -c |sort -n
