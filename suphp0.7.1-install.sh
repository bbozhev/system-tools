#!/bin/bash

mkdir /root/setup
cd /root/setup
yum -y install gcc gcc-c* httpd-devel* apr*
wget http://www.suphp.org/download/suphp-0.7.1.tar.gz
tar -xzvf suphp-0.7.1.tar.gz

cd suphp-0.7.1
./configure --prefix=/opt/suphp --with-apxs=/usr/sbin/apxs --with-apr=/usr/bin/apr-1-config --with-setid-mode=force --with-apache-user=apache --with-log=/var/log/suphp.log
make && make install

touch /etc/httpd/conf.d/suphp.conf;
echo "LoadModule suphp_module modules/mod_suphp.so" >> /etc/httpd/conf.d/suphp.conf
echo "suPHP_Engine on" >> /etc/httpd/conf.d/suphp.conf
echo "AddHandler x-httpd-php .php .php5 .php4 .php3 .phtml" >> /etc/httpd/conf.d/suphp.conf
echo "suPHP_ConfigPath /etc" >> /etc/httpd/conf.d/suphp.conf
echo "suPHP_AddHandler x-httpd-php" >> /etc/httpd/conf.d/suphp.conf
echo "DirectoryIndex index.php" >> /etc/httpd/conf.d/suphp.conf

touch /etc/suphp.conf

echo "[global]" >> /etc/suphp.conf
echo "logfile=/var/log/httpd/suphp_log" >> /etc/suphp.conf
echo "loglevel=info" >> /etc/suphp.conf
echo "webserver_user=apache" >> /etc/suphp.conf
echo "docroot=/home/" >> /etc/suphp.conf
echo "allow_file_group_writeable=false" >> /etc/suphp.conf
echo "allow_file_others_writeable=false" >> /etc/suphp.conf
echo "allow_directory_group_writeable=false" >> /etc/suphp.conf
echo "allow_directory_others_writeable=false" >> /etc/suphp.conf
echo "check_vhost_docroot=true" >> /etc/suphp.conf
echo "errors_to_browser=true" >> /etc/suphp.conf
echo "env_path=\"/usr/bin:/bin\"" >> /etc/suphp.conf
echo "umask=0022" >> /etc/suphp.conf
echo "min_uid=500" >> /etc/suphp.conf
echo "min_gid=500" >> /etc/suphp.conf
echo "[handlers]" >> /etc/suphp.conf
echo "x-httpd-php=\"php:/usr/bin/php-cgi\"" >> /etc/suphp.conf
echo "x-suphp-cgi="execute:\!self"" > suphp.conf

mkdir /opt/suphp/etc
cp /etc/suphp.conf /opt/suphp/etc/

sed -i "s/LoadModule suexec_module/#LoadModule suexec_module/g" /etc/httpd/conf/httpd.conf
sed -i "s/SuExecUserGroup/suPHP_UserGroup/g" /etc/httpd/conf/httpd.conf
sed -i "s/SuExecUserGroup/suPHP_UserGroup/g" /etc/httpd/sites.d/*.conf
