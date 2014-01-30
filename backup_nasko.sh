#/bin/bash
#kvo backupvame tyi to bellow : 
backup_files="/var/www/htdocs /var/lib/mysql/"

# kude otivat tiq backups :
dest="/backup"

# sha arhivirameee filename + date v imeto  :
day=$(date +%Y'-'%m'-'%d"-"%A)
archive_name=Backup
archive_file="$archive_name-$day.tgz"

# Aide malko logvane i pisane na status-i po logove
echo "Backing up $backup_files to $dest/$archive_file" >> /backup/$archive_file.log
date
echo

# Backup the files using tar.
tar czf $dest/$archive_file $backup_files

# Print end status message.
echo
echo "Backup finished" >> /backup/$archive_file.log
date

# mail setup
MTO="nasko@nasko.com"
MSUB="Backup completed for `hostname` `date`"
MES=/tmp/message-backup.txt
MATT=/backup/$archive_file.log

# create message for mail
echo "Backup successfully done. Please see attached file." > $MES
echo "" >> $MES
echo "Backup file: $OUT" >> $MES
echo "" >> $MES

which mutt > /dev/null
if [ $? -eq 0 ]; then
        # now mail backup file with this attachment
        mutt -s "$MSUB" -a "$MATT" $MTO < $MES
else
        echo "Command mutt not found, cannot send an email with attachment"
fi
