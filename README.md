# hiveos-asic
Hive OS client for ASICs

Supported ASICs:
* Antminer S9/S9i
* Antminer L3+/L3++
* Antminer D3
* Antminer A3
* Antminer T9+
* Antminer Z9/Z9-Mini
* Antminer X3
* Antminer E3
* Innosilicon A9 ZMaster
* Innosilicon D9 DecredMaster
* Innosilicon S11 SiaMaster



## Installation
[Video tutorial](https://asciinema.org/a/OZpbFSomhjvOkXlctEVIh7RQZ)
Default SSH login and password:
Antminer: **root:admin**
Innosilicon: **root:blacksheepwall**
Login with SSH to your miner and run the following command
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade
```
For Antminer D3 **Blissz**, before installation run:
```
ln -s /usr/lib/libcurl-gnutls.so.4 /usr/lib/libcurl.so.5
```

## Promptless installation
You can use FARM_HASH to add ASIC automatically without entering rig id and password. Get your hash and put it on the commandline.
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=your_hash_from_web sh selfupgrade
```

## Bulk installation
You can install Hive on all the ASICs you have on your local network.
For this you need to have running Linux computer (maybe Hive OS on GPU rig), download files from 
https://github.com/minershive/hiveos-asic/tree/master/hive/hive-asic-net-installer
```sh
cd /tmp
wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/config.txt
wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/ips.txt
wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/install.sh
chmod +x install.sh
```
Edit `config.txt` to set your FARM_HASH, edit `ips.txt` to set IPs list of your new ASICs.
Then run just run `install.sh`. If IP was connected then it will become commented in file.


## Downgrade and Version changing

If you want to install specific version or downgrade please append version as an argument to selfupgrade. E.g. 0.1-02
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade 0.1-02
```

Locally on ASIC you can run ```selfupgrade``` command. 
To install specific version you should run ```selfupgrade 0.1-02```.
If you want to reinstall version please add ```-f``` to the command like this ```selfupgrade 0.1-02 -f```.
To install current development version from repository please run ```selfupgrade master```.

**To display data in monitoring, be sure to create a flight sheet.**

## Uninstall
``` sh
hive-uninstall
```
Maybe cron jobs have to removed manually with `crontab -e` even if they are left there the would do nothing.

## Innosilicon
Some innosilicon factory firmware have a memory leak, and asic freezes every few days. To solve this problem, you can enable the miner or asic reboot every 24 hours.
Run the following commands:
``` sh
inno-reboot miner enable/disable
inno-reboot asic enable/disable
inno-reboot status
```


