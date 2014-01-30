#!/bin/sh
for username in `cat /etc/userdomains | awk {'print $2'} | grep -v nobody | sort -n | uniq`;do mkdir -p /home/$username/tmp/web && cd /home/$username && chown -R $username: tmp/ ;done
