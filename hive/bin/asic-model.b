#!/hive/sbin/bash


#
# Copyright (C) 2016-2020  Hiveon
# Distributed under GNU GENERAL PUBLIC LICENSE 2.0
# License information can be found in the LICENSE file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE.txt
#
# Linted by shellcheck 0.3.7
#


library_mission='Client for ASICs: Print ASIC model and set necessary constants' # also sourced from everywhere
library_version='1.4.3'
library_basename="${0##*/}"


# !!! bash strict mode, no unbound variables
#set -o nounset # !!! this script being sourced constantly, so turning this off for a while -- we don't want to break the other not-yet-refactored scripts


# functions

assign_ASIC_MANUFACTURER_and_ASIC_MODEL_constants () {
	#
	# !!! shall be sh-friendly
	# !!! copied from 'selfupgrade' script, PLEASE KEEP IT IN SYNC
	#

	# code
	ASIC_MODEL='<unknown>'			# global var
	ASIC_MANUFACTURER='<unknown>'	# global var
	ASIC_FW_VERSION='<unknown>'		# global var

	# Bitmain Antminer
	if [ -s /usr/bin/compile_time ]; then
		ASIC_MANUFACTURER='Bitmain'
		ASIC_MODEL="$( sed -n '2p' /usr/bin/compile_time )"
		# shellcheck disable=SC2034
		ASIC_FW_VERSION="$( sed -n '1p' /usr/bin/compile_time )"
		case "$ASIC_MODEL" in
			'Blackminer F1'*)
				ASIC_MANUFACTURER='HashAltCoin'
			;;
		esac
	fi

	# Ebang Ebit
	if [ -f /opt/system/bank.conf ]; then
		ASIC_MANUFACTURER='Ebang'
		ASIC_MODEL='ebit'
	fi

	# Innosilicon
	if [ -s /etc/hwrevision ]; then
		ASIC_MANUFACTURER='Innosilicon'
		ASIC_MODEL="$( cut -d' ' -f 2 /etc/hwrevision )"
		if uname -a | grep -q dragonMint; then
			ASIC_MANUFACTURER='DragonMint'
		fi
	elif [ -s /tmp/type ]; then
		# Innosilicon A5/8
		ASIC_MANUFACTURER='Innosilicon'
		ASIC_MODEL="$( cat /tmp/type ).$( cat /tmp/hwver )"
	fi
	# TODO for refactor: place hwrevision to ASIC_HWREVISION and then place a human-friendly name to ASIC_MODEL='T2Thf' ??? way too much work...

	# Dayun Zig
	if [ -s /var/www/html/src/Template/Layout/signin.twig ]; then
		ASIC_MANUFACTURER='Dayun'
		# Zig old firmware
		ASIC_MODEL="$(
			{
				grep -Fs -e 'Zig' /var/www/html/src/Template/Layout/signin.twig ||
				grep -Fs -e 'Zig' /var/www/html/src/Template/Users/login.twig
			} |
				grep -Es -e 'title|<a><b>' | sed 's/<[^>]*>//g; s/^ *//g; s/ *$//g'
		)"
		# Zig new firmware
		if [ -s /var/www/html/TYPE ]; then
			# shellcheck disable=SC2001
			# bc might think about it later
			ASIC_MODEL="$( echo "$ASIC_MODEL" | sed "s/{{ type() }}/$( cat /var/www/html/TYPE )/" )" #"# syntax highliting fix
		fi
	fi

	# Todek Toddminer C1 / C1 PRO
	if [ -x /home/sm/miner/build/cpuminer ] && [ -e /flask/setHashinJson ]; then
		# shellcheck disable=SC2034
		ASIC_MANUFACTURER='Todek'
		ASIC_MODEL='Toddminer C1'
		if /home/sm/miner/build/cpuminer -V | head -1 | grep -Fq 'pro'; then
			ASIC_MODEL="$ASIC_MODEL PRO"
		fi
	fi
}

