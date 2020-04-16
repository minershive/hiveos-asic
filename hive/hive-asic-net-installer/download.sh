#!/usr/bin/env sh


#
# Copyright (C) 2016-2020  Hiveon
# Distributed under GNU GENERAL PUBLIC LICENSE 2.0
# License information can be found in the LICENSE file or at https://github.com/minershive/hiveos-asic/blob/master/LICENSE
#


readonly script_mission='Hive OS Client for ASICs: Download bulk install scripts'
readonly script_version='1.0'


# consts

readonly bulk_install_dir='/tmp/hive-bulk-install'
readonly github_path='https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer'


# functions

print_script_version() {
	echo -e "${YELLOW-}${script_mission}, version ${script_version}${NOCOLOR-}"
	echo
}

is_on_busybox() {
    [ -f "/usr/bin/compile_time" ]
}


# code

print_script_version

if is_on_busybox; then
    which sshpass > /dev/null || ( echo -e "${CYAN}sshpass${NOCOLOR} is required, upgrade Hive OS Client to latest version: ${CYAN}selfupgrade${NOCOLOR}"; exit 1 )
else
    which sshpass > /dev/null || ( echo -e "${CYAN}sshpass${NOCOLOR} is required, try ${CYAN}apt-get install sshpass${NOCOLOR}"; exit 1 )
    which curl > /dev/null || ( echo -e "${CYAN}sshpass${NOCOLOR} is required, try ${CYAN}apt-get install curl${NOCOLOR}"; exit 1 )
fi

echo -e "Creating ${WHITE}${bulk_install_dir}...${NOCOLOR}"

mkdir -p "$bulk_install_dir" || ( echo -e "${RED}ERROR${NOCOLOR}"; exit 1 )
cd "$bulk_install_dir"

for file in config.txt ips.txt install.sh ipscan.sh firmware.sh setup.sh firmware-upgrade ipscan_model.sh firmware-L3.sh firmware-upgrade-L3; do
	echo -e "${NOCOLOR}Downloading ${WHITE}$file...${DGRAY}"
	if ! curl -L --insecure -O "${github_path}/$file"; then
		fail=1
		echo -e -n "${DGRAY}"
		break
	fi
	echo
done

if [ -z "$fail" ]; then
	for file in install.sh ipscan.sh firmware.sh setup.sh firmware-upgrade ipscan_model.sh; do
		chmod +x "$file"
	done
	echo -e "${GREEN}Done.${NOCOLOR} All files downloaded to ${WHITE}${bulk_install_dir}${NOCOLOR}."
else
	echo -e ${RED}"Something bad happen.${NOCOLOR}"
fi
