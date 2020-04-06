#
# Hive OS Client for ASICs: bash library
#


#
# under the hood
#

function print_script_version {
	echo -e "${YELLOW-}${script_mission}, version ${script_version}${NOCOLOR-}"
	echo
}

function errcho {
	# uniform error logging to stderr
	echo -e "${RED-}Error in ${BRED-}$0${RED-}:${BRED-}${FUNCNAME[1]}${RED-}:${NOCOLOR-} $@"
} 1>&2


#
# conditionals
#

function iif {
	#
	# Usage: iif flag cmd [arg...]
	#
	# if true (flag==1), runs cmd
	#

	# args

	(( $# < 2 )) && return $(( exitcode_ERROR_IN_ARGUMENTS ))
	local -r -i condition="${1-}"
	local -r -a cmd=( "${@:2}" )

	# code

	if (( condition )); then
		"${cmd[@]}" # execute a command
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

	(( $# < 2 )) && return $(( exitcode_ERROR_IN_ARGUMENTS ))
	local -r -i condition="${1-}"
	local -r -a cmd=( "${@:2}" )

	# code

	if (( condition )); then
		"${cmd[@]}" # execute a command
	else
		cat - # pass stdin to stdout
	fi
}


#
# math
#

function calculate_percent_from_number {
	#
	# Usage: calculate_percent_from_number 'percent' 'number'
	#
	# gives result rounded to *nearest* integer, not the frac part as in the bash builtin arithmetics
	#

	# args

	(( $# != 2 )) && return $(( exitcode_ERROR_IN_ARGUMENTS ))
	local -r -i percent=${1-}
	local -r -i number=${2-}

	# code

	printf '%.0f\n' "$((10**9 * (number * percent) / 100 ))e-9" # yay, neat trick
}


#
# files
#

function get_file_last_modified_time_in_seconds {
	#
	# Usage: get_file_last_modified_time_in_seconds 'file_name'
	#

	# args

	(( $# != 1 )) && return $(( exitcode_ERROR_IN_ARGUMENTS ))
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
	# highly portable, uses ls
	#

	# args

	(( $# != 1 )) && return $(( exitcode_ERROR_IN_ARGUMENTS ))
	local -r file_name="${1-}"

	# arrays

	local -a ls_output_field=()

	# code

	# parse ls output to array
	# -rwxr-xr-x 1 0 0 4745 Apr  3 16:03 log-watcher.sh
	# 0          1 2 3 4    5    6 7     8
	if [[ -f "$file_name" ]] && ls_output_field=( $( ls -dn "$file_name" ) ); then
		# print 5th field
		echo "${ls_output_field[4]}"
	else
		errcho "$file_name not found"
		return $(( exitcode_ERROR_NOT_FOUND ))
	fi
}


#
# date & time
#

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

	(( $# != 1 )) && return $(( exitcode_ERROR_IN_ARGUMENTS ))
	local -r -n variable_to_set_by_ref="${1-}" # get var by ref

	# code

	variable_to_set_by_ref="$( get_current_system_time_in_seconds )"
}

function seconds2dhms {
	#
	# Usage: seconds2dhms 'time_in_seconds' ['delimiter']
	#
	# Renders time_in_seconds to 'XXd XXh XXm[ XXs]' string
	# Default delimiter = ' '
	#

	# args

	(( $# < 1 || $# > 2 )) && return $(( exitcode_ERROR_IN_ARGUMENTS ))
	local -i -r time_in_seconds="${1#-}" # strip sign, get ABS
	local -r delimiter_DEFAULT=' '
	local -r delimiter="${2-${delimiter_DEFAULT}}"

	# consts

	local -i -r days="$(( time_in_seconds / 60 / 60 / 24 ))"
	local -i -r hours="$(( time_in_seconds / 60 / 60 % 24 ))"
	local -i -r minutes="$(( time_in_seconds / 60 % 60 ))"
	local -i -r seconds="$(( time_in_seconds % 60 ))"

	# code

	(( days > 0 ))					&&	printf '%ud%s'	"$days" "$delimiter"
	(( hours > 0 ))					&&	printf '%uh%s'	"$hours" "$delimiter"
	(( minutes > 0 ))				&&	printf '%um%s'	"$minutes"
	(( minutes > 0 && days < 1 ))	&&	printf '%s'	"$delimiter"
	(( days < 1 ))					&&	printf '%us'	"$seconds" # no seconds if days > 0
										printf '\n'
}

function format_date_in_seconds {
	#
	# Usage: format_date_in_seconds 'time_in_seconds' ['date_format']
	#
	# 'date_format' as in strftime(3) OR special 'dhms' format
	#

	# args

	(( $# < 1 || $# > 2 )) && return $(( exitcode_ERROR_IN_ARGUMENTS ))
	local -i -r time_in_seconds="${1#-}" # strip sign, get ABS
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


# consts

declare -r -i exitcode_ERROR_IN_ARGUMENTS=128
declare -r -i exitcode_ERROR_NOT_FOUND=1
