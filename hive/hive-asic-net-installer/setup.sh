#!/usr/bin/env bash

readonly script_basename="$( basename "$0" )"

# functions

function script_usage {
	echo -e "Usage: ${CYAN}$script_basename [ssh|web]${NOCOLOR}"
}

is_on_busybox() {
	[[ -f "/usr/bin/compile_time" ]]
}


# code

[[ -f /hive/bin/colors ]] && source /hive/bin/colors


cd `dirname $0`

which sshpass > /dev/null || (echo -e "${RED}sshpass${NOCOLOR} is required, try apt-get install sshpass" && exit 1)


IPS=`cat ips.txt | grep -v '#' | grep -v '^$'`
[[ -z $IPS ]] && echo -e "${YELLOW}No IPs in the list${NOCOLOR}" && exit 1

. config.txt

[[ -z $FARM_HASH ]] && echo -e "${RED}FARM_HASH is empty, set it in config${NOCOLOR}" && exit 1

echo -e "FARM_HASH ${GREEN}$FARM_HASH${NOCOLOR}"

echo -e "IPs count `echo "$IPS" | wc -l`"


install_cmd="export PATH=$PATH:/hive/bin:/hive/sbin; export LD_LIBRARY_PATH=/hive/lib; HIVE_HOST_URL=$HIVE_HOST_URL firstrun $FARM_HASH -f"
#install_cmd="pwd; ls" #for testing
#install_cmd="[ -d /hive ] && (echo Already_installed) || ($install_cmd)"

from_ssh=0
from_web=0

case "$1" in
	'ssh')
		from_ssh=1
		;;
	'web')
		from_web=1
		;;
	*)
		script_usage
		exit 0
		;;
esac




for ip in $IPS; do
	[ -z "$ip" ] && echo "Empty line on ips.txt" && continue
	echo
	echo -e "> Processing $LOGIN@${CYAN}$ip${NOCOLOR}"
	if is_on_busybox; then
		$apply_farm_hash_b
		[ $from_web -eq 1 ] && curl -X GET --connect-timeout 5 --digest --user $WEB_LOGIN:$WEB_PASS "http://$ip/cgi-bin/farmConfig.cgi?new_farmhash=$FARM_HASH&new_api=$HIVE_HOST_URL"
		[ $from_ssh -eq 1 ] && sshpass -p$PASS ssh -t $LOGIN@$ip -p 22 -y "su -l -c '$install_cmd'"
		#sshpass -p$PASS ssh -t $LOGIN@$ip -p 22 -y "su -l -c '$install_cmd'"
		exit_code=$?
	else
		[ $from_web -eq 1 ] && curl -X GET --connect-timeout 5 --digest --user $WEB_LOGIN:$WEB_PASS "http://$ip/cgi-bin/farmConfig.cgi?new_farmhash=$FARM_HASH&new_api=$HIVE_HOST_URL"
		[ $from_ssh -eq 1 ] && shpass -p$PASS ssh -t $LOGIN@$ip -p 22 -oConnectTimeout=15 -oStrictHostKeyChecking=no "su -l -c '$install_cmd'" &
		#sshpass -p$PASS ssh -t $LOGIN@$ip -p 22 -oConnectTimeout=15 -oStrictHostKeyChecking=no "su -l -c '$install_cmd'" &
		exit_code=$?
		sleep 1
	fi


	if [[ $exit_code -ne 0 ]]; then
		echo -e "${YELLOW}Error connecting${NOCOLOR}"
	else
		echo -e "${GREEN}OK${NOCOLOR}"

		#Comment it in file
		sed -i "s/^$ip$/\#$ip/g" ips.txt
	fi

done
