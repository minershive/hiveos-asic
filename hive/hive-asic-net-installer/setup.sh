#!/usr/bin/env bash


# functions

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

#sleep 1

install_cmd="export PATH=$PATH:/hive/bin:/hive/sbin; export LD_LIBRARY_PATH=/hive/lib; HIVE_HOST_URL=$HIVE_HOST_URL firstrun $FARM_HASH -f"
#install_cmd="pwd; ls" #for testing
#install_cmd="[ -d /hive ] && (echo Already_installed) || ($install_cmd)"

for ip in $IPS; do
	[ -z "$ip" ] && echo "Empty line on ips.txt" && continue
	echo
	echo -e "> Processing $LOGIN@${CYAN}$ip${NOCOLOR}"
	if is_on_busybox; then
		sshpass -p$PASS ssh -t $LOGIN@$ip -p 22 -y "su -l -c '$install_cmd'"
		exit_code=$?
	else
		sshpass -p$PASS ssh -t $LOGIN@$ip -p 22 -oConnectTimeout=15 -oStrictHostKeyChecking=no "su -l -c '$install_cmd'" &
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
