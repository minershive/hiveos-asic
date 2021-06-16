#!/hive/sbin/bash


#
# Copyright (C) 2017  Hiveon Holding LTD
# Distributed under Business Source License 1.1
# License information can be found in the LICENSE.txt file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE.txt
#
# Linted by shellcheck 0.7.0 (80%)
#


declare -r hive_functions_lib_mission='Client for ASICs: Oh my handy little functions'
declare -r hive_functions_lib_version='0.55.0'
#                                        ^^ current number of public functions


# !!! bash strict mode, no unbound variables
#set -o nounset # !!! this is a library, so we don't want to break the other's scripts


#
# all functions are divided by the next categories:
#	SCRIPT INFRASTRUCTURE, LOGGING
#	AUDIT
#	CONDITIONALS
#	MATH
#	FILES
#	DATE, TIME
#	NETWORK
#	TEXT, STRINGS
#	PROCESSES
#	SCREEN
#	OTHER
#


#
# functions: SCRIPT INFRASTRUCTURE, LOGGING
#
#	print_script_version
#	errcho
#	debugcho
#	log_line
#

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

	# vars

	local -i this_index

	# code

	echo -e -n "${BRED-}$0"
	for (( this_index = ${#FUNCNAME[@]} - 2; this_index >= 1; this_index-- )); { echo -e -n "${RED-}:${BRED-}${FUNCNAME[this_index]}"; }
	echo -e " error:${NOCOLOR-} $*"

} 1>&2

function debugcho {
	#
	# Usage: debugcho [arg...]
	#
	# uniform debug logging to stderr
	#

	# vars

	local this_argument
	local -i this_index

	# code

	echo -e -n "${DGRAY-}DEBUG $0"
	for (( this_index = ${#FUNCNAME[@]} - 2; this_index >= 1; this_index-- )); { echo -e -n ":${FUNCNAME[this_index]}"; }
	for this_argument in "$@"; do
		printf " %b'%b%s%b'" "${CYAN-}" "${DGRAY-}" "${this_argument}" "${CYAN-}"
	done
	echo "${NOCOLOR-}"

} 1>&2

function log_line {
	#
	# Usage: log_line 'ok|info|error|warning|debug' 'log_entry'
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __event_type="${1:-info}"
	local -r __log_entry="${2:-empty}"

	# consts

	local -r -A __event_color_dictionary=(
		['warning']="${YELLOW}"
		['debug']="${BPURPLE}"
		['error']="${RED}"
		['info']="${DGRAY}"
		['ok']="${GREEN}"
	)
	# wd			2 chars
	# agent			5
	# watchdog		8
	# controller	10
	local -r -i __basename_max_length=10

	# vars

	local __basename_color

	# code

	__basename_color="${__event_color_dictionary[$__event_type]}"
	[[ -z "$__basename_color" ]] && __basename_color="${NOCOLOR}" # any unsupported event
	# shellcheck disable=SC2154
	printf '%b%(%F %T)T %b%-*.*s%b %b%b\n' "${DGRAY}" -1 "$__basename_color" "$__basename_max_length" "$__basename_max_length" "$script_basename" "${NOCOLOR}" "$__log_entry" "${NOCOLOR}"
}



#
# functions: AUDIT
#
# we need to audit externally--does the script work as intended or not (like the system returns exitcode "file not found")
# [[ $( script_to_audit ) != 'I AM FINE' ]] && echo "Something wrong with $script_to_check"
#
#	print_i_am_doing_fine_then_exit
#	is_script_exist_and_doing_fine
#

function print_i_am_doing_fine_then_exit {
	#
	# Usage: print_i_am_fine_and_exit
	#

	# code

	echo "$__audit_ok_string"
	exit $(( exitcode_OK ))
}

function is_script_exist_and_doing_fine {
	#
	# Usage: is_script_exist_and_doing_fine
	#

	# args

	(( $# != 1 )) && { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __script_name="${1-}"

	# code

	is_program_in_the_PATH "$__script_name" && [[ "$( "$__script_name" --audit )" == "$__audit_ok_string" ]]
}



#
# functions: CONDITIONALS
#
#	iif
#	iif_pipe
#	is_program_in_the_PATH
#	is_process_running
#	is_process_not_running
#	is_function_exist
#	is_first_floating_number_bigger_than_second
#	is_first_version_equal_to_second
#	is_integer
#	is_JSON_string_empty_or_null
#	is_JSON_string_not_empty_or_null
#	is_file_exist_but_empty
#	is_file_exist_and_contain
#	is_directory_exist_and_writable
#

function iif {
	#
	# Usage: iif flag cmd [arg...]
	#
	# if true (flag==1), runs cmd
	#

	# args

	(( $# >= 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -i __condition="${1-}"
	local -r -a __cmd=( "${@:2}" )

	# code

	if (( __condition )); then
		"${__cmd[@]}" # execute a command
	fi
}

function iif_pipe {
	#
	# Usage: iif flag cmd [arg...]
	#
	# if true (flag==1), runs cmd
	# if false (flag==0), copy stdin to stdout, if stdin not empty
	# could be used to construct conditional pipelines
	#

	# args

	(( $# >= 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -i __condition="${1-}"
	local -r -a __cmd=( "${@:2}" )

	# code

	if (( __condition )); then
		"${__cmd[@]}" # execute a command
	else
		cat - # pass stdin to stdout
	fi
}

function is_program_in_the_PATH {
	#
	# Usage: is_program_in_the_PATH 'program_name'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __program_name="$1"

	# code

	hash "$__program_name" 2> /dev/null
}

function is_process_running {
	#
	# Usage: is_process_running 'process_name'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r process_name="${1-}"

	# code

	if is_program_in_the_PATH 'pidof'; then
		pidof "$process_name" > /dev/null
	else
		# shellcheck disable=SC2009
		ps | grep -q "[${process_name:0:1}]${process_name:1}" # neat trick with '[p]attern'
		# ...bc we don't have pgrep
	fi
}

function is_process_not_running {
	#
	# Usage: is_process_not_running 'process_name'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r process_name="${1-}"

	# code

	! is_process_running "$process_name"
}

function is_function_exist {
	#
	# Usage: is_function_exist 'function_name'
	#
	# stdin: none
	# stdout: none
	# exit code: boolean
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __function_name="$1"

	# code

	declare -F -- "$__function_name" >/dev/null
}

function is_first_floating_number_bigger_than_second {
	#
	# Usage: is_first_floating_number_bigger_than_second 'first_number' 'second_number'
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r first_number="${1-}"
	local -r second_number="${2-}"

	# code

	# 1. trivial test based on string comparison
	if [[ "$first_number" == "$second_number" ]]; then
		false
	# 2. compare a part before the dot as numbers
	elif (( ${first_number%.*} == ${second_number%.*} )); then
		[[ "${first_number#*.}" > "${second_number#*.}" ]] # intentional text compare
	else
		(( ${first_number%.*} > ${second_number%.*} ))
	fi
}

function is_first_version_equal_to_second {
	#
	# Usage: is_first_version_equal_to_second 'first_version' 'second_version'
	#
	# Returns: exitcode_IS_EQUAL | exitcode_LESS_THAN | exitcode_GREATER_THAN
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local first_version="${1-}"
	local second_version="${2-}"

	# vars

	local IFS='.-'
	local -i idx
	local -a first_version_array second_version_array

	# code

	if [[ "$first_version" != "$second_version" ]]; then
		first_version="${first_version//[[:alpha:]]/}"
		second_version="${second_version//[[:alpha:]]/}"

		first_version_array=( $first_version )
		second_version_array=( $second_version )

		# fill empty fields in first_version_array with zeros
		for (( idx=${#first_version_array[@]}; idx < ${#second_version_array[@]}; idx++ )); do
			first_version_array[idx]=0
		done
		for (( idx=0; idx < ${#first_version_array[@]}; idx++ )); do
			# you don't need double quotes here but we need to fix a syntax highlighting issue
			(( "10#${first_version_array[idx]}" > "10#${second_version_array[idx]-0}" )) && return $(( exitcode_GREATER_THAN ))
			(( "10#${first_version_array[idx]}" < "10#${second_version_array[idx]-0}" )) && return $(( exitcode_LESS_THAN ))
		done
	fi

	return $(( exitcode_IS_EQUAL ))
}

function is_integer {
	#
	# Usage: is_integer 'string_to_check'
	#
	# checks the first argument as an integer or fail
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r string_to_check="${1-}"

	# consts

	# "Integer: A sequence of an optional sign (+ or -) followed by no more than 18 (significant) decimal digits."
	local -r integer_definition_RE='^([+-])?0*([0-9]{1,18})$'

	# code

	[[ "$string_to_check" =~ $integer_definition_RE ]]
}

function is_JSON_string_empty_or_null {
	#
	# Usage: is_JSON_string_empty_or_null 'JSON_string_to_check'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r JSON_string_to_check="$1"

	# code

	[[ -z "$JSON_string_to_check" || "$JSON_string_to_check" == 'null' ]]
}

function is_JSON_string_not_empty_or_null {
	#
	# Usage: is_JSON_string_not_empty_or_null 'JSON_string_to_check'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r JSON_string_to_check="$1"

	# code

	[[ -n "$JSON_string_to_check" && "$JSON_string_to_check" != 'null' ]]
}

function is_file_exist_but_empty {
	#
	# Usage: is_file_exist_but_empty 'file_name_to_check'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r file_name_to_check="$1"

	# code

	[[ -f "$file_name_to_check" && ! -s "$file_name_to_check" ]]
}

function is_file_exist_and_contain {
	#
	# Usage: is_file_exist_and_contain 'file_name_to_check' 'ERE_string_to_contain'
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r file_name_to_check="$1"
	local -r ERE_string_to_contain="$2"

	# code

	[[ -s "$file_name_to_check" ]] && grep -q "$ERE_string_to_contain" "$file_name_to_check"
}

function is_directory_exist_and_writable {
	#
	# Usage: is_directory_exist_and_writable 'directory_to_check'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r directory_to_check="${1-}"

	# code

	[[ -d "$directory_to_check" && -w "$directory_to_check" ]]
}



#
# functions: MATH
#
#	calculate_percent_from_number
#	set_bits_by_mask
#	scientific_to_integer
#	humanize
#	khs_to_human_friendly_hashrate
#

function calculate_percent_from_number {
	#
	# Usage: calculate_percent_from_number 'percent' 'number'
	#
	# gives result rounded to the *nearest* integer, not the frac part as in the bash builtin arithmetics
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -i percent="${1-}"
	local -r -i number="${2-}"

	# code

	printf '%.0f\n' "$((10**9 * (number * percent) / 100 ))e-9" # yay, neat trick
}

function set_bits_by_mask {
	#
	# Usage: set_bits_by_mask 'variable_by_ref' 'bitmask_by_ref'
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -n variable_by_ref="${1-}"
	local -r -n bitmask_by_ref="${2-}"

	# code

	(( variable_by_ref |= bitmask_by_ref )) # bitwise OR
}

function scientific_to_integer {
	#
	# Usage: scientific_to_integer 'exponential_number'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r exponential_number="${1:-0}"

	# code

	printf "%.0f\n" "$exponential_number"
}

function humanize {
	#
	# Usage: humanize 'big_integer_number' ['name_of_unit']
	#
	# '1100000000000' 'h/s' -> '1.1 Th/s'

	# args

	(( $# == 1 || $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	big_integer_number=${1:-0}
	name_of_unit=${2:-}

	# vars

	local period_and_two_digits='' sign=''
	local -i remainder_rounded_to_two_digits
	local -i magnitude_index=0 # 0  1    2    3    4    5    6   7     8
	local magnitude_char=(		'' 'k'  'M'  'G'  'T'  'P'  'E' 'Y'   'Z' )
	#								kilo Mega Giga Tera Peta Exa Yotta Zetta

	# code

	# check for negative
	if (( big_integer_number < 0 )); then
		(( big_integer_number = -big_integer_number )) # strip off the sign
		sign='-'
	fi

	while (( big_integer_number >= 1000 )); do
		(( remainder_rounded_to_two_digits = ( big_integer_number + 5 ) % 1000 / 10 ))

		if (( remainder_rounded_to_two_digits == 0 )); then
			# discard '.00'
			period_and_two_digits=''
		elif (( remainder_rounded_to_two_digits % 10 == 0 )); then
			# strip off a trailing '0'
			printf -v period_and_two_digits '.%01u' $(( remainder_rounded_to_two_digits / 10 ))
		else
			# print as is
			printf -v period_and_two_digits '.%02u' "$remainder_rounded_to_two_digits"
		fi

		(( big_integer_number /= 1000, magnitude_index++ ))
	done

	echo "${sign}${big_integer_number}${period_and_two_digits} ${magnitude_char[${magnitude_index}]}${name_of_unit}"
}

function khs_to_human_friendly_hashrate {
	#
	# Usage: khs_to_human_friendly_hashrate 'hashrate_in_khs'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r hashrate_in_khs="${1:-0}"

	# vars

	local -i khs_integer hs_integer

	# code

	if [[ "$hashrate_in_khs" == '0' || "$hashrate_in_khs" == 'null' ]]; then
		echo '0 H/s'
	elif [[ "$hashrate_in_khs" != *[Ee]* ]]; then
		# a number without exponent
		hs_integer="$( scientific_to_integer "${hashrate_in_khs}e3" )" # multiply by 1000 right there and then
		humanize "$hs_integer" 'H/s'
	else
		# a number with exponent, process with care
		khs_integer="$( scientific_to_integer "$hashrate_in_khs" )"
		(( hs_integer = khs_integer * 1000 ))
		humanize "$hs_integer" 'H/s'
	fi
}



#
# functions: FILES
#
#	get_file_last_modified_time_in_seconds
#	get_file_size_in_bytes
#	read_variable_from_file
#	read_variable_from_file_unsafe
#	set_variable_in_file
#

function get_file_last_modified_time_in_seconds {
	#
	# Usage: get_file_last_modified_time_in_seconds 'file_name'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r file_name="${1-}"

	# code

	if [[ -f "$file_name" ]]; then
		date -r "$file_name" '+%s'
		# or:
		# stat -c '%Y' "$file_name"
		# their timing is the same in case 'date' and 'stat' are busybox' commands
	else
		errcho "'$file_name' not found"
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi
}

function get_file_size_in_bytes {
	#
	# Usage: get_file_size_in_bytes 'file_name'
	#
	# highly portable, uses ls if no stat there
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r file_name="${1-}"

	# arrays

	local -a ls_output_field=()

	# code

	if [[ -f "$file_name" ]]; then
		# try stat first
		if ! stat -Lc %s "$file_name" 2> /dev/null; then
			# no stat, parse ls output to array then:
			ls_output_field=( $( ls -dn "$file_name" ) ) && echo "${ls_output_field[4]}" # print 5th field
			# -rwxr-xr-x 1 0 0 4745 Apr  3 16:03 log-watcher.sh
			# 0          1 2 3 4    5    6 7     8
		fi
	else
		errcho "$file_name not found"
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi
}

function read_variable_from_file {
	#
	# Usage: read_variable_from_file 'file_with_variables' 'variable_to_read'
	#
	# input file is filtered for valid assignments
	# caveat: doesn't work well for multi-line assignments
	# ??? still cannot figure out how to filter them in a proper way

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r file_with_variables="${1-}"
	local -r -n variable_to_read="${2-}"

	# vars

	local result

	# code

	# if file isn't empty or it's a named pipe (for <() constructions)
	if [[ -s "$file_with_variables" || -p "$file_with_variables" ]]; then
		# let's don't pollute our scope -- do it in the sub-shell
		if result="$(
			source <( grep -E -e '^[_[:alnum:]]+=[^[:space:]]' -- "$file_with_variables" ) # read all *valid* variable assignments
			[[ -n "${variable_to_read-}" ]] && echo "${variable_to_read-}"
		)"; then
			echo "$result"
		else
			return $(( exitcode_ERROR_NOT_FOUND ))
		fi
	else
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi
}

function read_variable_from_file_unsafe {
	#
	# Usage: read_variable_from_file_unsafe 'file_with_variables' 'variable_to_read'
	#
	# can be evil if file_with_variables does contain commands or has an invalid syntax

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r file_with_variables="${1-}"
	local -r -n variable_to_read="${2-}"

	# vars

	local result

	# code

	# if file isn't empty or it's a named pipe (for <() constructions)
	if [[ -s "$file_with_variables" || -p "$file_with_variables" ]]; then
		# let's don't pollute our scope -- do it in the sub-shell
		if result="$(
			source "$file_with_variables"
			[[ -n "${variable_to_read-}" ]] && echo "${variable_to_read-}"
		)"; then
			echo "$result"
		else
			return $(( exitcode_ERROR_NOT_FOUND ))
		fi
	else
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi
}

function set_variable_in_file {
	#
	# Usage: set_variable_in_file 'file_with_variables' 'variable_to_change' 'new_value'
	#
	# if the variable isn't exist, add it to the end of file
	# if the variable is defined as empty, like 'var=', add a value to it

	# args

	(( $# == 3 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r file_with_variables="${1-}"
	local -r variable_to_change="${2-}"
	local -r new_value="${3-}"

	# vars

	local empty_if_ends_with_newline

	# code

	if [[ -s "$file_with_variables" ]]; then
		# is variable exist?
		if grep -Eq -e "^$variable_to_change=.*$" -- "$file_with_variables"; then
			# yes, change its value
			sed -i "s/^$variable_to_change=.*$/$variable_to_change=$new_value/" "$file_with_variables"
		else
			# no, add variable
			empty_if_ends_with_newline="$( tail -c 1 "$file_with_variables" )"
			{
				[[ -n "$empty_if_ends_with_newline" ]] && echo # add a newline first
				echo "$variable_to_change=$new_value"
			} >> "$file_with_variables"
		fi
	else
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi
}



#
# functions: DATE, TIME
#
#	get_system_boot_time_in_seconds
#	get_current_system_time_in_seconds
#	set_variable_to_current_system_time_in_seconds
#	seconds2dhms
#	format_date_in_seconds
#	get_system_uptime_in_seconds
#	get_system_uptime_in_milliseconds
#	snore
#

function get_system_boot_time_in_seconds {
	#
	# Usage: get_system_boot_time_in_seconds
	#

	awk '/btime/{print $2}' /proc/stat
}

function get_current_system_time_in_seconds {
	#
	# Usage: get_current_system_time_in_seconds
	#

	printf '%(%s)T\n' -1
}

function set_variable_to_current_system_time_in_seconds {
	#
	# Usage: set_variable_to_current_system_time_in_seconds 'variable_to_set_by_ref'
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -n variable_to_set_by_ref="${1-}" # get var by ref

	# code

	# shellcheck disable=SC2034
#	variable_to_set_by_ref="$( get_current_system_time_in_seconds )"
	printf -v variable_to_set_by_ref '%(%s)T\n' -1
}

function seconds2dhms {
	#
	# Usage: seconds2dhms 'time_in_seconds' ['delimiter']
	#
	# Renders time_in_seconds to 'XXd XXh XXm[ XXs]' string
	# Default delimiter = ' '
	#

	# args

	(( $# == 1 || $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -i -r time_in_seconds="${1#-}" # strip sign, get ABS (just in case)
	local -r delimiter_DEFAULT=' '
	local -r delimiter="${2-${delimiter_DEFAULT}}"

	# vars

	local -i days hours minutes seconds
	local dhms_string

	# code

	((
		days = time_in_seconds / 60 / 60 / 24,
		hours = time_in_seconds / 60 / 60 % 24,
		minutes = time_in_seconds / 60 % 60,
		seconds = time_in_seconds % 60
	)) # arithmetic context, GOD I LOVE IT

	if (( days )); then
		dhms_string="${days}d${delimiter}${hours}h${delimiter}${minutes}m"
	elif (( hours )); then
		dhms_string="${hours}h${delimiter}${minutes}m"
	elif (( minutes )); then
		dhms_string="${minutes}m${delimiter}${seconds}s"
	else
		dhms_string="${seconds}s"
	fi

	echo "$dhms_string"
}

function format_date_in_seconds {
	#
	# Usage: format_date_in_seconds 'time_in_seconds' ['date_format']
	#
	# 'time_in_seconds' can be -1 for a current time
	# 'date_format' as in strftime(3) OR special 'dhms' format
	#

	# args

	(( $# == 1 || $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -i -r time_in_seconds="${1-}"
	local -r date_format_DEFAULT='%F %T'
	local -r date_format="${2-${date_format_DEFAULT}}"

	# code

	if [[ $date_format == 'dhms' ]]; then
		seconds2dhms "$time_in_seconds"
	else
		printf "%(${date_format})T\n" "$time_in_seconds"
	fi
}

function get_system_uptime_in_seconds {
	#
	# Usage: get_system_uptime_in_seconds
	#

	# vars

	local -a uptime_line
	local cputime_line
	local -i system_uptime_in_seconds

	# code

	# 'test -s' - do not work on procfs files
	# 'test -r' - file exists and readable
	if [[ -r /proc/uptime ]]; then
		# /proc/uptime sample: '143377.33 68759.84'
		uptime_line=( $( < /proc/uptime ) )
		system_uptime_in_seconds=$(( ${uptime_line/\.} / 100 ))
	elif [[ -r /proc/sched_debug ]]; then
		# do we really need a second option?
		cputime_line="$( grep -F -m 1 '\.clock' /proc/sched_debug )"
		if [[ $cputime_line =~ [^0-9]*([0-9]*).* ]]; then
			system_uptime_in_seconds=$(( BASH_REMATCH[1] / 1000 ))
		fi
	else
		errcho '/proc/uptime or /proc/sched_debug not found'
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi

	printf '%u\n' "$system_uptime_in_seconds"
}

function get_system_uptime_in_milliseconds {
	#
	# Usage: get_system_uptime_in_milliseconds
	#

	# vars

	local -a uptime_line
	local -i system_uptime_in_milliseconds

	# code

	# 'test -s' - do not work on procfs files
	# 'test -r' - file exists and readable
	if [[ -r /proc/uptime ]]; then
		# /proc/uptime sample: '143377.33 68759.84'
		uptime_line=( $( < /proc/uptime ) )
		system_uptime_in_milliseconds=$(( ${uptime_line/\.} * 10 ))
	else
		errcho '/proc/uptime not found'
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi

	printf '%u\n' "$system_uptime_in_milliseconds"
}

function snore {
	#
	# Usage: snore 1
	#        snore 0.2
	#
	# pure bash 'sleep'
	# https://blog.dhampir.no/content/sleeping-without-a-subprocess-in-bash-and-how-to-sleep-forever

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __sleep_time="${1-1}" # 1s by default

	# vars

	local IFS # reset IFS in case it's set to something weird

	# code

	# shellcheck disable=SC1083
	# because 'man bash':
	# Each redirection that may be preceded by a file descriptor number may instead be preceded by a word of the form {varname}.
	[[ -n "${__snore_fd:-}" ]] || { exec {__snore_fd}<> <(:); } 2> /dev/null ||
	{
		# workaround for MacOS and similar systems
		local fifo
		fifo="$( mktemp -u )"
		mkfifo -m 700 "$fifo"
		# shellcheck disable=SC2093
		exec {__snore_fd}<>"$fifo"
		rm "$fifo"
	}
	read -t "${__sleep_time}" -u "$__snore_fd" || :
}



#
# functions: NETWORK
#
#	is_interface_up
#	is_tcp_port_listening
#	get_ip_address
#	get_ip_postfix_address
#	get_mac_address
#

function is_interface_up {
	#
	# Usage: is_interface_up ['interface']
	#

	# args

	(( $# == 0 || $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r interface_DEFAULT='eth0'
	local -r interface="${1:-$interface_DEFAULT}"

	# code

	if [[ ! -d "/sys/class/net/$interface" ]]; then
		errcho "No such interface '$interface'"
		return $(( exitcode_ERROR_NOT_FOUND ))
	else
		[[ $( < "/sys/class/net/${interface}/operstate" ) == 'up' ]]
	fi
}

function is_tcp_port_listening {
	#
	# Usage: is_tcp_port_listening 'host' 'port'
	#
	# Exit codes:
	#
	# exitcode_PORT_IS_OPENED
	# exitcode_PORT_IS_CLOSED
	# exitcode_ERROR_HOST_NOT_FOUND
	# exitcode_ERROR_SOMETHING_WEIRD

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r host_to_check="${1-}"
	local -r port_to_check="${2-}"

	# vars

	local -i nc_exitcode

	# code

	(
		exec 2> /dev/null # silence the "Terminated" message in this sub-shell if the timeout watchdog has been activated
		/hive/bin/timeout -t 1 nc "$host_to_check" "$port_to_check" < /dev/null
	)

	# exit code:
	# 0		port is opened
	# 1		host not found, connection error
	# 143	port is closed
	nc_exitcode=$?

	case "$nc_exitcode" in
		0	)	return $(( exitcode_PORT_IS_OPENED ))			;;
		1	)	return $(( exitcode_ERROR_HOST_NOT_FOUND ))		;;
		143	)	return $(( exitcode_PORT_IS_CLOSED ))			;;
		*	)	return $(( exitcode_ERROR_SOMETHING_WEIRD ))	;;
	esac
}

# shellcheck disable=SC2120
# bc $1 can be empty
function get_ip_address {
	#
	# Usage: get_ip_address ['interface']
	#

	# args

	(( $# == 0 || $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r interface_DEFAULT='eth0'
	local -r interface="${1-$interface_DEFAULT}"

	# code

	LANG=C ifconfig "$interface" | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }'
}

# shellcheck disable=SC2120
# bc $1 can be empty
function get_ip_postfix_address {
	#
	# Usage: get_ip_postfix_address ['interface']
	#
	# it does mimic a BTC Tools' "IP postfix" -- '192.168.12.13' becomes '12x13'

	# args

	(( $# == 0 || $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r interface_DEFAULT='eth0'
	local -r interface="${1-$interface_DEFAULT}"

	# vars

	local -i octet_C=0 octet_D=0

	# code

	LANG=C ifconfig "$interface" | grep 'inet addr:' | { IFS=' :.' read -r _ _ _ _ octet_C octet_D _; echo "${octet_C}x${octet_D}"; }
}

# shellcheck disable=SC2120
# bc $1 can be empty
function get_mac_address {
	#
	# Usage: get_mac_address ['interface']
	#

	# args

	(( $# == 0 || $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r interface_DEFAULT='eth0'
	local -r interface="${1-$interface_DEFAULT}"

	# code

	LANG=C ifconfig "$interface" | rematch 'HWaddr (.{17})'
}



#
# functions: TEXT, STRINGS
#
#	strip_ansi
#	get_substring_position_in_string
#	rematch
#	get_all_matches
#	get_all_matches_unique
#	expand_hive_templates
#	expand_hive_templates_in_variable_by_ref
#

function strip_ansi {
	#
	# Usage: cat file | strip_ansi
	#
	# strips ANSI codes from text
	#
	# stdin: The text to strip
	# stdout: ANSI stripped text
	#

	# args

	(( $# == 0 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }

	# vars

	local line=''

	# code

	shopt -s extglob
	while IFS='' read -r line || [[ -n "$line" ]]; do
		printf '%s\n' "${line//$'\e'[\[(]*([0-9;])[@-n]/}"
	done
}

function get_substring_position_in_string {
	#
	# Usage: get_substring_position_in_string 'substring' 'string'
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r substring="${1-}"
	local -r string="${2-}"

	# vars

	local prefix

	# code

	prefix="${string%%${substring}*}"

	if (( ${#prefix} != ${#string} )); then
		echo "${#prefix}"
		return $(( exitcode_OK ))
	else
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi
}

function rematch {
	#
	# Usage: rematch 'regex' 'string'
	# Usage: rematch 'regex' <<< 'string'
	#

	# args

	(( $# == 1 || $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }

	local -r regex="${1-}"
	local -r string="${2:-$( < /dev/stdin )}" # get from arg or stdin

	# code

	[[ $string =~ $regex ]]
	printf '%s\n' "${BASH_REMATCH[@]:1}"
}

function get_all_matches {
	#
	# Usage: get_all_matches 'string' 'RE'
	#
	# extract all REgex matches from the string (global matching)
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local string_to_match="$1"
	local -r RE="$2"

	# consts

	local -r -i string_to_match_original_length="${#string_to_match}"

	# code

	while [[ "$string_to_match" =~ $RE ]]; do
		echo "${BASH_REMATCH[0]}"
		string_to_match="${string_to_match#*${BASH_REMATCH[0]}}" # remove one pattern a time
		if (( string_to_match_original_length == ${#string_to_match} )); then
			errcho "something weird with bash pattern matching (matched '$string_to_match' against '$RE')"
			break
		fi
	done
}

function get_all_matches_unique {
	#
	# Usage: get_all_matches_unique 'string' 'RE'
	#
	# extract all REgex matches from the string (global matching)
	# output contains no duplicates
	#

	# args

	(( $# == 2 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local string_to_match="$1"
	local -r RE="$2"

	# consts

	local -r -i string_to_match_original_length="${#string_to_match}"

	# code

	while [[ "$string_to_match" =~ $RE ]]; do
		echo "${BASH_REMATCH[0]}"
		string_to_match="${string_to_match//${BASH_REMATCH[0]}}" # remove a pattern globally
		if (( string_to_match_original_length == ${#string_to_match} )); then
			errcho "something weird with bash pattern matching (matched '$string_to_match' against '$RE')"
			break
		fi
	done
}

function expand_hive_templates {
	#
	# Usage: expand_hive_templates 'string_to_expand' ['is_verbose_FLAG']
	#
	# wrapper for expand_hive_templates_in_variable_by_ref()

	# args

	local string_to_expand="$1"
	local -i is_verbose_FLAG="$2"

	# code

	expand_hive_templates_in_variable_by_ref 'string_to_expand' "$is_verbose_FLAG"
	echo "$string_to_expand"
}

function expand_hive_templates_in_variable_by_ref {
	#
	# Usage: expand_hive_templates_in_variable_by_ref 'string_to_expand_by_ref' ['is_verbose_FLAG']
	#
	# in a given string variable, expand all Hive templates:
	#
	#	sw/fw versions: %BUILD% %FW%
	#	network:		%HOSTNAME% %IP% %IP_POSTFIX% %MAC%
	#	OC profile:		%PROFILE%
	#	RIG_CONF:		%URL% %WORKER_NAME% %WORKER_NAME_RAW%
	#	WALLET_CONF:	%EMAIL% %EWAL% %DWAL% %ZWAL%
	#
	# bonus: you could add a special suffix _SAFE or _SAFEST to any template to sanitize it
	#

	# args and asserts

	(( $# == 1 || $# == 2 ))	|| { errcho "invalid number of arguments: $#";				return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	[[ -n "$1" ]]				|| { errcho 'empty argument, must be a variable name';		return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	[[ -v "$1" ]]				|| { errcho "variable '$1' is not set";						return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -n string_to_expand_by_ref="$1"
	[[ -n "$string_to_expand_by_ref" ]] || { errcho "variable '$1' is empty";	return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -i is_verbose_FLAG="${2-0}"

	# consts

	local -r valid_tag_template_RE='%[[:alpha:]][[:alnum:]_]+%'

	local -r soft_sanitize_keyword_RE='_[Ss][Aa][Ff][Ee]%' # _SAFE
	local -r soft_sanitize_blacklisted_chars_RE='[^[:alnum:]_]'
	local -r soft_sanitize_replacement_char='_'

	local -r hard_sanitize_keyword_RE='_[Ss][Aa][Ff][Ee][Ss][Tt]%' # _SAFEST
	local -r hard_sanitize_blacklisted_chars_RE='[^[:alnum:]]'
	local -r hard_sanitize_replacement_char='x'

	# super local consts haha

	local -r __RIG_CONF_default='/hive-config/rig.conf'
	local -r __RIG_CONF="${RIG_CONF:-$__RIG_CONF_default}" # for ASIC emulator: set to default only if RIG_CONF variable is empty
	local -r __WALLET_CONF_default='/hive-config/wallet.conf'
	local -r __WALLET_CONF="${WALLET_CONF:-$__WALLET_CONF_default}" # for ASIC emulator: set to default only if WALLET_CONF variable is empty

	# enums

	local -r -i sanitize_NONE=0
	local -r -i sanitize_SOFT=1
	local -r -i sanitize_HARD=2
	local -i sanitization_type

	# vars

	local this_template_raw this_template_raw_sanitize_suffix_stripped this_template_keyword this_template_keyword_in_uppercase this_template_substitution

	# code

	for this_template_raw in $( get_all_matches_unique "$string_to_expand_by_ref" "$valid_tag_template_RE" ); do

		if [[ "$this_template_raw" =~ $soft_sanitize_keyword_RE ]]; then
			(( sanitization_type = sanitize_SOFT ))
			this_template_raw_sanitize_suffix_stripped="${this_template_raw/$soft_sanitize_keyword_RE/%}" # strip '_SAFE' suffix
		elif [[ "$this_template_raw" =~ $hard_sanitize_keyword_RE ]]; then
			(( sanitization_type = sanitize_HARD ))
			this_template_raw_sanitize_suffix_stripped="${this_template_raw/$hard_sanitize_keyword_RE/%}" # strip '_SAFEST' suffix
		else
			(( sanitization_type = sanitize_NONE ))
			this_template_raw_sanitize_suffix_stripped="$this_template_raw"
		fi

		this_template_keyword="${this_template_raw_sanitize_suffix_stripped//%}" # strip '%' chars
		this_template_keyword_in_uppercase="${this_template_keyword^^}" # toupper()
		this_template_substitution=''

		case "$this_template_keyword_in_uppercase" in
			'BUILD' )
				if [[ -s /hive/etc/build ]]; then
					this_template_substitution="$( < /hive/etc/build )"
				else
					this_template_substitution='ERR_unknown_build'
				fi
			;;

			'FW' )
				#
				#/usr/bin/compile_ver:
				#Tue Aug 18 09:03:07 UTC 2020
				#Antminer T9 Hiveon
				#1.03@200818
				#
				#/usr/bin/compile_time:
				#Tue Aug 18 09:03:07 UTC 2020
				#Antminer T9 Hiveon
				#
				if [[ -s /usr/bin/compile_ver ]]; then
					this_template_substitution="$( sed -n '3p' /usr/bin/compile_ver )"
				elif [[ -s /usr/bin/compile_time ]]; then
					this_template_substitution="$( sed -n '1p' /usr/bin/compile_time )"
				else
					this_template_substitution='ERR_unknown_fw'
				fi
			;;

			'HOSTNAME' )
				this_template_substitution="$( hostname )"
			;;

			'IP' )
				# shellcheck disable=SC2119
				# bc 'no arguments' does mean default interface
				this_template_substitution="$( get_ip_address )"
			;;

			'IP_POSTFIX' )
				# shellcheck disable=SC2119
				# bc 'no arguments' does mean default interface
				this_template_substitution="$( get_ip_postfix_address )"
			;;

			'MAC' )
				# shellcheck disable=SC2119
				# bc 'no arguments' does mean default interface
				this_template_substitution="$( get_mac_address )"
			;;

			'PROFILE' )
				this_template_substitution="$( asic-oc status --active-profile-desc )" ||
					this_template_substitution='ERR_unknown_profile'
			;;

			'URL' )
				#IFS='/' read -r _ _ this_template_substitution <<< "$HIVE_HOST_URL" # extract a domain name
				# nope
				# i think it should be FQDN
				this_template_substitution="$( read_variable_from_file "$__RIG_CONF" 'HIVE_HOST_URL' )" ||
					this_template_substitution='ERR_no_HIVE_HOST_URL_in_RIG_CONF'
			;;

			'WORKER_NAME' | 'WORKER_NAME_RAW' )
				this_template_substitution="$( read_variable_from_file "$__RIG_CONF" 'WORKER_NAME' )" ||
					this_template_substitution='ERR_no_WORKER_NAME_in_RIG_CONF'
			;;

			'EMAIL' | 'EWAL' | 'DWAL' | 'ZWAL' )
				this_template_substitution="$( read_variable_from_file_unsafe "$__WALLET_CONF" "$this_template_keyword_in_uppercase" )" ||
					this_template_substitution="ERR_no_${this_template_keyword_in_uppercase}_in_WALLET_CONF"
			;;

		esac

		if [[ -n "$this_template_substitution" ]]; then
			# sanitization
			case "$sanitization_type" in
				"$sanitize_SOFT" ) # soft sanitize in case of _SAFE suffix -- replace blacklisted chars with a safe char
					this_template_substitution="${this_template_substitution//$soft_sanitize_blacklisted_chars_RE/$soft_sanitize_replacement_char}"
					;;
				"$sanitize_HARD" ) # hard sanitize in case of _SAFEST suffix
					this_template_substitution="${this_template_substitution//$hard_sanitize_blacklisted_chars_RE/$hard_sanitize_replacement_char}"
					;;
			esac
			# a template expanding itself
			string_to_expand_by_ref="${string_to_expand_by_ref//$this_template_raw/$this_template_substitution}"
			# logging
			(( is_verbose_FLAG )) && debugcho "Template $this_template_raw expanded to $this_template_substitution"
		else
			errcho "Unknown template $this_template_keyword_in_uppercase"
		fi

	done
}



#
# functions: PROCESSES
#
#	pgrep_count
#	pgrep_quiet
#	get_process_owner
#

function pgrep_count {
	#
	# Usage: pgrep_count 'pattern'
	#
	# pgrep --count naive emulator
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r pattern="$1"

	# vars

	local marker self

	# code

	printf -v marker '%(%s)T-%s-%u%u' -1 "${FUNCNAME[0]}" "${RANDOM}" "${RANDOM}"
#	self="${$}[[:space:]].+${FUNCNAME[0]}" # TODO figure out what's best
	self="(${$}|${BASHPID})[[:space:]].+$0"

	ps w | tail -n +2 | grep -E -e "$pattern" -e "$marker" -- | grep -Evc -e "$marker" -e "$self" --
}

function pgrep_quiet {
	#
	# Usage: pgrep_quiet 'pattern'
	#
	# pgrep --quiet naive emulator
	#

	# args

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r pattern="$1"

	# vars

	local marker self

	# code

	printf -v marker '%(%s)T:%s:%u%u' -1 "${FUNCNAME[0]}" "${RANDOM}" "${RANDOM}"
	self="${$}[[:space:]].+${FUNCNAME[0]}"
#	self="(${$}|${BASHPID})[[:space:]].+$0" # TODO figure out what's best

	ps w | tail -n +2 | grep -E -e "$pattern" -e "$marker" -- | grep -Evq -e "$marker" -e "$self" --
}

function get_process_owner {
	#
	# Usage: get_process_owner 'process_name'
	#

	# args and asserts

	(( $# == 1 )) || { errcho "invalid number of arguments: $#"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r process_name="$1"

	# code
	if is_process_running "$process_name"; then
		ps | awk "/$process_name/ && !/awk/ {print \$2}"
		# TODO: could be improved like 'PID=pidof; stat --owner /proc/PID' (pseudo-code)
	else
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi
}



#
# functions: SCREEN
#
#	is_screen_session_exist
#

function is_screen_session_exist {
	#
	# Usage: is_screen_session_exist ['screen_session name'] -> $?
	#
	# default screen session name is a current script basename
	#

	# args and asserts

	(( $# <= 1 )) || { errcho "invalid number of arguments: $#. only 0 or 1 argument allowed"; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r screen_session_name="${1:-$script_basename}"

	# code

	if (( script_DEBUG )); then
		screen -S "$screen_session_name" -X select .
	else
		screen -S "$screen_session_name" -X select . > /dev/null # silent
	fi
}



#
# functions: OTHER
#
#	set_variable_to_terminal_width
#

function set_variable_to_terminal_width {
	#
	# Usage: set_variable_to_terminal_width
	#

	# args and asserts

	(( $# == 1 ))	|| { errcho "invalid number of arguments: $#";				return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	[[ -n "$1" ]]	|| { errcho 'empty argument, must be a variable name';		return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -n variable_to_set="$1"

	# consts

	local -r -i terminal_width_DEFAULT='109' # the width of Hive OS 'remote command result' window

	# vars

	local COLUMNS

	# code

	if [[ -t 1 ]]; then # get $COLUMNS forcefully
		shopt -s checkwinsize
		cat /dev/null # poke the bash to get $COLUMNS and $LINES
		shopt -u checkwinsize
	#else
		# use default terminal width
	fi

	variable_to_set="${COLUMNS:-$terminal_width_DEFAULT}"
}



#
# the last: THE FUNCTION LISTER
#

function __list_functions {
	#
	# List all functions but started with '_'
	#

	# consts

	local -r private_function_attribute_RE='^_'
	local -r -i columns_spacing=2

	# vars

	local this_function_name
	local -a all_functions_ARR=() private_functions_ARR=() public_functions_ARR=()
	local -i public_functions_count
	local -i terminal_width max_name_length
	local -i columns_count this_column
	local -i rows_count this_row

	# code

	all_functions_ARR=( $( compgen -A function ) )

	for this_function_name in "${all_functions_ARR[@]}"; do
		# fill private/public arrays separately
		if [[ "${this_function_name}" =~ $private_function_attribute_RE ]]; then
			private_functions_ARR+=( "$this_function_name" )
		else
			public_functions_ARR+=( "$this_function_name" )
		fi
		# shellcheck disable=SC1073,SC1072,SC1105
		((
			${#this_function_name} > max_name_length ? max_name_length=${#this_function_name} : nil
		))                                         # nice ternary trick -- the fake "else" part ^^^
	done

	if (( ${#private_functions_ARR[@]} != 0 )); then
		echo "${#private_functions_ARR[@]} private function(s):"
		echo
		printf '%s\n' "${private_functions_ARR[@]}"
		echo
	fi

	#
	# TODO: are we fancy to make the separate function like print_array_in_columns()?
	# in other words, do we need such kind of function?
	#

	set_variable_to_terminal_width 'terminal_width'

	((
		columns_count = ( terminal_width / ( max_name_length + columns_spacing ) ),
		public_functions_count = ${#public_functions_ARR[@]}
	))

	# correct columns_count formula
	(( (max_name_length*(columns_count+1) + columns_spacing*columns_count ) < terminal_width )) && (( columns_count++ ))

	(( rows_count = ( public_functions_count + ( columns_count-1 ) ) / columns_count ))
	#                       note the ceiling ^^^^^^^^^^^^^^^^^^^^^

	echo "$public_functions_count public function(s):"
	echo
	for (( this_row = 0; this_row < rows_count; this_row++ )); do
		for (( this_column = 0; this_column < columns_count; this_column++ )); do
			(( this_element = this_row + ( this_column * rows_count ) )) # from top to bottom, then proceed to a next column
			printf '%-*.*s' "$max_name_length" "$max_name_length" "${public_functions_ARR[this_element]}"
			if (( this_column < columns_count-1 )); then
				# does print a spacing *between* the columns only
				printf '%-*.*s' "$columns_spacing" "$columns_spacing" ''
			fi
		done
		printf '\n'
	done
	echo
}



# consts

declare -r __audit_ok_string='I AM DOING FINE'

# shellcheck disable=SC2034
{
	# enum exit codes

	# common codes
	declare -r -i exitcode_OK=0
	declare -r -i exitcode_NOT_OK=1
	declare -r -i exitcode_ERROR_NOT_FOUND=1
	declare -r -i exitcode_ERROR_IN_ARGUMENTS=127
	declare -r -i exitcode_ERROR_SOMETHING_WEIRD=255

	# is_first_version_equal_to_second()
	declare -r -i exitcode_IS_EQUAL=0
	declare -r -i exitcode_GREATER_THAN=1
	declare -r -i exitcode_LESS_THAN=2

	# is_tcp_port_listening()
	declare -r -i exitcode_PORT_IS_OPENED=0
	declare -r -i exitcode_PORT_IS_CLOSED=1
	declare -r -i exitcode_ERROR_HOST_NOT_FOUND=3

	# regular expressions

	declare -r positive_integer_RE='^[[:digit:]]+$'
	declare -r empty_line_RE='^[[:space:]]*$'
}


# main

if ! ( return 0 2>/dev/null ); then # not sourced

	declare -r script_mission="$hive_functions_lib_mission"
	declare -r script_version="$hive_functions_lib_version"

	case "$*" in
		'')
			source /hive/bin/colors
			print_script_version
			__list_functions
			;;
		*)
			if is_function_exist "$1"; then
				"$@" # potentially unsafe
				exit $? # do an explicit passing of the exit code
			else
				errcho "function '$1' is not defined"
				exit $(( exitcode_ERROR_SOMETHING_WEIRD ))
			fi
			;;
	esac
fi
