#/bin/bash
mysql=`which mysql`

$mysql -u admin -p`cat /etc/psa/.psa.shadow` psa -e "select dns_zone_id,displayHost from dns_recs GROUP BY dns_zone_id ORDER BY dns_zone_id ASC;" | awk '{print "INSERT INTO dns_recs (type,host,val,time_stamp,dns_zone_id,displayHost,displayVal) VALUES ('\''TXT'\'','\''"$2"'\'','\''v=spf1 a mx ~all'\'',NOW(),"$1",'\''"$2"'\'','\''v=spf1 a mx ~all'\'');"}' | mysql -u admin -p`cat /etc/psa/.psa.shadow` psa
# select everything from name field in domains table and run trough the dnsmng update
$mysql -Ns -uadmin -p`cat /etc/psa/.psa.shadow` -D psa -e 'select name from domains' | awk '{print "/usr/local/psa/admin/sbin/dnsmng update " $1 }' | sh
# output the records to make sure they are correctly entered
$mysql -u admin -p`cat /etc/psa/.psa.shadow` psa -e "SELECT * FROM dns_recs WHERE type='TXT';"
