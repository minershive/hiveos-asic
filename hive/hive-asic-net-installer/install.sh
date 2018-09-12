#!/usr/bin/env bash


[[ -e /hive/bin/colors ]] && source /hive/bin/colors


cd `dirname $0`

which sshpass > /dev/null || (echo -e "${RED}sshpass${NOCOLOR} is required, try apt-get install sshpass" && exit 1)


IPS=`cat ips.txt | grep -v '#' | grep -v '^$'`
[[ -z $IPS ]] && echo -e "${YELLOW}No IPs in the list${NOCOLOR}" && exit 1

. config.txt

[[ -z $FARM_HASH ]] && echo -e "${RED}FARM_HASH is empty, set it in config${NOCOLOR}" && exit 1

echo -e "FARM_HASH ${GREEN}$FARM_HASH${NOCOLOR}"

echo -e "IPs count `echo "$IPS" | wc -l`"

#sleep 1

install_cmd="cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=$FARM_HASH sh selfupgrade"
#install_cmd="pwd; ls" #for testing
install_cmd="[ -d /hive ] && (echo 'Already installed') || ($install_cmd)"

for ip in $IPS; do
	echo
	echo -e "> Processing $LOGIN@${CYAN}$ip${NOCOLOR}"
	sshpass -p$PASS ssh $LOGIN@$ip -p 22 -o ConnectTimeout=10 "$install_cmd"


	if [[ $? -ne 0 ]]; then
		echo -e "${YELLOW}Error connecting${NOCOLOR}"
	else
		echo -e "${GREEN}OK${NOCOLOR}"

		#Comment it in file
		sed -i "s/^$ip$/\#$ip/g" ips.txt
	fi

done