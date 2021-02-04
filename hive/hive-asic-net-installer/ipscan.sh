#!/usr/bin/env bash


#
# Copyright (C) 2017  Hiveon Holding LTD
# Distributed under Business Source License 1.1
# License information can be found in the LICENSE.txt file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE.txt
#
# Linted by shellcheck 0.7.0
#


readonly script_mission='Client for ASICs: Network ASIC scanner (Antminers only)'
readonly script_version='1.3.0'
readonly script_basename="${0##*/}"


# !!! bash strict mode, no unbound variables
set -o nounset # commented out for production bc still not tested thoroughly


# functions

function echo_error {
	echo -e "${BRED-}${*}${NOCOLOR-}"
} 1>&2

function print_script_version {
	echo -e "${YELLOW-}${script_mission}, version ${script_version}${NOCOLOR-}"
	echo
} 1>&2

function print_script_usage {
	echo -e "Usage ${CYAN-}$script_basename network/prefix [network/prefix...]${NOCOLOR-}"
	echo
	echo -e "      ${CYAN-}$script_basename${NOCOLOR-} 192.168.0.0/24"
	echo -e "      ${CYAN-}$script_basename${NOCOLOR-} 192.168.0.0/24 192.168.100.0/24"
	echo -e "      ${CYAN-}$script_basename${NOCOLOR-} 172.16.1.0/16 192.168.1.0/24 10.0.1.0/24"
	echo -e "      ${CYAN-}$script_basename${NOCOLOR-} 192.168.0.0/24 > ips.txt"
	echo
} 1>&2

is_on_busybox() {
	# vars
	local canonical_path

	# code
	canonical_path="$( readlink -f "$( command -v timeout )" )" && [[ "$canonical_path" == *'/busybox'* ]] #" syntax highlighting fix
}

function are_programs_available {
	# args
	#local -r program_list="$@"

	# flags
	local -i something_is_not_available_FLAG=0

	# vars
	local this_program

	# code
	for this_program in "$@"; do
		if ! hash "$this_program" 2> /dev/null; then
			something_is_not_available_FLAG=1
			break
		fi
	done

	return $(( something_is_not_available_FLAG ))
}

function trim_string {
	# args
	local -r string_to_trim="$1"

	# vars
	local trimmed_string

	# code
	shopt -s extglob
	trimmed_string="${string_to_trim##+([[:space:]])}" # trim leading
	trimmed_string="${trimmed_string%%+([[:space:]])}" # trim trailing
	echo "$trimmed_string"
}

function prefix_to_bit_netmask {
	# args
	local -r prefix="$1"

	# vars
	local bitmask='' space
	local -i this_bit num

	# code
	for (( this_bit = 0; this_bit < 32; this_bit++ )); do
		(( this_bit < prefix )) && num=1		|| num=0
		(( this_bit % 8 == 0 )) && space=' '	|| space=''
		bitmask="${bitmask}${space}${num}"
	done
	trim_string "$bitmask"
}

function bit_netmask_to_wildcard_netmask {
	# args
	local -r bitmask="$1"

	# vars
	local this_octet wildcard_mask=''

	# code
	for this_octet in $bitmask; do
		wildcard_mask="${wildcard_mask} $(( 255 - 2#$this_octet ))"
	done
	trim_string "$wildcard_mask"
}

function is_valid_cidr {
	# args
	local -r cidr_to_validate="$1"

	# const
	local -r valid_ip_range_RE='^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/([0-9]{1,2})$'

	# vars
	local -i ip ip1 ip2 ip3 ip4 N

	# code
	if [[ "$cidr_to_validate" =~ $valid_ip_range_RE ]]; then
		ip1="${BASH_REMATCH[1]}"
		ip2="${BASH_REMATCH[2]}"
		ip3="${BASH_REMATCH[3]}"
		ip4="${BASH_REMATCH[4]}"
		N="${BASH_REMATCH[5]}"
		(( ip = ip1 * 256 ** 3 + ip2 * 256 ** 2 + ip3 * 256 + ip4 ))
		if (( ip % 2**(32-N) != 0 )); then
			echo_error "'$cidr_to_validate' is not a valid IP range (address or netmask part is wrong by means of the address arithmetic)"
			return 1
		fi
	else
		echo_error "'$cidr_to_validate' is not a valid IP range"
		return 1
	fi
}

function get_asic_model {
	# args
	local -r asic_ip="$1"

	# vars
	local timeout_options

	# code
	if is_on_busybox; then
		timeout_options='-t 7'
	else
		timeout_options='7'
	fi

	echo '{"command":"stats"}' | timeout $timeout_options nc "$asic_ip" 4028 | tr -d '\0\n' | sed 's/}{/\},{/' | jq --raw-output '.STATS[0].Type'
}

