#!/hive/sbin/bash


#
# Copyright (C) 2016-2020  Hiveon
# Distributed under GNU GENERAL PUBLIC LICENSE 2.0
# License information can be found in the LICENSE file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE.txt
#


declare -r ant_functions_lib_mission='Antminer and Custom FW functions'
declare -r ant_functions_lib_version='0.1.20'


# !!! bash strict mode, no unbound variables
#set -o nounset # !!! this is a library, so we don't want to break the other's scripts


#
# functions: script infrastructure
#

#base
function print_script_version {
	echo -e "${YELLOW-}${script_mission}, version ${script_version}${NOCOLOR-}"
	echo
}

function errcho {
	#
	# Usage: errcho [arg...]
	#
	# uniform error logging to stderr
	#

	echo -e -n "${BRED-}$0"
	for (( i=${#FUNCNAME[@]} - 2; i >= 1; i-- )); { echo -e -n "${RED-}:${BRED-}${FUNCNAME[i]}"; }
	echo -e " error:${NOCOLOR-} $*"

} 1>&2

#
# functions: audit
#
# we need to audit externally--does the script work as intended or not (like the system returns exitcode "file not found")
# [[ $( script_to_audit ) != 'I AM FINE' ]] && echo "Something wrong with $script_to_check"
#

function print_i_am_doing_fine_then_exit {
	#
	# Usage: print_i_am_fine_and_exit
	#

	# code

	echo "$__audit_ok_string"
	exit $(( exitcode_OK ))
}

#base
function is_function_exist {
	#
	# Usage: is_function_exist 'function_name'
	#
	# stdin: none
	# stdout: none
	# exit code: boolean
	#

	# args

	(( $# != 1 )) && { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r function_name="$1"

	# code

	declare -F -- "$function_name" >/dev/null
}

#base
function __list_functions {
	#
	# List all functions but started with '_'
	#

	# consts

	local -r private_function_attribute_RE='^_'

	# vars

	local function_name=''
	local -a all_functions=()
	local -a private_functions=()
	local -a public_functions=()

	# code

	all_functions=( $( compgen -A function ) )

	for function_name in "${all_functions[@]}"; do
		if [[ "${function_name}" =~ $private_function_attribute_RE ]]; then
			private_functions+=("$function_name")
		else
			public_functions+=("$function_name")
		fi
	done

	if (( ${#private_functions[@]} != 0 )); then
		echo "${#private_functions[@]} private function(s):"
		echo
		printf '%s\n' "${private_functions[@]}"
		echo
	fi

	echo "${#public_functions[@]} public function(s):"
	echo
	printf '%s\n' "${public_functions[@]}"
	echo
}


#ant functions

function is_custom_fw_signed {

	# consts

	local -r upgrade_script='/www/pages/cgi-bin/upgrade.cgi'
	local -r uncommented_openssl_RE='^[[:space:]]*openssl'

	# vars

	local -i is_certs_exist=0
	local first_match

	# code

	for first_match in /etc/*.pem; do
		[[ -s "$first_match" ]] && is_certs_exist=1
		break
	done

	(( is_certs_exist )) && [[ -s "$upgrade_script" ]] && grep -Eqe "$uncommented_openssl_RE" -- "$upgrade_script"
}

#get status
function hiveon_status {
	#
	# Usage: hiveon_status 'ERR_NO_STATS'
	# Usage: hiveon_status '{JSON}'
	# Usage: hiveon_status <<< '{JSON}'
	#
	(( $# <= 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r input_text="${1:-$( < /dev/stdin )}" # get from arg or stdin

	# vars
	local -i tune_board=0 tune_chip=0
	local system_status

	# consts
	local -r series_17_RE='^Antminer [STX]17'

	# code
	if [[ -n "$input_text" && "$input_text" != 'ERR_NO_STATS' ]]; then
		system_status="$( jq --raw-output '.[0].Type' <<< "$input_text" )"
		system_status="${system_status/(S9 6-boards)}" # remove '(S9 6-boards)'
		# should we remove space too ' (S9 6-boards)'
		#                             ^ ???

		if [[ -n "$system_status" ]]; then
			if [[ "$system_status" =~ \(([^()]*)\)[^\(\)]*$ ]]; then # anything inside the last pair of brackets
				system_status="${BASH_REMATCH[1]}"
			else
				system_status='mining'
			fi
		fi

		# previous variant of a '(S9 6-boards)' processing
		#if [[ -n "$system_status" ]]; then
		#	if grep -v 'S9 6-boards' <<< "$system_status" | grep -Fq '('; then #)'# syntax highlighting fix
		#		system_status="$( echo "$system_status" | grep '(' | sed 's/.*(\|).*//g' )"
		#	else
		#		system_status='mining'
		#	fi
		#fi
	else
		system_status='ERR_NO_STATS'
	fi

	#Hiveon before 17 series
	if (( IS_ASIC_CUSTOM_FW )) && [[ ( ! "$ASIC_MODEL" =~ $series_17_RE ) && ( "$system_status" == 'mining' || "$system_status" == 'ERR_NO_STATS' ) ]]; then
		if [[ -s /www/pages/cgi-bin/check-auto-tune-running.cgi ]]; then
			tune_board="$( sh /www/pages/cgi-bin/check-auto-tune-running.cgi )"
		fi
		if [[ -s /www/pages/cgi-bin/check-auto-chip-tune-running.cgi ]]; then
			tune_chip="$( sh /www/pages/cgi-bin/check-auto-chip-tune-running.cgi )"
		fi

		#L3 without check-auto-tune-running.cgi
		if [[ $ASIC_MODEL =~ 'Antminer L3' ]]; then
			if ps w | grep -q '[a]uto-tune'; then
				tune_board=1
			else
				tune_board=0
			fi
		fi

		if (( tune_board || tune_chip )); then
			system_status='tuning'
		fi
	fi

	[[ "$system_status" == 'ERR_NO_STATS' ]] && system_status='NA'

	echo "$system_status"
}

#get voltage
function hiveon_voltage {
	#
	# Usage: hiveon_voltage '[...,0,0,X,X,X,0,...]'
	# Example acn=[0,0,0,0,0,63,63,63,0,0,0,0,0,0,0,0]
	#
	# If the API does not return voltage, get it from the advanced config
	#

	(( $# > 1 )) && { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r input_text="${1:-$( < /dev/stdin )}" # get from arg or stdin

	# vars
	local -a voltage_mask_array voltage_mask_only_non_zeroes_array voltage_list_array
	local -i voltage_mask_chain_count voltage_list_chain_count
	local -i this_chain voltage_list_iterator=0 voltage_list_index=0
	local this_chain_voltage IFS voltages_from_adv_config

	# code
	if (( IS_ASIC_CUSTOM_FW )) && [[ -s /www/pages/cgi-bin/get_adv_config.cgi ]]; then
		# '[0,0,0,0,0,63,63,63,0,0,0,0,0,0,0,0]' -> '0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0' -> ( 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0 )
		voltage_mask_array=( $( jq '. | to_entries | .[].value | if . > 0 then 1 else 0 end' <<< "$input_text" ) )
		# ( 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0 ) -> ( 1,1,1 )
		voltage_mask_only_non_zeroes_array=( ${voltage_mask_array[@]//0} )
		voltage_mask_chain_count="${#voltage_mask_only_non_zeroes_array[@]}"
		if (( voltage_mask_chain_count )); then
			#
			# sh /www/pages/cgi-bin/get_adv_config.cgi output:
			#bitmain-voltage1=820
			#bitmain-voltage2=820
			#bitmain-voltage3=840
			voltages_from_adv_config="$( sh /www/pages/cgi-bin/get_adv_config.cgi | awk -F '=' '/bitmain-voltage[0-9]+/{print $2/100}' )"
			#
			if [[ -n "$voltages_from_adv_config" ]]; then
				voltage_list_array=( $voltages_from_adv_config )
				voltage_list_chain_count="${#voltage_list_array[@]}"
				for (( this_chain=0; this_chain < ${#voltage_mask_array[@]}; this_chain++ )); do
					# voltage_mask_array=( 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0 )
					# voltage_list_array=( 8.20 8.20 8.40 )
					if [[ "${voltage_mask_array[this_chain]}" != '0' ]]; then
						this_chain_voltage="${voltage_list_array[voltage_list_index]:-0}" # covering edge case: if voltage_list_array length < number of voltage_mask_array's entries that are > 0
						voltage_mask_array[this_chain]="$this_chain_voltage"
						(( voltage_list_iterator++ ))

						# too smart
						#if (( (voltage_mask_chain_count == voltage_list_chain_count) || (voltage_mask_chain_count % voltage_list_chain_count != 0) )); then
						# let's keep it simple
						if (( voltage_mask_chain_count != 9 )); then
							# simply progress the index
							(( voltage_list_index++ ))
						else
							# !!! experimental
							# especially for T9 with the virtual chains (3 physical -> 9 virtual):
							#
							# visual chart:
							#
							# voltage_list_array        ( 8.2, 8.2, 8.4 ) #3
							# voltage_mask_array        ( 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0 ) #3
							# voltage_list_iterator                 0 1 2
							# voltage_list_index                    0 1 2
							# voltage_list_iterator % (3/3)         0 0 0
							#
							# voltage_list_array        ( 8.2, 8.2, 8.4 ) #3
							# voltage_mask_array        ( 0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0 ) #9
							# voltage_list_iterator           0 1 2 3 4 5 6 7 8
							# voltage_list_index              0 0 0 1 1 1 2 2 2
							# voltage_list_iterator % (9/3)   0 1 2 0 1 2 0 1 2
							#
							(( quotient = voltage_mask_chain_count / voltage_list_chain_count ))
							(( quotient = quotient < 1 ? 1 : quotient ))
							(( voltage_list_iterator % quotient == 0 ? voltage_list_index++ : skip ))
						fi
					fi
				done
			else
				# it seems that we have no (or empty) /config/config.conf
				errcho 'No voltages found in the output of /www/pages/cgi-bin/get_adv_config.cgi. Please check /config/config.conf'
				voltage_mask_array=()
			fi
		else
			errcho 'Voltage mask has no non-zero entries'
			voltage_mask_array=()
		fi
	elif (( IS_ASIC_CUSTOM_FW )); then
		errcho "/www/pages/cgi-bin/get_adv_config.cgi not found or empty. Seems like your $ASIC_CUSTOM_FW_BRAND $ASIC_CUSTOM_FW_VERSION is broken."
	fi

	IFS=','
	echo "[${voltage_mask_array[*]}]"
}

#get power chain id
function hiveon_power {
	#
	# Usage: hiveon_power '{"chain_power1": 982, "chain_power3": 1001}' '[...,0,0,X,X,X,0,...]'
	#

	(( $# > 2 )) && { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
#	local -r input_text="${1:-$( < /dev/stdin )}" # get from arg or stdin
	local -r power="${1-}"
	local -r acn="${2-}"

	# vars
	local -a power_mask
	local -i this_chain
	local this_chain_power IFS

	# code
	power_mask=( $( jq '. | to_entries | .[].value | if . > 0 then 1 else 0 end' <<< "$acn" ) )

	for (( this_chain=0; this_chain < ${#power_mask[@]}; this_chain++ )); do
		if (( power_mask[this_chain] )); then
			this_chain_power="$( jq ".chain_power$(( this_chain + 1 ))" <<< "$power" )" #"#
			[[ "$this_chain_power" == 'null' ]] && this_chain_power=0
			power_mask[this_chain]="$this_chain_power"
		fi
	done

	IFS=','
	echo "[${power_mask[*]}]"
}


function hiveon_default_config {
	#
	# Usage: hiveon_default_config
	#
	# reset hiveon config to default

	if [[ -f /etc/config.conf.e ]]; then
		cp -rf /etc/config.conf.e /config/config.conf
		message info 'Firmware config reset to default'
		send_custom_fw_config_to_server
		miner restart
	fi
}


#send hiveon config
function send_custom_fw_config_to_server {
	#
	# Usage: send_custom_fw_config_to_server
	#
	# send hiveon config to API server

	# vars
	local request hiveon_config

	# code
	if [[ ! -s "$RIG_CONF" ]]; then
		echo "Cannot send $ASIC_CUSTOM_FW_BRAND config to API server, '$RIG_CONF' not found"
		exit 0
	fi

	source "$RIG_CONF"

	if [[ -z "$RIG_ID" ]]; then
		echo "Cannot send $ASIC_CUSTOM_FW_BRAND config to API server, RIG_ID is empty"
		exit 0
	fi

	hiveon_config="$( tr -d $'\r' < /config/config.conf |
		jq --raw-input --raw-output --null-input --compact-output 'inputs | match("(.*)=(.*)") | .captures | {(.[0].string): (.[1].string)}' |
			jq --slurp add
	)"

	request="$( jq --null-input --compact-output \
		--arg rig_id "$RIG_ID" \
		--arg passwd "$RIG_PASSWD" \
		--argjson hiveon_config "$hiveon_config" \
		'{
			"method": "set_asic_config", "jsonrpc": "2.0", "id": 0,
			"params": {
				$rig_id, $passwd,
				"config": $hiveon_config
			}
		}'
	)"
	echo -n 'Request: '
	jq --compact-output '.' <<< "$request"

#duplicate code from agent
	HIVE_URL="$HIVE_HOST_URL"
	HIVE_URL_collection[0]="$HIVE_URL" # zeroth index for original HIVE_HOST_URL
	# !!! duct tape
	# protection measures -- we might don't have https on the vast majority of ASICs
	if [[ "$HIVE_URL" =~ ^https:// ]]; then
		echo "API server $HIVE_URL is not supported, most likely"
		HIVE_URL_collection[1]="${HIVE_URL/https:\/\//http:\/\/}" # and 2nd place for a http form of https'ed HIVE_HOST_URL
#		if (( https_disabled_message_sent == 0 )); then
#			cp "$RIG_CONF" "${RIG_CONF}.original"
#			sed -i 's|HIVE_HOST_URL="https://|HIVE_HOST_URL="http://|' "$RIG_CONF"
#			echo "Server URL with HTTPS might not be supported on this ASIC. It's recommended to switch to HTTP (Settings->Mirror select)"
#			mv "${RIG_CONF}.original" "$RIG_CONF"
#			https_disabled_message_sent=1
#		fi
	fi

	for this_URL in "${HIVE_URL_collection[@]}"; do
		this_URL="${this_URL%/}" # cut the trailing slash, if any (like as in rocketchain's local API server URL)
		echo "Sending config to $this_URL..."
		response="$( jq --compact-output '.' <<< "$request" |
			curl --insecure --location --data @- --silent \
			--connect-timeout 15 --max-time 25  \
			--request POST "$this_URL/worker/api?id_rig=$RIG_ID&method=set_asic_config" \
			--header 'Content-Type: application/json'
		)"
		curl_exitcode=$?
		if [[ -n "$response" ]]; then
			echo -n 'Response: '
			jq --compact-output --color-output '.' <<< "$response"
			response_message="$( jq --raw-output '.message' <<< "$response" )"
			case "$response_message" in
				'Not a Hiveon ASIC')
					echo "Firmware config sending error: Not a $ASIC_CUSTOM_FW_BRAND ASIC"
					message error "Not a $ASIC_CUSTOM_FW_BRAND firmware (cannot send firmware config)" --silent
				;;
				'Wrong password')
					echo "Firmware config sending error: invalid password"
					message error 'Firmware config sending error' --payload --silent <<< "Invalid password: API server $this_URL does not validate password '$RIG_PASSWD'"
				;;
				'Invalid method')
					echo "Firmware config sending error: server does not support 'set_asic_config' method"
					message error 'Firmware config sending error' --payload --silent <<< "Invalid method: API server $this_URL does not support 'set_asic_config' method"
				;;
				'null'|'')
					# all is ok
				;;
				*)
					echo "Firmware config sending error? Unknown response '$response_message'"
				;;
			esac
		fi

		if (( curl_exitcode )); then
			echo "Error sending config (curl error $curl_exitcode), trying next URL..."
		else
			break
		fi
	done

	if (( ! curl_exitcode )) && [[ -z "$response_message" || "$response_message" == 'null' ]]; then
		echo "Firmware config sent to server"
		message info 'Firmware config sent to server' --silent
	fi
}


# sources

source asic-model || echo 'ERROR: /hive/bin/asic-model not found'


# consts

declare -r __audit_ok_string='I AM DOING FINE'
# shellcheck disable=SC2034
declare -r -i exitcode_OK=0
declare -r -i exitcode_ERROR_NOT_FOUND=1
declare -r -i exitcode_ERROR_IN_ARGUMENTS=127
# shellcheck disable=SC2034
declare -r -i exitcode_ERROR_SOMETHING_WEIRD=255

declare -r -i exitcode_IS_EQUAL=0
declare -r -i exitcode_GREATER_THAN=1
declare -r -i exitcode_LESS_THAN=2
declare -r RIG_CONF='/hive-config/rig.conf'
declare -a HIVE_URL_collection=( # indices 0 and 1 are reserved for HIVE_HOST_URL from RIG_CONF
	[2]='http://api.hiveos.farm'
	[3]='http://paris.hiveos.farm'
	[4]='http://amster.hiveos.farm'
	[5]='http://helsinki.hiveos.farm'
	[6]='http://msk.hiveos.farm'
	[7]='http://ca1.hiveos.farm'
)
declare -i https_disabled_message_sent=0


# main

if ! ( return 0 2>/dev/null ); then # not sourced

	declare -r script_mission="$ant_functions_lib_mission"
	declare -r script_version="$ant_functions_lib_version"

	case "$*" in
		'')
			source colors
			print_script_version
			__list_functions
			;;
		*)
			if is_function_exist "$1"; then
				"$@" # potentially unsafe
			else
				errcho "function '$1' is not defined"
			fi
			;;
	esac
fi
