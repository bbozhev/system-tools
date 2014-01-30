#!/bin/bash
USER=""
DOMAIN=""

while [ "$USER" == "" ] || [ "$CORRECT" != "Y" ] || [ ! -f "/var/cpanel/users/$USER" ]
do
        echo -n "Insert username : "
        read -e USER
        echo -n You chose: $USER Is that Correct? [Y/N]:
        read -e CORRECT
done

while [ "$WRAPPER" != "A" ] && [ "$WRAPPER" != "1" ]
do
        echo -n "Set Wrapper for ALL of user's virtual hosts or for One [A/1] : "
        read -e WRAPPER
        echo You chose: $WRAPPER
        echo
done
if [ "$WRAPPER" == "A" ]
        then
		mkdir -p /usr/local/apache/conf/userdata/ssl/2/$USER
		echo "<IfModule mod_fcgid.c>" >> /usr/local/apache/conf/userdata/ssl/2/$USER/fcgid.conf
		echo "AddHandler php5-fastcgi .php" >> /usr/local/apache/conf/userdata/ssl/2/$USER/fcgid.conf
		echo "Action php5-fastcgi /cgi-bin/php5.fcgi" >> /usr/local/apache/conf/userdata/ssl/2/$USER/fcgid.conf
		echo "</IfModule>" >> /usr/local/apache/conf/userdata/ssl/2/$USER/fcgid.conf

		mkdir -p /usr/local/apache/conf/userdata/std/2/$USER
		echo "<IfModule mod_fcgid.c>" >> /usr/local/apache/conf/userdata/std/2/$USER/fcgid.conf
		echo "AddHandler php5-fastcgi .php" >> /usr/local/apache/conf/userdata/std/2/$USER/fcgid.conf
		echo "Action php5-fastcgi /cgi-bin/php5.fcgi" >> /usr/local/apache/conf/userdata/std/2/$USER/fcgid.conf
		echo "</IfModule>" >> /usr/local/apache/conf/userdata/std/2/$USER/fcgid.conf

		/scripts/verify_vhost_includes
		/scripts/ensure_vhost_includes --user=$USER
fi
if [ "$WRAPPER" == "1" ]
        then
		while [ "$DOMAIN" == "" ] || [ "$CORRECT" != "Y" ]
		do
			echo -n "Type in domain : "
			read -e DOMAIN
			echo -n You entered: $DOMAIN ? [Y/N]:
			read -e CORRECT
		done
		mkdir -p /usr/local/apache/conf/userdata/ssl/2/$USER/$DOMAIN
		echo "<IfModule mod_fcgid.c>" >> /usr/local/apache/conf/userdata/ssl/2/$USER/$DOMAIN/fcgid.conf
		echo "AddHandler php5-fastcgi .php" >> /usr/local/apache/conf/userdata/ssl/2/$USER/$DOMAIN/fcgid.conf
		echo "Action php5-fastcgi /cgi-bin/php5.fcgi" >> /usr/local/apache/conf/userdata/ssl/2/$USER/$DOMAIN/fcgid.conf
		echo "</IfModule>" >> /usr/local/apache/conf/userdata/ssl/2/$USER/$DOMAIN/fcgid.conf

		mkdir -p /usr/local/apache/conf/userdata/std/2/$USER/$DOMAIN
		echo "<IfModule mod_fcgid.c>" >> /usr/local/apache/conf/userdata/std/2/$USER/$DOMAIN/fcgid.conf
		echo "AddHandler php5-fastcgi .php" >> /usr/local/apache/conf/userdata/std/2/$USER/$DOMAIN/fcgid.conf
		echo "Action php5-fastcgi /cgi-bin/php5.fcgi" >> /usr/local/apache/conf/userdata/std/2/$USER/$DOMAIN/fcgid.conf
		echo "</IfModule>" >> /usr/local/apache/conf/userdata/std/2/$USER/$DOMAIN/fcgid.conf

		/scripts/verify_vhost_includes
		/scripts/ensure_vhost_includes --user=$USER
fi

exit 0
