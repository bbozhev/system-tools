#!/bin/sh
#configuration changes
perl -p -i -e "s/80/8081/g" /usr/local/lxlabs/kloxo/httpdocs/lib/domain/web/driver/web__apachelib.php
perl -p -i -e "s/80/8081/g" /usr/local/lxlabs/kloxo/httpdocs/lib/domain/web/driver/web__lighttpdlib.php
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/mimetype.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/domainip.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/ssl.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/default.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/webmail_redirect.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/webmail.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/cp_config.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/init.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/virtualhost.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/kloxo/forward/forwardhost.conf
perl -p -i -e "s/80/8081/g" /etc/httpd/conf/httpd.conf
#end configuration changes

#store some info 
OS=`uname`
IO="" # store IP
case $OS in
   Linux) IP=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;;
   FreeBSD|OpenBSD) IP=`ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}'` ;;
   SunOS) IP=`ifconfig -a | grep inet | grep -v '127.0.0.1' | awk '{ print $2} '` ;;
   *) IP="Unknown";;
esac
#end of store some info

#start Nginx install 
yum install httpd-devel pcre perl pcre-devel zlib zlib-devel nginx -y 
chkconfig nginx on 
chkconfig httpd on 
#install mod_rpaf
cd /usr/local/src/
wget http://stderr.net/apache/rpaf/download/mod_rpaf-0.6.tar.gz
tar -xvf mod_rpaf-0.6.tar.gz 
cd mod_rpaf-0.6/
apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c
cd /etc/httpd/conf.d/ 
wget bozhev.net/mod_rpaf.conf
/etc/init.d/httpd restart
perl -p -i -e "s/SERVER_IP/$IP/g" /etc/httpd/conf.d/mod_rpaf.conf
mkdir /var/cache/nginx/
cd /etc/nginx/ && rm -rf nginx.conf && wget bozhev.net/nginx-kloxo.conf && mv nginx-kloxo.conf nginx.conf
/etc/init.d/nginx restart
perl -p -i -e "s/SERVER_IP/$IP/g" /etc/nginx/nginx.conf