assign_ASIC_CUSTOM_FW_constants () {
	#
	# !!! shall be sh-friendly
	# !!! copied from 'selfupgrade' script, PLEASE KEEP IT IN SYNC
	#

	# consts
	local ASIC_CUSTOM_FW_BRAND_default='Hiveon'
	
	# global vars, defaults
	ASIC_CUSTOM_FW_VERSION=''								# default: '', no custom fw
	ASIC_CUSTOM_FW_VERSION_RAW=''							# default: '', no custom fw
	ASIC_CUSTOM_FW_VERSION_DATE=''							# default: '', no custom fw
	ASIC_CUSTOM_FW_VERSION_MAJOR=-1							# default: -1, no custom fw
	ASIC_CUSTOM_FW_VERSION_MINOR=-1							# default: -1, no custom fw
	ASIC_CUSTOM_FW_BRAND="$ASIC_CUSTOM_FW_BRAND_default"	# default: 'Hiveon', if not redefined in /usr/bin/compile_ver
	ASIC_CUSTOM_FW_BUID=''									# default: '', no custom fw
	ASIC_CUSTOM_FW_PUID=''									# default: '', no custom fw
	IS_ASIC_CUSTOM_FW=0										# default: 0, no custom fw

	# vars
	local ASIC_CUSTOM_FW_description_file_content

	# code
	if [ -s "$ASIC_CUSTOM_FW_description_file" ]; then
		IS_ASIC_CUSTOM_FW=1
		#
		# A sample content of /usr/bin/compile_ver:
		#
		# Tue Nov 20 10:12:30 UTC 2019
		# Antminer S9 Hiveon
		# 1.02@191120
		# Bigminer
		# 333956ed-4bda-4f7f-9d29-097f8d68e686
		# 62e3f4ad-15f4-432e-aebd-6ce164354f81
		# <EOF>
		#
		ASIC_CUSTOM_FW_description_file_content="$( cat "$ASIC_CUSTOM_FW_description_file" )"

		# let's parse it to a global variables
		ASIC_CUSTOM_FW_VERSION_RAW="$( echo "$ASIC_CUSTOM_FW_description_file_content" | sed -n '3p' )" # f.e. 1.03@200818

		# take a part before the first '@'   vvvv
		ASIC_CUSTOM_FW_VERSION="${ASIC_CUSTOM_FW_VERSION_RAW%%@*}"
		# take a part after the last '@'          vvvv
		# shellcheck disable=SC2034
		ASIC_CUSTOM_FW_VERSION_DATE="${ASIC_CUSTOM_FW_VERSION_RAW##*@}"

		case "$ASIC_CUSTOM_FW_VERSION" in
			*.* ) # is it look like a version?
				# take a part before the first dot                      vvvv
				ASIC_CUSTOM_FW_VERSION_MAJOR="$( printf '%g\n' "${ASIC_CUSTOM_FW_VERSION%%.*}" 2> /dev/null )"
				# take a part after the last dot                        vvvv
				ASIC_CUSTOM_FW_VERSION_MINOR="$( printf '%g\n' "${ASIC_CUSTOM_FW_VERSION##*.}" 2> /dev/null )"
				#                                ^^ and then remove leading zeroes, if any
			;;
		esac

		ASIC_CUSTOM_FW_BRAND="$(	echo "$ASIC_CUSTOM_FW_description_file_content" | sed -n '4p' )" # f.e. 'Hiveon' OR whitelabel's brand
		ASIC_CUSTOM_FW_BUID="$(		echo "$ASIC_CUSTOM_FW_description_file_content" | sed -n '5p' )" # f.e. '333956ed-4bda-4f7f-9d29-097f8d68e686'
		ASIC_CUSTOM_FW_PUID="$(		echo "$ASIC_CUSTOM_FW_description_file_content" | sed -n '6p' )" # f.e. '62e3f4ad-15f4-432e-aebd-6ce164354f81'
	fi

	[ -z "$ASIC_CUSTOM_FW_BRAND" ] && ASIC_CUSTOM_FW_BRAND="$ASIC_CUSTOM_FW_BRAND_default" # an absent 4th line is equal to 'Hiveon', for backward compatibility

	# stub for legacy Hiveon vars
	# shellcheck disable=SC2034
	{
		HIVEON_VER="$ASIC_CUSTOM_FW_VERSION" # deprecated earlier in favor of the more clear HIVEON_VERSION
		HIVEON_VERSION="$ASIC_CUSTOM_FW_VERSION"
		HIVEON_VERSION_full="$ASIC_CUSTOM_FW_VERSION_RAW"
		HIVEON_VERSION_major="$ASIC_CUSTOM_FW_VERSION_MAJOR"
		HIVEON_VERSION_minor="$ASIC_CUSTOM_FW_VERSION_MINOR"
	}
}

