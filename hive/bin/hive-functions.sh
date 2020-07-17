#!/usr/bin/env bash


#
# Copyright (C) 2016-2020  Hiveon
# Distributed under GNU GENERAL PUBLIC LICENSE 2.0
# License information can be found in the LICENSE file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE.txt
#
# Linted by shellcheck 0.3.7
#


declare -r hive_functions_lib_mission='Client for ASICs: Oh my handy little functions'
declare -r hive_functions_lib_version='0.34.7'
#                                        ^^ current number of public functions


# !!! bash strict mode, no unbound variables

#set -o nounset # !!! this is a library, so we don't want to break the other's scripts


#
# functions: script infrastructure
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

	echo -e -n "${BRED-}$0"
	for (( i=${#FUNCNAME[@]} - 2; i >= 1; i-- )); { echo -e -n "${RED-}:${BRED-}${FUNCNAME[i]}"; }
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

	# code

	echo -e -n "${DGRAY-}DEBUG $0"
	for (( i=${#FUNCNAME[@]} - 2; i >= 1; i-- )); { echo -e -n ":${FUNCNAME[i]}"; }
	for this_argument in "$@"; do
		printf " %b'%b%q%b'" "${CYAN-}" "${DGRAY-}" "${this_argument}" "${CYAN-}"
	done
	echo "${NOCOLOR-}"

} 1>&2

function log_line {
	#
	# Usage: log_line 'ok|info|error|warning' 'log_entry'
	#

	# args

	(( $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __event_type="${1:-info}"
	local -r __log_entry="${2:-}"

	# consts

	local -r -A __event_color_dictionary=(
		['warning']="${YELLOW}"
		['error']="${RED}"
		['info']="${DGRAY}"
		['ok']="${GREEN}"
	)

	# code

	# wd			2 chars
	# agent			5
	# watchdog		8
	# controller	10

	# shellcheck disable=SC2154
	printf '%b%(%F %T)T %b%-10.10s%b %b%b\n' "${DGRAY}" -1 "${__event_color_dictionary[$__event_type]}" "$script_basename" "${NOCOLOR}" "$__log_entry" "${NOCOLOR}"
#	printf '%b%(%F %T)T %b%s%b %b%b\n' "${DGRAY}" -1 "${__event_color_dictionary[$__event_type]}" "$script_basename" "${NOCOLOR}" "$__log_entry" "${NOCOLOR}"
}


#
# functions: audit
#
# we need to audit externally--does the script work as intended or not (like the system returns exitcode "file not found")
# [[ $( script_to_audit ) != 'I AM FINE' ]] && echo "Something wrong with $script_to_check"
#

function print_i_am_doing_fine_then_exit () {
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

	(( $# != 1 )) && { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __script_name="${1-}"

	# code

	is_program_in_the_PATH "$__script_name" && [[ "$( "$__script_name" --audit )" == "$__audit_ok_string" ]]
}


#
# functions: conditionals
#

function iif {
	#
	# Usage: iif flag cmd [arg...]
	#
	# if true (flag==1), runs cmd
	#

	# args

	(( $# >= 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

	(( $# >= 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __program_name="$1"

	# code

	type -p "$__program_name" &> /dev/null
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

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __function_name="$1"

	# code

	declare -F -- "$__function_name" >/dev/null
}

function is_first_floating_number_bigger_than_second {
	#
	# Usage: is_first_floating_number_bigger_than_second 'first_number' 'second_number'
	#

	# args

	(( $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

	# args

	(( $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r string_to_check="${1-}"

	# consts

	# "Integer: A sequence of an optional sign (+ or -) followed by no more than 18 (significant) decimal digits."
	local -r integer_definition_RE='^([+-])?0*([0-9]{1,18})$'

	# code

	[[ "$string_to_check" =~ $integer_definition_RE ]]
}


#
# functions: text
#

function strip_ansi {
	#
	# Usage: strip_ansi 'text'
	#        cat file | strip_ansi
	#
	# strips ANSI codes from text
	#
	# < or $1: The text to strip
	# >: ANSI stripped text
	#

	# args

	(( $# <= 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r input_text="${1:-$( < /dev/stdin )}" # get from arg or stdin

	# vars

	local line=''

	# code

	while IFS='' read -r line || [[ -n "$line" ]]; do
		(
			shopt -s extglob
			printf '%s\n' "${line//$'\e'[\[(]*([0-9;])[@-n]/}"
		)
	done <<< "$input_text"
}


#
# functions: math
#

function calculate_percent_from_number {
	#
	# Usage: calculate_percent_from_number 'percent' 'number'
	#
	# gives result rounded to the *nearest* integer, not the frac part as in the bash builtin arithmetics
	#

	# args

	(( $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

	(( $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r -n variable_by_ref="${1-}"
	local -r -n bitmask_by_ref="${2-}"

	# code

	(( variable_by_ref |= bitmask_by_ref )) # bitwise OR
}

function scientific_to_decimal {
	#
	# Usage: scientific_to_decimal 'exponential_number'
	#

	# args

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r exponential_number="${1:-0}"

	# code

	printf "%.0f\n" "$exponential_number"
}

function big_decimal_to_human {
	#
	# Usage: big_decimal_to_human 'big_decimal_number' ['base_units']
	#

	# args

	(( $# == 1 || $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	big_decimal_number=${1:-0}
	base_units=${2:-}

	# vars

	local digits_after_period=''
	local -i magnitude_index=0
	local magnitude_char=( '' 'k' 'M' 'G' 'T' 'P' 'E' 'Y' 'Z' )

	# code

	while (( big_decimal_number > 1000 )); do
		printf -v digits_after_period ".%02d" $(( big_decimal_number % 1000 * 100 / 1000 ))
		(( big_decimal_number /= 1000, magnitude_index++ ))
	done

	[[ $digits_after_period =~ \.00 ]] && digits_after_period=''
	[[ $digits_after_period =~ \.[0-9]0 ]] && digits_after_period="${digits_after_period::-1}"
	echo "${big_decimal_number}${digits_after_period} ${magnitude_char[${magnitude_index}]}${base_units}"
}

function khs_to_human_friendly_hashrate {
	#
	# Usage: khs_to_human_friendly_hashrate 'hashrate_in_khs'
	#

	# args

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r hashrate_in_khs="${1:-0}"

	# vars

	local -i khs_decimal hs_decimal

	# code

	khs_decimal="$( scientific_to_decimal "$hashrate_in_khs" )"
	hs_decimal=$(( khs_decimal * 1000 ))

	big_decimal_to_human "$hs_decimal" 'H/s'
}


#
# functions: files
#

function get_file_last_modified_time_in_seconds {
	#
	# Usage: get_file_last_modified_time_in_seconds 'file_name'
	#

	# args

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r file_name="${1-}"

	# code

	if [[ -f "$file_name" ]]; then
		date -r "$file_name" '+%s'
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

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

	# args

	(( $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

function set_variable_in_file {
	#
	# Usage: set_variable_in_file 'file_with_variables' 'variable_to_change' 'new_value'
	#
	# if the variable isn't exist, add it to the end of file
	# if the variable is defined as empty, like 'var=', add a value to it

	# args

	(( $# == 3 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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
# functions: date & time
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

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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
	(( $# == 1 || $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

	(( $# == 1 || $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

function snore {
	#
	# Usage: snore 1
	#        snore 0.2
	#
	# pure bash 'sleep'
	# https://blog.dhampir.no/content/sleeping-without-a-subprocess-in-bash-and-how-to-sleep-forever

	# args

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r __sleep_time="${1-}"

	# vars

	local IFS # reset IFS in case it’s set to something weird

	# code

	# shellcheck disable=SC1083
	# because 'man bash':
	# Each redirection that may be preceded by a file descriptor number may instead be preceded by a word of the form {varname}.
	[[ -n "${__snore_fd:-}" ]] || exec {__snore_fd}<> <(:)
	read -r -t "${__sleep_time}" -u "$__snore_fd" || :
}


#
# functions: strings
#

function get_substring_position_in_string {
	#
	# Usage: get_substring_position_in_string 'substring' 'string'
	#

	# args

	(( $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
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

	(( $# == 1 || $# == 2 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }

	local -r regex="${1-}"
	local -r string="${2:-$( < /dev/stdin )}" # get from arg or stdin

	# code

	[[ $string =~ $regex ]]
	printf '%s\n' "${BASH_REMATCH[@]:1}"
}


#
# functions: processes
#

function pgrep_count {
	#
	# Usage: pgrep_count 'pattern'
	#
	# pgrep --count naive emulator
	#
	
	# args

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r pattern="$1"

	# vars

	local marker self

	# code

	printf -v marker '%(%s)T-%s-%u%u' -1 "$FUNCNAME" "${RANDOM}" "${RANDOM}"
#	self="${$}[[:space:]].+${FUNCNAME}" # TODO figure out what's best
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

	(( $# == 1 )) || { errcho 'invalid number of arguments'; return $(( exitcode_ERROR_IN_ARGUMENTS )); }
	local -r pattern="$1"

	# vars

	local marker self

	# code

	printf -v marker '%(%s)T:%s:%u%u' -1 "$FUNCNAME" "${RANDOM}" "${RANDOM}"
	self="${$}[[:space:]].+${FUNCNAME}"
#	self="(${$}|${BASHPID})[[:space:]].+$0" # TODO figure out what's best

	ps w | tail -n +2 | grep -E -e "$pattern" -e "$marker" -- | grep -Evq -e "$marker" -e "$self" --
}


#
# the last: functions lister
#

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


# main

if ! ( return 0 2>/dev/null ); then # not sourced

	declare -r script_mission="$hive_functions_lib_mission"
	declare -r script_version="$hive_functions_lib_version"

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
