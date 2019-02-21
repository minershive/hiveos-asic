#!/usr/bin/env sh

if [ -e "/usr/bin/compile_time" ]; then
    which sshpass > /dev/null || (echo -e "${RED}sshpass${NOCOLOR} is required, upgrade hiveos client to latest version: selfupgrade" && exit 1)
else
    which sshpass > /dev/null || (echo -e "${RED}sshpass${NOCOLOR} is required, try apt-get install sshpass" && exit 1)
    which curl > /dev/null || (echo -e "${RED}sshpass${NOCOLOR} is required, try apt-get install curl" && exit 1)
fi

mkdir -p /tmp/hive-bulk-install
cd /tmp/hive-bulk-install
curl -L --insecure -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/config.txt
curl -L --insecure -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/ips.txt
curl -L --insecure -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/install.sh
curl -L --insecure -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/ipscan.sh
curl -L --insecure -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/firmware.sh
curl -L --insecure -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/setup.sh
curl -L --insecure -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/firmware-upgrade
chmod +x install.sh
chmod +x ipscan.sh
chmod +x firmware.sh
chmod +x setup.sh
chmod +x firmware-upgrade

