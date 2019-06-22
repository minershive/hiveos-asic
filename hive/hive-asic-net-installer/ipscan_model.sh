#!/usr/bin/env bash


cd `dirname $0`

which jq > /dev/null || (echo -e "${RED}jq${NOCOLOR} is required, try apt-get install jq" && exit 1

IPS=`cat ips.txt | grep -v '#' | grep -v '^$'`
[[ -z $IPS ]] && echo -e "${YELLOW}No IPs in the list${NOCOLOR}" && exit 1

. config.txt

echo -e "IPs count `echo "$IPS" | wc -l`"
echo > ./$1.txt

for ip in $IPS; do
    echo
    echo -e "> Processing ${CYAN}$ip${NOCOLOR}"
    model=`echo '{"command":"stats"}' | timeout 7 nc $ip 4028 | tr -d '\0\n' | sed 's/}{/\},{/' | jq -r .STATS[0].Type`
    echo "$ip $model"
        if [[ $model == "Antminer $1" ]]; then
            echo "$ip $model ADD"
            echo "$ip" >> ./$1.txt
    fi
    if [[ $? -ne 0 ]]; then
        echo -e "${YELLOW}Error connecting${NOCOLOR}"
    else
        echo -e "${GREEN}OK${NOCOLOR}"
    fi

done
