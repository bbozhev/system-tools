#==============================================================
# Zabbix-Create - Automated Agent/Host Install - (c) Travis Mathis - Millicorp 2011
# Version 2
# Change Log: 6/20/11 Finished Host Creation
#==============================================================

# VARIABLES
HOSTNAME=''
SERVER=''
IP=''
API=''

# CONSTANT VARIABLES
ERROR='0'
ZABBIX_USER='user'
ZABBIX_PASS='pass'

# Create zabbix.repo file in /etc/yum.repos.d/zabbix.repo
echo "[zabbix]" > /etc/yum.repos.d/zabbix.repo
echo "name=Zabbix (CentOS_5)" >> /etc/yum.repos.d/zabbix.repo
echo "type=rpm-md" >> /etc/yum.repos.d/zabbix.repo
echo "baseurl=http://download.opensuse.org/repositories/home:/ericgearhart:/zabbix/CentOS_CentOS-5/" >> /etc/yum.repos.d/zabbix.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/zabbix.repo
echo "gpgkey=http://download.opensuse.org/repositories/home:/ericgearhart:/zabbix/CentOS_CentOS-5/repodata/repomd.xml.key" >> /etc/yum.repos.d/zabbix.repo
echo "enabled=1" >> /etc/yum.repos.d/zabbix.repo

# Find out where the server is located and store it as 2 variables.
# Edit Your information below

while [ $ERROR = 0 ]
do
  read -p "What DATACENTER is this server located at?(MIA, FMY, LAX) " RESP
  if [ "$RESP" != "MIA" ] && [ "$RESP" != "LAX" ] && [ "$RESP" != "FMY" ]; then
    echo "That is not a valid option, please try again!"
    echo ""
  else
    ERROR='1'
  fi
done

if [ "$RESP" = "MIA" ]; then
  SERVER='192.168.1.99'
  API='http://192.168.1.99/zabbix/api_jsonrpc.php'
fi

if [ "$RESP" = "FMY" ]; then
  SERVER='192.168.5.99'
  API='http://192.168.5.99/zabbix/api_jsonrpc.php'
fi

if [ "$RESP" = "LAX" ]; then
  SERVER='192.168.9.99'
  API='http://192.168.9.99/zabbix/api_jsonrpc.php'
fi

# Request the Hostname of the server
echo ""
read -p "What is the HOSTNAME of the server? " RESP2
  HOSTNAME="$RESP2"

# Request IPADDRESS of the server
echo ""
read -p "What is the IP ADDRESS of the server? " RESP3
  IP="$RESP3"

# Install zabbix-agent
yum -y install zabbix-agent

create config file in /etc/zabbix/zabbix_agentd.conf
rm -rf /etc/zabbix/zabbix_agentd.conf
echo "LogFile=/tmp/zabbix_agentd.log" > /etc/zabbix/zabbix_agentd.conf
echo "Server=$SERVER" >> /etc/zabbix/zabbix_agentd.conf
echo "Hostname=$HOSTNAME" >> /etc/zabbix/zabbix_agentd.conf

# start zabbix agent
chkconfig --level 2345 zabbix-agentd on
service zabbix-agentd start

# Authenticate with Zabbix API
authenticate() {
curl -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"password\": \"$ZABBIX_PASS\", \"user\": \"$ZABBIX_USER\"}, \"jsonrpc\": \"2.0\", 
\"method\": \"user.authenticate\",\"auth\": \"\", \"id\": 0}" $API | grep -Eo 'Set-Cookie: zbx_sessionid=.+' | head -n 1 | cut -d '=' -f 2 | tr -d '\r'
}
AUTH_TOKEN=$(authenticate)

# Give user HostGroup option list to choose from

get_host_groups() {
  curl -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"output\": \"extend\", \"sortfield\": \"name\"}, \"jsonrpc\": \"2.0\", \"method\": 
\"hostgroup.get\",\"auth\": \"$AUTH_TOKEN\", \"id\": 0}" $API | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^name/ {print $2}' | sed 's/\(^"\|"$\)//g'
}

HOST_GROUPS=$(get_host_groups)

echo ""
echo "Please select a HOSTGROUP"
echo ""
select HOST in $HOST_GROUPS
do
echo ""
break;
done


# Give user Template option list to choose from
get_templates() {
  curl -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"params\": {\"output\": \"extend\", \"sortfield\": \"template\"}, \"jsonrpc\": \"2.0\", 
\"method\": \"template.get\",\"auth\": \"$AUTH_TOKEN\", \"id\": 0}" $API | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^host"/ {print $2}' | sed 
's/\(^"\|"$\)//g'
}


TEMPLATES=$(get_templates)

echo ""
echo "Please select a TEMPLATE"
echo ""
select TEMP in $TEMPLATES
do
echo ""
break;
done

# Get Host_Group and Template ID's for host creation
get_host_group_id() {
 curl -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"params\":{\"output\": 
\"extend\",\"filter\":{\"name\":[\"$HOST\"]}},\"auth\":\"$AUTH_TOKEN\",\"id\":0}" $API | sed -e 's/[{}]/''/g' | sed -e 's/[""]/''/g' | grep -Eo groupid:[0-9]* | 
cut -d":" -f2;
}

get_template_id() {
  curl -i -X POST -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"template.get\",\"params\":{\"output\": 
\"extend\",\"filter\":{\"host\":[\"$TEMP\"]}},\"auth\":\"$AUTH_TOKEN\",\"id\":0}" $API | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^templateid/ {print $2}' | 
sed 's/\(^"\|"$\)//g' | sed -e 's/["]]/''/g'
}

HOSTGROUPID=$(get_host_group_id)
TEMPLATEID=$(get_template_id)

# Create Host
create_host() {
  curl -i -X POST -H 'Content-Type: application/json-rpc' -d 
"{\"jsonrpc\":\"2.0\",\"method\":\"host.create\",\"params\":{\"host\":\"$HOSTNAME\",\"ip\":\"$IP\",\"port\":10050,\"useip\":1,\"groups\":[{\"groupid\":$HOSTGROUPID}],\"templates\":[{\"templateid\":$TEMPLATEID}]},\"auth\":\"$AUTH_TOKEN\",\"id\":0}" 
$API
}