function assign_model_specific_constants {
	# args
	local -r ASIC_MODEL="${1-}"

	# global vars, defaults
	ASIC_MOUNT_PATH=''
	ASIC_ALGO='unknown'
	ASIC_MINER_NAME='na'
	ASIC_LOG_FILE=''
	ASIC_MINER_CONFIG_FILE=''
	ASIC_CHAIN_HASHRATE_UNITS=''
	ASIC_TOTAL_HASHRATE_UNITS=''	# in case there's a difference between total hashrate units and chain hashrate units (like new Z11 fw)
	ASIC_MAX_FAN_RPM=6000
	ASIC_GPIO_LED_RED=''
	ASIC_GPIO_PATH=''
	ASIC_FAN_COUNT=2
	ASIC_CHAIN_COUNT=3
	ASIC_WEAK_FLASH=0				# 0 - not too weak (with the grain of salt yeah), 1 - weak and weary flash chip like them Antminers L3/Z11

	# vars
	local antminer_firmware_version

	# code
	case "$ASIC_MODEL" in
		'Antminer ' )
			ASIC_ALGO='Tensority'
			ASIC_MINER_NAME='bmminer'
			ASIC_LOG_FILE='/var/volatile/tmp/temp'
			ASIC_MINER_CONFIG_FILE='/config/bmminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='hs'
		;;

		'Antminer A3' )
			ASIC_MOUNT_PATH='config'
			ASIC_ALGO='Blake(2b)'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/volatile/log/messages'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=45
			ASIC_GPIO_PATH='value'
		;;

		'Antminer D3' | 'Antminer D3 Blissz'* )
			ASIC_MOUNT_PATH='config'
			ASIC_ALGO='X11'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/volatile/log/messages'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='mhs'
			ASIC_GPIO_LED_RED=45
			ASIC_GPIO_PATH='value'
		;;

		'Antminer DR3' )
			ASIC_MOUNT_PATH='config'
			ASIC_ALGO='Blake256R14'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/volatile/log/messages'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=941
			ASIC_GPIO_PATH='value'
		;;

		'Antminer E3' )
			ASIC_ALGO='Ethash'
			ASIC_MINER_NAME='bmminer'
			ASIC_LOG_FILE='/mnt/tmp/bmminer.log'
			ASIC_MINER_CONFIG_FILE='/config/bmminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='mhs'
		;;

		'Antminer L3+'* | 'Antminer L3++' )
			ASIC_MOUNT_PATH='config'
			ASIC_ALGO='Scrypt'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/volatile/log/messages'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='mhs'
			ASIC_GPIO_LED_RED=45
			ASIC_GPIO_PATH='value'
			ASIC_CHAIN_COUNT=4
			ASIC_WEAK_FLASH=1
		;;

		'Antminer S7' )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/volatile/log/messages'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=70
			#ASIC_GPIO_LED_RED=23
			ASIC_GPIO_PATH='direction'
		;;

		'Antminer S9' | 'Antminer S9i' | 'Antminer S9 Hydro' | 'Antminer S9j' |\
		'Antminer S9 (vnish'* | 'Antminer S9'* | 'Minecenter S9' )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='bmminer'
			ASIC_LOG_FILE='/var/volatile/tmp/temp'
			ASIC_MINER_CONFIG_FILE='/config/bmminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=37
			#ASIC_GPIO_LED_RED=38
			ASIC_GPIO_PATH='direction'
		;;

		'Antminer S9k'* | 'Antminer S9 SE'* )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/log/log'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=941
			ASIC_GPIO_PATH='direction'
		;;

		'Antminer S10'* )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='bmminer'
			ASIC_LOG_FILE='/var/volatile/tmp/temp'
			ASIC_MINER_CONFIG_FILE='/config/bmminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=37
			#ASIC_GPIO_LED_RED=38
			ASIC_GPIO_PATH='direction'
			ASIC_CHAIN_COUNT=6
		;;

		'Antminer S11' )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='bmminer'
			ASIC_LOG_FILE='/var/volatile/tmp/freq'
			ASIC_MINER_CONFIG_FILE='/config/bmminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=70
			#ASIC_GPIO_LED_RED=71
			ASIC_GPIO_PATH='direction'
		;;

		'Antminer S15' | 'Antminer T15' )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/log/log'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=941
			ASIC_GPIO_PATH='direction'
		;;

		'Antminer S17'* | 'Antminer T17'* | 'Antminer X17'* )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/log/log'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=941
			ASIC_GPIO_PATH='direction'
			ASIC_FAN_COUNT=4
		;;

		'Antminer T9+'* | 'Antminer T9'* )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='bmminer'
			ASIC_LOG_FILE='/var/volatile/tmp/temp'
			ASIC_MINER_CONFIG_FILE='/config/bmminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_GPIO_LED_RED=70
			[[ "$ASIC_CUSTOM_FW_VERSION" == '1.03' ]] && ASIC_GPIO_LED_RED=37
			ASIC_GPIO_PATH='direction'
			ASIC_CHAIN_COUNT=9
		;;

		'Antminer X3' )
			ASIC_MOUNT_PATH='config'
			ASIC_ALGO='CryptoNight'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/volatile/log/messages'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='khs'
			ASIC_GPIO_LED_RED=45
			ASIC_GPIO_PATH='value'
		;;

		'Antminer Z9'* )
			ASIC_MOUNT_PATH='config'
			ASIC_ALGO='Equihash'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/volatile/log/messages'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='khs'
			ASIC_MAX_FAN_RPM=8000
			ASIC_GPIO_LED_RED=941
			ASIC_GPIO_PATH='value'
			ASIC_WEAK_FLASH=1
		;;

		'Antminer Z11'* )
			ASIC_MOUNT_PATH='config'
			ASIC_ALGO='Equihash'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/var/volatile/log/messages'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='khs'
			ASIC_GPIO_LED_RED=941
			ASIC_GPIO_PATH='value'
			# hashrate tweak for the latest Z11 firmware
			if antminer_firmware_version="$( sed -n '1p' /usr/bin/compile_time )" && [[ "$antminer_firmware_version" == *'Oct'*'2019' ]]; then
				# shellcheck disable=SC2034
				ASIC_TOTAL_HASHRATE_UNITS='hs'
			fi
			# shellcheck disable=SC2034
			ASIC_WEAK_FLASH=1
		;;

		'ebit' )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='dwang_btc_miner'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			# shellcheck disable=SC2034
			LOCALIP="$( ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}' )" # ??? seems unused. will we need it later?
		;;

		'b29+.g19' | 'a9+.g19' )
			ASIC_ALGO='Equihash'
			ASIC_MINER_NAME='cgminer'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='hs'
		;;

		'd9.g19' )
			ASIC_ALGO='Blake256R14'
			ASIC_MINER_NAME='cgminer'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='mhs'
		;;

		's11.g19' )
			ASIC_ALGO='Blake2B'
			ASIC_MINER_NAME='cgminer'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='mhs'
		;;

		't3.soc' )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/tmp/log/cgminer.log'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='khs'
		;;

		't1.g19' )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='/tmp/log/volAnalys0.log'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='mhs'
		;;


		't2th+.soc' | 't2thf+.soc' | 't2thl+.soc' | 't2th.soc' | 't2tz.soc' |\
		't2thm.soc' | 't2thf.soc' | 't2t+.soc' | 't2ts.soc' | 't2ti.soc' | 't2t.soc' |\
		't3h+.soc' | 't3+.soc' )
			ASIC_ALGO='sha256'
			ASIC_MINER_NAME='cgminer'
			ASIC_LOG_FILE='journalctl'
			ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
			ASIC_CHAIN_HASHRATE_UNITS='mhs'
			STAT_TOKEN='eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJBc2ljTWluZXIiLCJpYXQiOiIxNDcwODM5MzQ1IiwiZXhwIjoiMzMxMzQ3NDkyNjEiLCJ1c2VyIjoiYWRtaW4ifQ'
			# shellcheck disable=SC2034,SC2046
			# TODO get rid of the unquoted variables to prevent accidental word splitting
			TEMP_TOKEN=$( echo -n $STAT_TOKEN.$( echo -n $STAT_TOKEN | openssl dgst -sha256 -hmac $( cat /tmp/jwtK ) -binary | openssl base64 -e -A | sed s/\+/-/ | sed -E s/=+$// ) ) # !!! 'sed -E'? maybe 'sed -r'?
			ASIC_FAN_COUNT=3
		;;

		'T4.G19' )
			ASIC_ALGO='CryptoNight'
			ASIC_MINER_NAME='innominer'
			ASIC_LOG_FILE='/tmp/log/innominer.log'
			ASIC_MINER_CONFIG_FILE='/home/www/conf/miner.conf'
			ASIC_CHAIN_HASHRATE_UNITS='khs'
		;;

		'Zig Z1'* )
			ASIC_ALGO='lyra2v2'
			ASIC_MINER_NAME='cgminer'
			ASIC_MINER_CONFIG_FILE='/var/www/html/resources/cgminer.config'
			ASIC_CHAIN_HASHRATE_UNITS='mhs'
			ASIC_MAX_FAN_RPM=4000
			# shellcheck disable=SC2034
			ASIC_CHAIN_COUNT=4
		;;

		'Toddminer C1'* )
			ASIC_ALGO='eaglesong'
			ASIC_MINER_NAME='cpuminer'
			ASIC_GPIO_LED_RED=168
			ASIC_GPIO_PATH='value'
			ASIC_MINER_CONFIG_FILE='/flask/sysconf/config/config.json'
			ASIC_CHAIN_HASHRATE_UNITS='ghs'
			ASIC_MAX_FAN_RPM=7000
			# shellcheck disable=SC2076,SC2034
			[[ "$ASIC_MODEL" =~ 'PRO' ]] && ASIC_FAN_COUNT=4
		;;

		'Blackminer F1'* )
			# shellcheck disable=SC2034
			{
				if mount | grep -q '/sdcard'; then
					ASIC_MOUNT_PATH='/sdcard'
				else
					ASIC_MOUNT_PATH='/fpgabit'
				fi
				ASIC_ALGO='eaglesong'
				ASIC_MINER_NAME='cgminer'
				ASIC_LOG_FILE='/var/volatile/log/messages'
				ASIC_MINER_CONFIG_FILE='/config/cgminer.conf'
				ASIC_CHAIN_HASHRATE_UNITS='ghs'
				ASIC_MAX_FAN_RPM=1500
				ASIC_GPIO_LED_RED=23
				ASIC_GPIO_PATH='direction'
			}
		;;
	esac
}


