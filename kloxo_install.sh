#!/bin/sh
msgf=/tmp/kloxo-install.txt
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
echo "????????? ????? - <a href=http://$ipaddr:7778> Kloxo </a>" >> $msgf
echo "<br> <br />" >> $msgf
echo "????: $hostn" >> $msgf
echo "<br> <br />  " >> $msgf

setenforce 0

# Dobavi Epel repo

mkdir $rpdir
cd $rpdir && wget http://bozhev.net/epel.rpm && rpm -ihv epel-*
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL

# rpmforge 
cd $rpdir && wget http://bozhev.net/rpmforge.rpm && rpm -ihv rpmforge.rpm
rpm --import /etc/pki/rpm-gpg/*

#dobavi sender na email
cd $rpdir && wget http://bozhev.net/sendemail.rpm
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
echo "<br> <br /> " >> $msgf
echo "<b>SSH Port: 12545 </b>" >> $msgf
echo "<br> <br /> " >> $msgf
#premahvane / install na neobhodimi paketi
yum -y remove httpd && yum --enablrepo=epel -y install wget mc fail2ban
cd /usr/local/src/ && wget http://bozhev.net/kloxo-script && bash kloxo-script

#Secure SSH
yum -y install wget mc fail2ban
perl -p -i -e 's/#Port 22/Port 12545/g' /etc/ssh/sshd_config
/etc/init.d/sshd restart
rm -rf /etc/fail2ban/jail.conf
cd /etc/fail2ban/ && wget http://bozhev.net/jail.conf
perl -p -i -e 's/hostname-change/$hostn/g' /etc/fail2ban/jail.conf
phpshit=`php -v`;

echo "<b> $phpshit <b>" >> $msgf
echo "<br> <br />  " >> $msgf
#smeni default pass-a s po-gore generiraniqt :
cd /usr/local/lxlabs/kloxo/httpdocs  && /usr/bin/lphp.exe  ../bin/common/resetpassword.php master $admpass

sendEmail -f installer@bozhev.net -t support@bozhev.net -u Kloxo ??????????? ?? $hostn -xu installer@bozhev.net -xp jUmpP@2_313#21 -s smtp.gmail.com:25  -o message-header=X-AntiAbuse  message-content-type=html message-charset=utf8 message-file=$msgf
