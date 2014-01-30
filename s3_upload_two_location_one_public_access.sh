#!/bin/bash
user=$1
option=$2
feedsjdir="/home/$user/bin"
command="java -jar $jdir/$option.jar --export --config"
dirtosync="/mnt1/"
daten=$(date +"%Y-%m-%d")
bs3repo="s3://s3repo-url/exports/$daten/"
s3repo="s3://s3repo-url/output/"
LOGFILE="/tmp/$1-$s.log"

if [ $# -lt 1 ]
then
echo "Usage: $0 --env <qa|prod>"
echo ""
echo "Option --env is required"
    exit 1
fi

while [ ! -z "$*" ]
do
        case $1 in
                --env) shift
                        ENV="$1"
                        shift
                        ;;
                *) echo "Unknown option $1"
                        exit 1
                        ;;
        esac
done

bs3repo="s3://s3repo-url/$ENV/$daten/"
s3repo="s3://s3repo-url/$ENV/output/"


#get all config files
for i in `ls -la /home/config/ | grep output_config | grep -i -v vhm | awk {'print $9'}`; do $command /home/config/$i;done >> $LOGFILE 2>&1

#sync files to s3repo in appropriate folder
echo "####### Export finished, starting file upload #########"
/usr/local/bin/s3cmd put --recursive --multipart-chunk-size-mb=500 $dirtosync/* $bs3repo >> $LOGFILE 2>&1
/usr/local/bin/s3cmd put --acl-public --recursive --multipart-chunk-size-mb=500 $dirtosync/* $s3repo >> $LOGFILE 2>&1 
/usr/local/bin/s3cmd put --acl-public $LOGFILE $s3repo  >> $LOGFILE 2>&1

#Archive
for file in `ls $dirtosync/*.xml`;do mv $file ${file%.*}-$daten.xml;done
for file in `ls $dirtosync/*.xml`;do gzip -f $file; done


#Remove old files. Hardcoded because of error prevention
find /mnt1/reports-export -type f -mtime +14 -exec rm {} \;