# global consts

declare -r ASIC_CUSTOM_FW_description_file='/usr/bin/compile_ver'


# code

assign_ASIC_MANUFACTURER_and_ASIC_MODEL_constants
assign_ASIC_CUSTOM_FW_constants
assign_model_specific_constants "$ASIC_MODEL"

# check if we're sourced
if ! ( return 0 2>/dev/null ); then
	# not sourced

	script_mission="$library_mission"
	script_version="$library_version"
	# shellcheck disable=SC2034
	script_basename="$library_basename"

	source colors

	#function print_script_version {
		echo -e "${YELLOW-}${script_mission}, version ${script_version}${NOCOLOR-}"
		echo
	#}

	#function print_script_usage {
	#	echo -e "Usage: ${CYAN-}${script_basename}${NOCOLOR-}"
	#	echo
	#}

	for variable_name in											\
		ASIC_MANUFACTURER ASIC_MODEL ASIC_FW_VERSION				\
		divider														\
		ASIC_CUSTOM_FW_BRAND ASIC_CUSTOM_FW_VERSION_RAW				\
		ASIC_CUSTOM_FW_VERSION_DATE ASIC_CUSTOM_FW_VERSION			\
		ASIC_CUSTOM_FW_VERSION_MAJOR ASIC_CUSTOM_FW_VERSION_MINOR	\
		ASIC_CUSTOM_FW_BUID ASIC_CUSTOM_FW_PUID						\
		IS_ASIC_CUSTOM_FW											\
		divider														\
		ASIC_MINER_NAME ASIC_ALGO									\
		ASIC_CHAIN_HASHRATE_UNITS ASIC_TOTAL_HASHRATE_UNITS			\
		ASIC_CHAIN_COUNT ASIC_FAN_COUNT ASIC_MAX_FAN_RPM			\
		divider														\
		ASIC_MOUNT_PATH ASIC_LOG_FILE ASIC_MINER_CONFIG_FILE		\
		divider														\
		ASIC_GPIO_PATH ASIC_GPIO_LED_RED ASIC_WEAK_FLASH			\
		divider														\
		LOCALIP STAT_TOKEN TEMP_TOKEN								\
		divider; do
			if [[ "$variable_name" != 'divider' ]]; then
				if [[ -v "$variable_name" ]]; then
					variable_value="${!variable_name-}"
					if [[ -n "$variable_value" ]]; then
						variable_value_color="${GREEN-}"
					else
						variable_value='empty'
						variable_value_color="${DGRAY-}"
					fi
					variable_name_color="${LGRAY-}"
				else
					variable_value='not defined'
					variable_name_color="${DGRAY-}"
					variable_value_color="${DGRAY-}"
				fi
				printf '  %b%-28.28s %b%s%b\n' "$variable_name_color" "$variable_name" "$variable_value_color" "$variable_value" "${NOCOLOR-}"
			else
				echo
			fi
	done
fi