function process_ip_ranges {
	# vars
	local this_ip_range net_part prefix_part bit_netmask wildcard_mask str range ip_list_for_eval ip_list_for_display this_ip
	local -i this_octet mask_octet

	# code
	for this_ip_range in "$@"; do
		# assert: ip address range is valid
		is_valid_cidr "$this_ip_range" || continue

		net_part="${this_ip_range%/*}"
		prefix_part="${this_ip_range#*/}"

		bit_netmask="$( prefix_to_bit_netmask "$prefix_part" )"
		wildcard_mask="$( bit_netmask_to_wildcard_netmask "$bit_netmask" )"

		# debug
		#echo "this_ip_range '$this_ip_range', net_part '$net_part', prefix_part '$prefix_part', bit_netmask '$bit_netmask', wildcard_mask '$wildcard_mask'"

		str=''

		for (( this_octet = 1; this_octet <= 4; this_octet++ )); do
			range="$( cut -d '.' -f "$this_octet" <<< "$net_part" )"
			mask_octet="$( cut -d ' ' -f "$this_octet" <<< "$wildcard_mask" )"
			if (( mask_octet > 0 )); then
				range="{0..$mask_octet}"
			fi
			str="$str $range"
		done

		: "$( trim_string "$str" )"
		ip_list_for_eval="${_// /.}"

		: "${ip_list_for_eval//{/[}"
		: "${_//\}/]}"
		: "${_//../-}"
		ip_list_for_display="$_"

		message="Scanning range ${WHITE}${ip_list_for_display}${NOCOLOR}"

		for this_ip in $( eval echo "$ip_list_for_eval" ); do # eval is to expand "{n..m}" template(s)
			echo -e -n "\r${message}: $this_ip" 1>&2
			# --verbose and --silent options at the same time does make a verbose output (we need that) but hides curl errors (we don't need them)
			curl --verbose --silent --max-time 5 "$this_ip:80" 2>&1 | grep -Fq 'Miner Configuration' && touch "/dev/shm/ip/$this_ip" & # let's parallelize!
			{ sleep 0.1 || usleep 100000; } 2> /dev/null # only integer sleep on BusyBox
		done

		echo -e -n "\r${message} done. Processing answers..." 1>&2
		wait
	done
}

function print_antminers_found {
	# arrays
	local -a antminer_ip_list_ARR=() antminer_model_list_ARR=()

	# vars
	local this_antminer_ip this_antminer_model
	local -i antminers_found this_element

	# code
	# shellcheck disable=SC2012
	# bc there's a problem with only-filenames-find-from-busybox
	readarray -t antminer_ip_list_ARR < <( ls /dev/shm/ip/ | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 )
	antminers_found="${#antminer_ip_list_ARR[@]}"

	if (( antminers_found )); then
		{
			echo
			echo "Antminers found: $antminers_found"
			echo
			printf '%-15.15s %s\n' 'IP address' 'Model'
			for (( this_element = 0; this_element < antminers_found; this_element++ )); do
				this_antminer_ip="${antminer_ip_list_ARR[this_element]-}"
				[[ -z "$this_antminer_ip" ]] && continue # out of boundaries check
				if are_programs_available 'timeout' 'nc' 'jq'; then
					this_antminer_model="$( get_asic_model "$this_antminer_ip" 2>&1 )"
					antminer_model_list_ARR[this_element]="$this_antminer_model"
				else
					this_antminer_model="${DGRAY-}<detection skipped>${NOCOLOR-}"
				fi
				printf '%-15.15s %b\n' "$this_antminer_ip" "$this_antminer_model"
			done
			echo
		} 1>&2
		if [[ ! -t 1 ]]; then # print this only if stdout redirected
			printf '#\n# %s: range(s) %s scanned at %(%F %T)T, %d Antminers found\n#\n' "$script_basename" "$*" -1 "$antminers_found"
			for (( this_element = 0; this_element < antminers_found; this_element++ )); do
				this_antminer_ip="${antminer_ip_list_ARR[this_element]-}"
				this_antminer_model="${antminer_model_list_ARR[this_element]-}"
				[[ -z "$this_antminer_ip" ]] && continue # out of boundaries check
				printf '# %s\n%s\n' "$this_antminer_model" "$this_antminer_ip"
			done
		fi
	else
		{
			echo
			echo 'No Antminers found'
			echo
		} 1>&2
	fi
}


# sources

source /hive/bin/colors


# code

print_script_version

# assert: at least 1 argument does exist
[[ -n "${1-}" ]] || { print_script_usage; exit 1; }
# assert: curl is available
are_programs_available 'curl' || { echo -e "${CYAN-}curl${NOCOLOR-} is required, try ${CYAN-}apt-get install curl${NOCOLOR-}"; exit 1; }
# cleanup at exit or break
trap 'rm -rf /dev/shm/ip; exit' EXIT INT HUP

# create a directory in the shared memory
mkdir -p /dev/shm/ip
rm -rf /dev/shm/ip/*

# let's go!
process_ip_ranges "$@"
print_antminers_found "$@"
