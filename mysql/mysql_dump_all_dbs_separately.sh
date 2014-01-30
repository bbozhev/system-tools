#!/bin/bash
TIMESTAMP=$(date +"%F")
BACKUP_DIR="$1/mysql-backup/$TIMESTAMP"
MYSQL_USER="$2"
MYSQL=`which mysql`
MYSQL_PASSWORD="$3"
MYSQLDUMP=`which mysqldump` 

#create backup directory
mkdir -p $BACKUP_DIR
# get the databases list into variable
databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`
# cycle database names to do a backup for each separately 
for db in $databases; do
  $MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/$db.gz"
done
