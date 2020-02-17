# Hiveon ASIC Client
Hive OS monitoring client for ASICs.

&nbsp;

## Table of contents
1. [Introduction](#introduction)
1. [Supported models](#supported-models)
1. [Preparation](#preparation)
1. [Install](#install)
1. [Other models](#other-models)
1. [Recovery boot images](#recovery-boot-images)
1. [Useful commands](#useful-commands)

&nbsp;

## Introduction
Hiveon ASIC *Client* and Hiveon ASIC *Firmware* is a two different products:

- Hiveon ASIC Client (you are here) supports most of the ASIC models in the world
  - A convinient monitoring agent brought to you by the Hive Team
  - All your ASICs gathered in the same good old Hive dashboard
- Hiveon ASIC Firmware is a custom ASIC firmware from the Hive Team
  - It supports only selected models: Antminer S17, S17 Pro, S9, S9i, S9j and T9+
  - It has overclocking, undervolting and other cool features
  - Firmware for other ASIC models (like S9k/S9SE/T17) are coming soon, so stay tuned
  - Find out more: [Download](https://hiveos.farm/asic) and [FAQ](https://hiveos.farm/hiveon_asic_faq-general-asic_faq)
  - [Step-by-step installation manual for S17/S17 Pro](https://medium.com/hiveon/hiveon-asic-firmware-installation-guide-s17-s17-pro-1d45a5d59a06)

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
  - S15, S17, S17 Pro *(deprecated in favor of Hiveon firmware)*
  - T9, T9+
  - T15, T17 *(deprecated in favor of Hiveon firmware)*
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

## Preparation

#### Beware of recent Bitmain firmware
```diff
- Never upgrade your Antminer to firmware newer than 10.06.2019
```
All newer versions of official firmware have defensive countermeasures against remote tampering, so you won't be able to install Hive Client or Hiveon ASIC Firmware.

#### Get FARM_HASH
To link ASIC to your Hive Farm you could use these options, sorted by ease:
1. *Hive OS* tab in the ASIC web interface (simpliest!)
1. ```firstrun``` command via ```ssh```
1. Download a special *.tar.gz* file via BTC Tools (mass deployment)

In all cases, you'll need the *FARM_HASH* string. You will find it in Hive OS dashboard, right in the farm's *Settings* tab.

#### Create and Apply the Flight Sheet
To start mining, be sure to create a *Flight Sheet* first. Apply it to start hashing.

&nbsp;

## Install
You can install Hive Client via firmware file download or via SSH.

&nbsp;

### Three basic install options
---

#### 1. ASIC web interface

##### Antminer Series 15, Series 17 and models S9k, S9se
These models are special. They loading OS right to the RAM in read-only mode. Hive Client installation is possible only by flashing a special firmware. It contains Stock Bitmain firmware + integrated Hive OS client:
- [Antminer S11](http://download.hiveos.farm/asic/repo/unsig/S11-hive.tar.gz)
- [Antminer S15](http://download.hiveos.farm/asic/repo/unsig/S15-hive.tar.gz)
- [Antminer S17](http://download.hiveos.farm/asic/repo/unsig/S17-hive.tar.gz)
- [Antminer S17 Pro](http://download.hiveos.farm/asic/repo/unsig/S17pro-hive.tar.gz)
- [Antminer T15](http://download.hiveos.farm/asic/repo/unsig/T15-hive.tar.gz)
- [Antminer T17](http://download.hiveos.farm/asic/repo/unsig/T17-hive.tar.gz)

>After successful flashing, you have to open ASIC web interface, click *Hive OS* tab, enter your *FARM_HASH* and then click *Apply&Save* button.

##### All other Antminer 3/7/9 series
Client for Antminer 3/7/9 series, firmware before 10.06.2019. Just flash ASIC with [hive_install_unsig_antminers.tar.gz](http://download.hiveos.farm/asic/repo/unsig/hive_install_unsig_antminers.tar.gz).

#### 2. BTC Tools

All things you do with an ASIC web interface you could do better with [BTC Tools](https://url.btc.com/btc-tools-download) utility. It's the best choice in case you have ASICs in numbers. Scan your network, select ASICs to update and then click "Firmware Upgrade".

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

You could add ASIC without entering *RIG_ID*, password and *API Server URL*.

##### To add ASIC without entering *RIG_ID* and password, you should fill *FARM_HASH* variable.
Get your *FARM_HASH* from Hive OS dashboard. Replace '**your_farm_hash**' string you see below with your *FARM_HASH*.  Transform the text below and then run as a single command:
 ```sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH='your_farm_hash' sh selfupgrade
```

##### To use another *API Server*, you should fill *HIVE_HOST_URL* variable.
Replace '**http://your_api_server**' string you see below with your *API Server URL*. Transform the text below and then run as a single command:
```sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && HIVE_HOST_URL='http://your_api_server' sh selfupgrade
```

##### Of course you could set *FARM_HASH* and *API Server* simultaneously.
Replace '**your_farm_hash**' string you see below with your *FARM_HASH*. Replace '**http://your_api_server**' string you see below with your *API Server URL*. Transform the text below and then run as a single command:
```sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH='your_farm_hash' HIVE_HOST_URL='http://your_api_server' sh selfupgrade
```

#### Bulk installation

You can install Hive Client on all the ASICs you have on your local network. Or you can install firmware on Antminer S9, S9i, S9j. For this you need to have a running Linux box (like Hive OS on the GPU rig) or Antminer ASIC with Hive Client. You could do it with just three commands.

1. **Skip this step if you're on the ASIC with Hive Client.** Install *sshpass* and *curl*:\
```apt-get install -y sshpass curl```
1. Download script:\
```cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/download.sh && sh download.sh```
1. Execute it:\
```cd /tmp/hive-bulk-install```

Edit `config.txt` to set your *FARM_HASH* or firmware URL, edit `ips.txt` to set IPs list of your new ASICs.
Or you can scan the local network to search for Antminer. Example: ```ipscan.sh 192.168.0.1/24 > ips.txt```  

To install Hive just run ```install.sh```.\
To install firmware on Antminer S9/i/j just run ```firmware.sh```.

>- Optionally, you can add *WORKER_NAME* to `ips.txt` (e.g. `192.168.1.100 asic_01`)
>- When IP was being processed then it will become *#commented*

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
### Antminer S9 signed *(deprecated in favor of Hiveon firmware)*
[Hiveon ASIC installation - Antminer S9 Cannot Find Signature Fix](https://forum.hiveos.farm/t/hiveon-asic-installation-antminer-s9-cannot-find-signature-fix/12466)

[Hiveon ASIC Firmware 1.02 for S9 Installation Manual](https://forum.hiveos.farm/t/hiveon-asic-s9-firmware-v1-02/13944)

### Antminer S17, S17 Pro, T17 *(deprecated in favor of Hiveon firmware)*
[Hive Client Installation Manual for S17/T17](https://forum.hiveos.farm/t/antminer-s17-t17/12415)

### Innosilicon new models
[Hive Client Installation Manual for Innosilicon](https://forum.hiveos.farm/t/innosilicon-t2t-t3-series/13610)

### Innosilicon old models
Note: some Innosilicon factory firmware have a memory leak, and ASIC freezes every few days. To solve this problem, you can enable the miner or ASIC reboot for every 24 hours. Run the following commands:

```sh
inno-reboot miner enable/disable
inno-reboot asic enable/disable
inno-reboot status
```

### Zig Z1+
[Hive Client Installation Manual for Zig Z1+](hive/share/zig/README.md)

```sh
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && bash selfupgrade
```
or
```sh
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=replace_with_your_farm_hash bash selfupgrade
```

&nbsp;

## Recovery boot images

### Antminer

You can find recovery boot images at [Bitmain's official repository](https://service.bitmain.com/support/download?product=Flashing%20SD%20card%20with%20image).

>Pease note the two different file formats of images.
>-`.img` file, must be written to SD with a special imaging software
>-`.zip` file containing files like `u-boot.img` and `uImage.bin` inside, must be unzipped to SD card formatted with **FAT32**

- [S9 Recovery image](https://download.hiveos.farm/asic/repo/fw/Antminer/recovery/Recovery_S9.img)
- S17, S17 Pro, T17
  - Download [recovery boot image](https://download.hiveos.farm/asic/repo/fw/Antminer/recovery/SD_S17-T17_650M.05.06.2019.zip)
  - Use SD card <16 Gb
  - Format SD card with FAT32
  - Unzip it to SD card
  - Boot ASIC with SD card
  - ASIC booted in recovery mode
  - Flash any suitable [old stock Bitmain firmware](https://download.hiveos.farm/asic/) (`.tar.gz` format) via web interface.

In case of issues, please read Bitmain's [control board program recovery manual](https://support.bitmain.com/hc/en-us/articles/360033757513-S17-S17Pro-S9-SE-S9k-Z11-control-board-program-recovery-SD-card-flashing-with-customized-PW-).

&nbsp;

## Useful commands

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
