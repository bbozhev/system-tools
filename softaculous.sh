#/bin/bash
bash=`which bash`
tmpdir=/tmp
if [ $# -lt 1 ]
then
echo "Usage: --normal, --nocpphp, --proxy use according to your local network/system setup"
echo ""
echo "Option is required"
    exit 1
fi
while [ ! -z "$*" ]
do
	case $1 in
		--normal)
		cd $tmpdir
		wget -N http://files.softaculous.com/install.sh
		chmod 755 install.sh
		$bash $tmpdir/install.sh
		;;
		--nocpphp)
		cd $tmpdir
		wget -N http://files.softaculous.com/install.sh
		chmod 755 install.sh
		$bash $tmpdir/install.sh --nocpphp
		;;
		--proxy)
		cd $tmpdir
		wget -N http://files.softaculous.com/install.sh
		chmod 755 install.sh
		$bash $tmpdir/install.sh proxy proxy_ip=YOUR_IP:PORT proxy_auth=USERNAME:PASSWORD
		;;
		*) echo "Unknown option $1"
	esac
done
echo "Installed as per $1"
