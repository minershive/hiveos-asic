#!/usr/bin/env bash


#
# Copyright (C) 2016-2020  Hiveon
# Distributed under GNU GENERAL PUBLIC LICENSE 2.0
# License information can be found in the LICENSE file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE
#


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

#[[ -z $FARM_HASH ]] && echo -e "${RED}FARM_HASH is empty, set it in config${NOCOLOR}" && exit 1

echo -e "FARM_HASH ${GREEN}$FARM_HASH${NOCOLOR}"

echo -e "IPs count `echo "$IPS" | wc -l`"

#sleep 1

#install_cmd="cd /tmp; chmod +x /tmp/firmware-upgrade; screen -dm -S upgrade /tmp/firmware-upgrade $URL"

IFS=$'\n'
for ip_worker in $IPS; do
	[ -z "$ip_worker" ] && echo "Empty line on ips.txt" && continue
	install_cmd="cd /tmp; chmod +x /tmp/firmware-upgrade; screen -dm -S upgrade /tmp/firmware-upgrade $URL"
	ip=$(echo "$ip_worker" | awk {'print $1'})
	worker=$(echo "$ip_worker" | awk {'print $2'})
	[[ ! -z $worker ]] && install_cmd="$install_cmd $worker"
	echo
	echo -e "> Processing $LOGIN@${CYAN}$ip${NOCOLOR}"
	if is_on_busybox; then
#		cp -rf firmware-upgrade firmware-upgrade-hash
#		sed -i '/URL="$1"/c URL="'$URL'"' firmware-upgrade-hash
#		sshpass -p$PASS scp -P 22 firmware-upgrade $LOGIN@$ip:/tmp/firmware-upgrade #scp don't save fingerprint
		sshpass -p$PASS ssh $LOGIN@$ip -p 22 -y sh -c 'cat > /tmp/firmware-upgrade' < firmware-upgrade-L3
		[ -n "$FARM_HASH" ] && sshpass -p$PASS ssh $LOGIN@$ip -p 22 -y sh -c 'cat > /config/FARM_HASH' <<< "$FARM_HASH"
		sshpass -p$PASS ssh $LOGIN@$ip -p 22 -y "$install_cmd"
	else
#		cp -rf firmware-upgrade firmware-upgrade-hash
#		sed -i '/URL="$1"/c URL="'$URL'"' firmware-upgrade-hash
		sshpass -p$PASS scp -P 22 -oConnectTimeout=15 -oStrictHostKeyChecking=no firmware-upgrade-L3 $LOGIN@$ip:/tmp/firmware-upgrade
		[ -n "$FARM_HASH" ] && echo "$FARM_HASH" > FARM_HASH && sshpass -p$PASS scp -P 22 -oConnectTimeout=15 -oStrictHostKeyChecking=no FARM_HASH $LOGIN@$ip:/config/FARM_HASH
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
		[[ ! -z $worker ]] && sed -i "s/^$ip.*$worker$/\#$ip $worker/g" ips.txt
	fi

done
