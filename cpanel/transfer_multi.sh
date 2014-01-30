#!/bin/bash
TEMPURLS=""
HOSTSFILE=""
for acc in `cat ${1}`
do
if [ -f /var/cpanel/users/${acc} ]; then
    IP=`grep '^IP=' /var/cpanel/users/${acc} |cut -d= -f2`
    DOM=`grep '^DNS=' /var/cpanel/users/${acc} |cut -b5-99`
    TEMPURLS="${TEMPURLS}\nhttp://${IP}/~${acc}/"
    HOSTSFILE="${HOSTSFILE}\n${IP} ${DOM} www.${DOM}"
fi
done
echo -e $TEMPURLS
echo
echo -e $HOSTSFILE
