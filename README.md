# hiveos-asic
Hive OS monitoring client for ASICs.

>To link ASIC to your farm you could use these options, sorted by ease:
>1. *Hive OS* tab in the ASIC web interface (simpliest!)
>1. ```firstrun``` command via ```ssh```
>1. download a special *.tar.gz* file via BTC Tools (mass deployment)
>
>In all cases, you'll need the *FARM_HASH* string. You will find it in Hive OS dashboard, right in the farm's *Settings* tab.

> To start mining, be sure to create a *Flight Sheet* first.

&nbsp;

## Table of contents
1. [Supported models](#supported-models)
1. [Installation](#installation)
1. [Other models](#other-models)
1. [Recovery images](#recovery-images)
1. [Handy commands](#handy-commands)

&nbsp;

## Supported models
- Antminer
  - A3
  - B3
  - D3, D3 (Blissz)
  - DR3
  - E3
  - L3+, L3++
  - S7
  - S9, S9i, S9j, S9k, S9SE, S9-Hydro, S9 (VNISH), S9 (mskminer), S11
  - S15 \*\*
  - S17, S17 Pro \*\*
  - T9, T9+
  - T15 \*\*
  - T17 \*\*
  - X3
  - Z9, Z9-Mini
  - Z11
- Innosilicon
  - A5/A8 (need test)
  - A9 ZMaster
  - D9 DecredMaster
  - S11 SiaMaster
  - T3 BTCMiner
  - T3H+, T3+, T2Th+, T2Thf+, T2Thl+, T2Th, T2Tz-30T, T2Thm, T2Thf, T2T+ (32T), T2Ts-26T, T2Ti-25T, T2T-24T
- Zig
  - Z1, Z1+

&nbsp;

## Installation
You can install via firmware file download or via SSH.
```diff
- DO NOT upgrade your Antminer to firmware newer than 10.06.2019.
- This firmware is protected by Bitmain against changes.
```

&nbsp;

### Three basic install options
---

#### 1. ASIC web interface

Client for Antminer 3/7/9 series, firmware before 10.06.2019: [hive_install_unsig_antminers.tar.gz](http://download.hiveos.farm/asic/repo/unsig/hive_install_unsig_antminers.tar.gz)  

Stock Bitmain firmware + integrated Hive OS client + Hive OS tab on ASIC web interface (you need to enter your *FARM_HASH* there):\
  [Antminer S11](http://download.hiveos.farm/asic/repo/unsig/S11-hive.tar.gz)\
  [Antminer S15](http://download.hiveos.farm/asic/repo/unsig/S15-hive.tar.gz)\
  [Antminer S17](http://download.hiveos.farm/asic/repo/unsig/S17-hive.tar.gz)\
  [Antminer S17 Pro](http://download.hiveos.farm/asic/repo/unsig/S17pro-hive.tar.gz)\
  [Antminer T15](http://download.hiveos.farm/asic/repo/unsig/T15-hive.tar.gz)\
  [Antminer T17](http://download.hiveos.farm/asic/repo/unsig/T17-hive.tar.gz)

#### 2. BTC Tools

All things you do with an ASIC web interface you could do better with BTC Tools utility. It's the best choice in case you have ASICs in numbers.

#### 3. SSH

Login with SSH to your miner and run the following command:

```sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade
```

>For Antminer D3 **Blissz**, before installation run:
>
>```sh
>ln -s /usr/lib/libcurl-gnutls.so.4 /usr/lib/libcurl.so.5
>```

Force setup *FARM_HASH* or *RIG_ID* and password, change API Server URL:
   ```firstrun``` or ```firstrun YOUR_FARM_HASH``` - set when there is no config  
   ```firstrun -f``` or ```firstrun YOUR_FARM_HASH -f``` - force set to replace the config  

>##### Default SSH login and password:
>- Antminer: user **root**, password **admin**
>- Innosilicon (ssh/telnet): user **root**, password **blacksheepwall** (or **innot1t2**, or **t1t2t3a5**)

&nbsp;

### Options for automation 
---
#### Promptless installation

You can use *FARM_HASH* to add ASIC automatically without entering *RIG_ID* and password. Get your *FARM_HASH* and put it on the command line, ```FARM_HASH=$FARM_HASH```:
```sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=your_hash_from_web sh selfupgrade
```
Change API server, ```HIVE_HOST_URL=$HIVE_HOST_URL```:
```sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=your_hash_from_web HIVE_HOST_URL=http://api.exaple.com sh selfupgrade
```

#### Bulk installation

You can install Hive Client on all the ASICs you have on your local network. Or you can install firmware on Antminer S9, S9i, S9j. For this you need to have a running Linux box (like Hive OS on the GPU rig) or Antminer ASIC with Hive Client. Download files with this command:

```sh
apt-get install -y sshpass curl
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/download.sh && sh download.sh
cd /tmp/hive-bulk-install
```
Edit `config.txt` to set your *FARM_HASH* or firmware URL, edit `ips.txt` to set IPs list of your new ASICs.
Or you can scan the local network to search for Antminer. Example: ```ipscan.sh 192.168.0.1/24 > ips.txt```  

To install Hive just run ```install.sh```.\
To install firmware on Antminer S9/i/j just run ```firmware.sh```.

>- Optionally, you can add *WORKER_NAME* to `ips.txt` (e.g. `192.168.1.100 asic_01`)
>- When IP was being processed then it will become `#commented`.

&nbsp;

### Downgrade and Version change
---
If you want to install specific version or downgrade to specific version, please append version as an argument to ```selfupgrade```. E.g. 0.1-02:
```sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade 0.1-02
```

Locally on ASIC you can run ```selfupgrade``` command. 
To install specific version you should run ```selfupgrade 0.1-02```.
If you want to reinstall version please add ```-f``` to the command like this ```selfupgrade 0.1-02 -f```.
To install current development version from repository please run ```selfupgrade master```.

&nbsp;

### Uninstall
---
```sh
hive-uninstall
```
A `cron` jobs might have to be removed manually with ```crontab -e``` even if they are left there the would do nothing.

&nbsp;

## Other models
### Antminer S9 signed (deprecated)
[Manual](https://forum.hiveos.farm/t/antminer-s9-signed/12466)
### Antminer S17, S17 Pro, T17 (deprecated)
[Manual](https://forum.hiveos.farm/t/antminer-s17-t17/12415)

### Innosilicon new models
[Manual](https://forum.hiveos.farm/t/innosilicon-t2t-t3-series/13610)
### Innosilicon old models
Some Innosilicon factory firmware have a memory leak, and ASIC freezes every few days. To solve this problem, you can enable the miner or ASIC reboot for every 24 hours. Run the following commands:

```sh
inno-reboot miner enable/disable
inno-reboot asic enable/disable
inno-reboot status
```
### Zig Z1+
[Zig Z1+ ssh manual](hive/share/zig/README.md)

```sh
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && bash selfupgrade
```
or
```sh
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=replace_with_your_farm_hash bash selfupgrade
```

&nbsp;

## Recovery images

  ### Antminer

* [S9 Recovery image](https://download.hiveos.farm/asic/repo/fw/Antminer/recovery/Recovery_S9.img)
* S17, S17 Pro, T17: download [Recovery image](https://download.hiveos.farm/asic/repo/fw/Antminer/recovery/SD_S17-T17_650M.05.06.2019.zip), unzip to SD card. Boot ASIC with SD card. Flash `.tar.gz` firmware via web interface.

&nbsp;

## Handy commands

### Antminer ```asic-find```

To search for an Antminer ASIC among a large number of ASICs, you can make it flash a red LED on its front panel. To do this, execute the command from the Hive OS dashboard or via SSH:
```sh
asic-find 5
```
The red LED will be blinking for 5 minutes.

### Rename the workers

To rename the workers in the Hive web interface as the hostname, run the command from the Hive OS dashboard:
```sh
hello hostname
```
