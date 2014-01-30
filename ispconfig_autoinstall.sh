#!/bin/sh
msgf=/tmp/ispconfig-install.txt
hostn=`uname -n`
OS=`uname`
IO="" # store IP
case $OS in
   Linux) ipaddr=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`;;
   FreeBSD|OpenBSD) ipaddr=`ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}'` ;;
   SunOS) ipaddr=`ifconfig -a | grep inet | grep -v '127.0.0.1' | awk '{ print $2} '` ;;
   *) ipaddr="Unknown";;
esac

arch=`uname -m`
rpdir=/usr/local/src/repos/
mkdir $rpdir

echo "<html>" >> $msgf
echo "????????? ????? - <a href=http://$ipaddr:8080> ISPConfig </a>" >> $msgf
echo "<br> <br />" >> $msgf
echo "????: $hostn" >> $msgf
echo "<br> <br />  " >> $msgf

setenforce 0

# Dobavi Epel repo

mkdir $rpdir
cd $rpdir && wget http://installers.bozhev.net/epel.rpm && rpm -ihv epel-*
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL

# rpmforge 
cd $rpdir && wget http://installers.bozhev.net/rpmforge.rpm && rpm -ihv rpmforge.rpm
rpm --import /etc/pki/rpm-gpg/*

#dobavi sender na email
cd $rpdir && wget http://installers.bozhev.net/sendemail.rpm
rpm -ihv sendemail.rpm --force 

#pribavi parolata kum neobhodimiqt file
function adminpass
{
echo `</dev/urandom tr -dc A-Za-z0-9 | head -c12`
}

admpass=`adminpass`;

echo "<i>??????????</i>: <b>admin</b>" >> $msgf
echo "<br> <br /> " >> $msgf
echo "<b>??????: <b> $admpass </b>" >> $msgf
echo "<br> <br />" >> $msgf
#premahvane / install na neobhodimi paketi

yum -y remove httpd && yum -y install wget mc fail2ban
#import keys
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*

cd /etc/yum.repos.d/ && rm -rf CentOS-Base.rpo && wget http://installers.bozhev.net/CentOS-Base.repo 

#Add atrpms :
rpm --import http://packages.atrpms.net/RPM-GPG-KEY.atrpms
wget http://packages.atrpms.net/RPM-GPG-KEY.atrpms
rpm --import RPM-GPG-KEY.atrpms
wget installers.bozhev.net/atrpms-i386.rpm && rpm -ihv atrpms-i386.rpm
wget installers.bozhev.net/CentOS-Testing.repo
# install package requirements

yum update -y
yum install mod_fcgid -y
yum groupinstall 'Development Tools' -y
yum groupinstall 'Development Libraries' -y

#remove default postfix if exists, and install frilling new / fancy postfix with mysql support shitec 
yum -y remove postfix

yum -y install ntp httpd mysql-server php php-mysql php-mbstring phpMyAdmin postfix getmail

# Turn on and start services 

chkconfig --levels 235 mysqld on
/etc/init.d/mysqld start

#start na drugi services
chkconfig --levels 235 httpd on
/etc/init.d/httpd start

chkconfig --levels 235 dovecot on
/etc/init.d/dovecot start

chkconfig --levels 235 sendmail off
chkconfig --levels 235 postfix on
/etc/init.d/sendmail stop
/etc/init.d/postfix start

#Secure SSH
perl -p -i -e 's/#Port 22/Port 12545/g' /etc/ssh/sshd_config
/etc/init.d/sshd restart
rm -rf /etc/fail2ban/jail.conf
cd /etc/fail2ban/ && wget http://installers.bozhev.net/jail.conf
perl -p -i -e 's/hostname-change/$hostn/g' /etc/fail2ban/jail.conf


# install some more software :
yum -y install amavisd-new spamassassin clamav clamd unzip bzip2 unrar quota

sa-update
chkconfig --levels 235 amavisd on
chkconfig --levels 235 clamav on
/usr/bin/freshclam
/etc/init.d/amavisd start
/etc/init.d/clamav start
mkdir /var/run/amavisd /var/spool/amavisd /var/spool/amavisd/tmp /var/spool/amavisd/db
chown amavis /var/run/amavisd /var/spool/amavisd /var/spool/amavisd/tmp /var/spool/amavisd/db
yum -y install perl-DBD-mysql

# add some extra repositories for php
cd /etc/yum.repos.d/ && wget http://installers.bozhev.net/CentOS-Testing.repo
rpm --import http://dev.centos.org/centos/RPM-GPG-KEY-CentOS-testing
cd /etc/yum.repos.d/ && wget http://installers.bozhev.net/kbsingh-CentOS-Extras.repo
rpm --import /etc/pki/rpm-gpg/*

#install php and some other soft shitec ;)
yum -y install roundcubemail squirrelmail php php-devel php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-mhash php-mssql php-snmp php-soap php-tidy curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel phpmyadmin

#Install pure-ftpd and quota
yum -y install pure-ftpd quota

chkconfig --levels 235 pure-ftpd on
/etc/init.d/pure-ftpd start

# Install bind dns server

yum -y install bind-chroot
chmod 755 /var/named/
chmod 775 /var/named/chroot/
chmod 775 /var/named/chroot/var/
chmod 775 /var/named/chroot/var/named/
chmod 775 /var/named/chroot/var/run/
chmod 777 /var/named/chroot/var/run/named/
cd /var/named/chroot/var/named/
ln -s ../../ chroot
cp /usr/share/doc/bind-9.3.6/sample/var/named/named.local /var/named/chroot/var/named/named.local
cp /usr/share/doc/bind-9.3.6/sample/var/named/named.root /var/named/chroot/var/named/named.root
cd /var/named/chroot/etc/ && wget http://installers.bozhev.net/ispconfig-named.conf && mv ispconfig-named.conf named.conf
touch /var/named/chroot/etc/named.conf.local

# Install vlogger dependencies and webalizer

yum -y install webalizer perl-DateTime-Format-HTTP perl-DateTime-Format-Builder

#Installing Jailkit:

yum -y install gcc
cd /tmp
wget http://installers.bozhev.net/jailkit-latest.tar.gz && tar -xvf jailkit-latest.tar.gz && cd jailkit-latest
./configure
make
make install
rm -rf jailkit-*

#change some things
perl -p -i -e 's/Defaults    requiretty/# Defaults    requiretty/g' /etc/sudoers

# download preconfigured ispconfig release from your truly and shitec to the shitec : 

cd /usr/local/src/ && wget http://installers.bozhev.net/ispconfig-latest.tar.gz && tar -xvf ispconfig-latest.tar.gz && cd ispconfig3_install/ && bash bash >> $msgf

mysql dbispconfig<<EOFMYSQL
update sys_user SET passwort = md5('$admpass') WHERE userid=1;
EOFMYSQL

#generate random secure pass
function mysqlpass
{
echo `</dev/urandom tr -dc A-Za-z0-9 | head -c13`
}

madpass=`mysqlpass`;
#apply new pass to mysql :

mysqladmin -u root password $madpass
service mysqld restart

echo "<br> <br /> " >> $msgf
echo "<b>MySQL Root ??????: <b> $madpass </b>" >> $msgf
echo "<br> <br />" >> $msgf

sendEmail -f installer@bozhev.net -t support@bozhev.net -u ISPConfig ? ?????????? ?? $hostn -xu installer@bozhev.net -xp jUmpP@2_313#21 -s smtp.gmail.com:25  -o message-header=X-AntiAbuse  message-content-type=html message-charset=utf8 message-file=$msgf
