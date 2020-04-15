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

cd `dirname $0`

which jq > /dev/null || ( echo -e "${RED}jq${NOCOLOR} is required, try apt-get install jq" && exit 1 )

IPS=`cat ips.txt | grep -v '#' | grep -v '^$'`
[[ -z $IPS ]] && echo -e "${YELLOW}No IPs in the list${NOCOLOR}" && exit 1

. config.txt

echo -e "IPs count `echo "$IPS" | wc -l`"
echo > ./$1.txt

for ip in $IPS; do
    [ -z "$ip" ] && echo "Empty line on ips.txt" && continue
    echo
    echo -e "> Processing ${CYAN}$ip${NOCOLOR}"

    if is_on_busybox; then
        timeout_options='-t 7'
    else
        timeout_options='7'
    fi

    model=`echo '{"command":"stats"}' | timeout $timeout_options nc $ip 4028 | tr -d '\0\n' | sed 's/}{/\},{/' | jq -r .STATS[0].Type`
    
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
