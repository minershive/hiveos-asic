#!/usr/bin/env bash


[[ -e /hive/bin/colors ]] && source /hive/bin/colors


cd `dirname $0`

which sshpass > /dev/null || (echo -e "${RED}sshpass${NOCOLOR} is required, try apt-get install sshpass" && exit 1)


IPS=`cat ips.txt | grep -v '#' | grep -v '^$'`
[[ -z $IPS ]] && echo -e "${YELLOW}No IPs in the list${NOCOLOR}" && exit 1

. config.txt

#[[ -z $FARM_HASH ]] && echo -e "${RED}FARM_HASH is empty, set it in config${NOCOLOR}" && exit 1

echo -e "FARM_HASH ${GREEN}$FARM_HASH${NOCOLOR}"

echo -e "IPs count `echo "$IPS" | wc -l`"

#sleep 1

install_cmd="cd /tmp; chmod +x /tmp/firmware-upgrade; screen -dm -S upgrade /tmp/firmware-upgrade $URL"
#install_cmd="cd /tmp; chmod +x /tmp/firmware-upgrade; screen -L -dm -S upgrade /tmp/firmware-upgrade"
#install_cmd="cd /tmp; chmod +x /tmp/firmware-upgrade; chmod +x /tmp/firmware-start; nohup /tmp/firmware-start"

for ip in $IPS; do
	echo
	echo -e "> Processing $LOGIN@${CYAN}$ip${NOCOLOR}"
	if [[ -e "/usr/bin/compile_time" ]]; then
#		cp -rf firmware-upgrade firmware-upgrade-hash
#		sed -i '/URL="$1"/c URL="'$URL'"' firmware-upgrade-hash
		sshpass -p$PASS scp -P 22 firmware-upgrade $LOGIN@$ip:/tmp/firmware-upgrade
		sshpass -p$PASS ssh $LOGIN@$ip -p 22 -y "$install_cmd"
	else
#		cp -rf firmware-upgrade firmware-upgrade-hash
#		sed -i '/URL="$1"/c URL="'$URL'"' firmware-upgrade-hash
		sshpass -p$PASS scp -P 22 -oConnectTimeout=15 -oStrictHostKeyChecking=no firmware-upgrade $LOGIN@$ip:/tmp/firmware-upgrade
#		sshpass -p$PASS scp -P 4444 -oConnectTimeout=15 -oStrictHostKeyChecking=no firmware-start $LOGIN@$ip:/tmp/firmware-start
		sleep 1
		sshpass -p$PASS ssh $LOGIN@$ip -p 22 -oConnectTimeout=25 -oStrictHostKeyChecking=no "$install_cmd"
	fi


	if [[ $? -ne 0 ]]; then
		echo -e "${YELLOW}Error connecting${NOCOLOR}"
	else
		echo -e "${GREEN}OK${NOCOLOR}"

		#Comment it in file
		sed -i "s/^$ip$/\#$ip/g" ips.txt
	fi

done
