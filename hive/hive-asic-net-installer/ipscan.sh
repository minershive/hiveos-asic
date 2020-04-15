#!/usr/bin/env bash


#
# Copyright (C) 2016-2020  Hiveon
# Distributed under GNU GENERAL PUBLIC LICENSE 2.0
# License information can be found in the LICENSE file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE
#


readonly script_mission='Client for ASICs: Network ASIC scanner'
readonly script_version='1.2.0'


# consts

. colors


# functions

print_script_version() {
	echo -e "${YELLOW-}${script_mission}, version ${script_version}${NOCOLOR-}"
	echo
} 1>&2

print_script_usage() {
	bname="$( basename "$0" )"
	echo -e "Usage ${CYAN-}$bname network/prefix [network/prefix...]${NOCOLOR-}"
	echo
	echo -e "      ${CYAN-}$bname${NOCOLOR-} 192.168.0.0/24"
	echo -e "      ${CYAN-}$bname${NOCOLOR-} 192.168.0.0/24 192.168.100.0/24"
	echo -e "      ${CYAN-}$bname${NOCOLOR-} 172.16.1.0/16 192.168.1.0/24 10.0.1.0/24"
	echo -e "      ${CYAN-}$bname${NOCOLOR-} 192.168.0.0/24 > ips.txt"
	echo
}

prefix_to_bit_netmask() {
	prefix="$1"
	shift=$(( 32 - prefix ))

	bitmask=''
	for (( i = 0; i < 32; i++ )); do
		if (( i < prefix )); then
			num=1
		else
			num=0
		fi

		if (( i % 8 == 0 )); then
			space=' '
		else
			space=''
		fi

		bitmask="${bitmask}${space}${num}"
	done
	echo $bitmask # !!! do not double-quote, there's leading space trimming
}

bit_netmask_to_wildcard_netmask() {
	bitmask="$1"
	wildcard_mask=
	for octet in $bitmask; do
		wildcard_mask="${wildcard_mask} $(( 255 - 2#$octet ))"
	done
	echo $wildcard_mask # !!! do not double-quote, there's leading space trimming
}


# code

print_script_version

[[ -z "$1" ]] && { print_script_usage; exit 1; }
which curl > /dev/null || { echo -e "${CYAN-}curl${NOCOLOR-} is required, try ${CYAN-}apt-get install curl${NOCOLOR-}"; exit 1; }

trap 'rm -rf /dev/shm/ip; exit' EXIT INT HUP
mkdir -p /dev/shm/ip
rm -rf /dev/shm/ip/*

for ip_range in "$@"; do
	net="$( echo "$ip_range" | cut -d '/' -f 1 )"
	prefix="$( echo "$ip_range" | cut -d '/' -f 2 )"

	bit_netmask="$( prefix_to_bit_netmask "$prefix" )"
	wildcard_mask="$( bit_netmask_to_wildcard_netmask "$bit_netmask" )"

	str=

	for (( idx = 1; idx <= 4; idx++ )); do
		range="$( echo "$net" | cut -d '.' -f "$idx" )"
		mask_octet="$( echo "$wildcard_mask" | cut -d ' ' -f "$idx" )"
		if (( mask_octet > 0 )); then
			range="{0..$mask_octet}"
		fi
		str="${str} $range"
	done

	ips="$( echo $str | sed 's, ,\.,g' )" ## replace spaces with periods, a join... !!! do not double-quote $str (there's leading space trimming)

	message="Scanning range ${WHITE}${ips}${NOCOLOR}"

	for ip in $( eval echo "$ips" ); do
		echo -e -n "\r${message}: $ip" 1>&2
		# -verbose and --silent options at the same time make verbose output (we need that) but hides curl errors (we don't need them)
		curl -v -s -m 5 "$ip:80" 2>&1 | grep -Fqs 'Miner Configuration' && touch "/dev/shm/ip/$ip" &
		{ sleep 0.1 || usleep 100000; } 2> /dev/null # only integer sleep on BusyBox
	done
	echo -e -n "\r${message}. Processing..." 1>&2
	wait
done

antminers_found="$( ls -1 /dev/shm/ip/ | wc -l )"

if (( antminers_found != 0 )); then
	{
		echo
		echo
		echo 'Antminers found:'
		echo
	} 2>&1
	ls -1 /dev/shm/ip/ | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
else
	{
		echo
		echo
		echo 'Antminers not found.'
	} 2>&1
fi

{
	echo
} 2>&1
