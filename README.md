# hiveos-asic
Hive OS client for ASICs

Supported ASICs:
* Antminer S9*/S9i/S9j/S9-Hydro/S9(VNISH)/S9(mskminer)/S11
* Antminer S17/S17 Pro **
* Antminer T17 **
* Antminer S15 **
* Antminer T15 **
* Antminer L3+/L3++
* Antminer D3/D3(Blissz)
* Antminer DR3
* Antminer A3
* Antminer T9/T9+
* Antminer Z9/Z9-Mini
* Antminer X3
* Antminer E3
* Antminer B3
* Antminer S7
* Antminer Z11
* Innosilicon A9 ZMaster
* Innosilicon D9 DecredMaster
* Innosilicon S11 SiaMaster
* Innosilicon T3 BTCMiner
* Innosilicon A5/A8 (need test)
* Zig Z1/Z1+



## Installation
[Video tutorial](https://asciinema.org/a/OZpbFSomhjvOkXlctEVIh7RQZ)

Default SSH login and password:

Antminer - default user:**root**  default password:**admin**

Innosilicon - default (ssh/telnet) user:**root**  default password:**blacksheepwall** or **innot1t2** or **t1t2t3a5**

Login with SSH to your miner and run the following command
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade
```
For Antminer D3 **Blissz**, before installation run:
```
ln -s /usr/lib/libcurl-gnutls.so.4 /usr/lib/libcurl.so.5
```
Force setup FARM_HASH or RIG ID and password, change api url:

   ```firstrun``` or ```firstrun FARM_HASH``` - set when there is no config  
   ```firstrun -f``` or ```firstrun FARM_HASH -f``` - force set to replace the config  


## Promptless installation
You can use FARM_HASH to add ASIC automatically without entering rig id and password. Get your hash and put it on the commandline.
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=your_hash_from_web sh selfupgrade
```

## Bulk installation
You can install Hive on all the ASICs you have on your local network. Or you can install firmware on Antminer S9/i/j.
For this you need to have running Linux computer (maybe Hive OS on GPU rig) or Antminer ASIC with hive client, download files with this command 
```sh
apt-get install -y sshpass curl
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/download.sh && sh download.sh
cd /tmp/hive-bulk-install
```
Edit `config.txt` to set your FARM_HASH or firmware URL, edit `ips.txt` to set IPs list of your new ASICs.
Or you can scan the local network to search for Antminer. Example: `ipscan.sh 192.168.0.1/24 > ips.txt`  
Optionally, you can add WORKER_NAME to `ips.txt` (e.g. `192.168.1.100 asic_01`)  
   To install hive just run `install.sh`.  
   To install firmware on Antminer S9/i/j just run `firmware.sh`.  
   If IP was connected then it will become commented in file.  


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

## asic-find (Antminer)
To search for an Antminer ASIC among a large number of ASICs, you can flash a red LED on it. To do this, execute the command via the web interface or via SSH:
``` sh
asic-find 5
```
Example: 'asic-find 15' the red LED will blinking for 15 minutes

## rename asics
To rename the workers in the Hive web interface as the hostname, run the command from the web interface:
``` sh
hello hostname
```

## Zig Z1+
[Zig Z1+ ssh manual](hive/share/zig/README.md)

``` sh
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && bash selfupgrade
```
or
``` sh
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=your_hash_from_web bash selfupgrade
```

## Antminer S9 signed
[Manual](https://forum.hiveos.farm/t/antminer-s9-signed/12466)

## Antminer S17/S17 Pro/T17
[Manual](https://forum.hiveos.farm/t/antminer-s17-t17/12415)
[Support](mailto:bee@hiveos.farm)

