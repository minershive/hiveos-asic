# Hive OS Client for ASICs
Simple yet powerful monitoring agent.

**Are you looking for a simple (and pretty fast) way to connect your miners to Hiveon? Please visit [ASIC Hub](https://hiveos.farm/asichub/) page first**

&nbsp;

## Table of contents
1. [Introduction](#introduction)
1. [Hive OS Client and Hiveon ASIC Firmware comparison](#hive-os-client-and-hiveon-asic-firmware-comparison)
1. [Supported models](#hive-os-client-supported-models)
1. [Prepare](#prepare)
1. [Install](#install)
1. [Other models](#other-models)
1. [Recovery boot images](#recovery-boot-images)
1. [Useful commands](#useful-commands)
1. [License](#license)

&nbsp;

## Introduction
*Hive OS Client* and *Hiveon ASIC Firmware* are two different products:

#### Hive OS Client (you are here)
- Allows you to see the miner in Hive, to control Wallets, Pools, restart and reboot the miner.
- Supports a broad range of ASIC models: Antminer, Innosilicon, Zig and even some FPGA miners.

It's a lightweight application running on the stock (or custom fw of your choice) ASIC firmware.

#### Hiveon ASIC Firmware ([follow the link](https://hiveos.farm/asic/))
All the features above plus:
- Overclocking, undervolting the miner, thus offering increased performance and/or lower consumption and heat.
- More control of overclocking and adjustment to voltage.
- Auto-tune to optimize overclocking almost automagically.

It's a *custom firmware* that does replace the stock one. Supports only selected models: **Antminer L3+, L3++, S10 (S9 Dual), S17, S17+, S17E, S17 Pro, T17, T17+, T17E, S9, S9i, S9j and T9+**. Hiveon Firmware for other ASIC models like S9k/S9SE are coming soon, so stay tuned!

Find out more: [Download](https://hiveos.farm/asic), [FAQ](https://hiveos.farm/hiveon-asic-firmware-general-asic_faq), [Step-by-step installation manual for S17/S17 Pro](https://medium.com/hiveon/hiveon-asic-firmware-installation-guide-s17-s17-pro-1d45a5d59a06)

&nbsp;

## *Hive OS Client* and *Hiveon ASIC Firmware* comparison

|Model / Feature|See miner in Hive OS|Control wallets & pools|Restart miner|Reboot miner|Anti-virus (Hiveon FW only)|Over clocking (Hiveon FW only)|Under volting (Hiveon FW only)|Voltage adjustment (Hiveon FW only)|Auto-tuning (Hiveon FW only)|
|-|-|-|-|-|-|-|-|-|-|
**Antminer**
|A3|•|•|•|•|
|B3|•|•|•|•|
|D3, D3 (Blissz)|•|•|•|•|
|DR3|•|•|•|•|
|E3|•|•|•|•|
|L3+, L3++|•|•|•|•|•|•|•|•|•|
|S7|•|•|•|•|
|S9, S9i, S9j|•|•|•|•|•|•|•|•|•|
|S9k, S9SE, S9-Hydro|•|•|•|•|soon|soon|soon|soon|soon|
|[S10 (S9 Dual mskminer)](#antminer-s9-mskminer-s10-mskminer)|•|•|•|•|•|•|•|•|•|
|S11|•|•|•|•|
|S15|•|•|•|•|
|S17, S17+, S17E, S17 Pro|•|•|•|•|•|•|•|•|•|
|T9|•|•|•|•|
|T9+|•|•|•|•|•|•|•|•|•|
|T15|•|•|•|•|
|T17, T17+, T17E|•|•|•|•|•|•|•|•|•|
|X3|•|•|•|•|
|Z9, Z9-Mini|•|•|•|•|
|Z11|•|•|•|•|
**DragonMint**
|DragonMint T1|•|•|•|•|
**HashAltCoin**
|Blackminer F1, F1+, F1-MINI|•|•|•|•|
|Blackminer F1-Ultra, F1-MINI+|•|•|•|•|
**Innosilicon**
|A5/A8 (need test)|•|•|•|•|
|A9 ZMaster|•|•|•|•|
|A9+ Zmaster|•|•|•|•|
|D9 DecredMaster|•|•|•|•|
|S11 SiaMaster|•|•|•|•|
|T3 BTCMiner|•|•|•|•|
|T3H+, T3+, T2Th+, T2Thf+, T2Thl+, T2Th, T2Tz-30T, T2Thm, T2Thf, T2T+ (32T), T2Ts-26T, T2Ti-25T, T2T-24T|•|•|•|•|
**Todek**
|Toddminer C1, C1 PRO|•|•|•|•|
**Zig**
|Z1, Z1+|•|•|•|•|

&nbsp;

## Hive OS Client supported models
- Antminer
  - A3
  - B3
  - D3, D3 (Blissz)
  - DR3
  - E3
  - L3+, L3++ *(please use [Hiveon firmware](https://hiveos.farm/asic/))*
  - S7
  - S9, S9i, S9j, S9k, S9SE, S9-Hydro, [S9 (mskminer)](#antminer-s9-mskminer-s10-mskminer), S11
  - [S10 (mskminer)](#antminer-s9-mskminer-s10-mskminer)
  - S15, T15
  - S17, S17+, S17E, S17 Pro *(please use [Hiveon firmware](https://hiveos.farm/asic/))*
  - T17, T17+, T17E *(please use [Hiveon firmware](https://hiveos.farm/asic/))*
  - T9, T9+
  - X3
  - Z9, Z9-Mini
  - Z11
- DragonMint
  - DragonMint T1
- HashAltCoin
   - Blackminer F1, Blackminer F1+, Blackminer F1-MINI
   - Blackminer F1-Ultra, Blackminer F1-MINI+
- Innosilicon
  - A5/A8 (need test)
  - A9 ZMaster
  - A9+ Zmaster
  - D9 DecredMaster
  - S11 SiaMaster
  - T3 BTCMiner
  - T3H+, T3+, T2Th+, T2Thf+, T2Thl+, T2Th, T2Tz-30T, T2Thm, T2Thf, T2T+ (32T), T2Ts-26T, T2Ti-25T, T2T-24T
- Todek
  - Toddminer C1, C1 PRO
- Zig
  - Z1, Z1+

&nbsp;

## Prepare

#### Beware of recent Bitmain firmware
```diff
- Antminer Series 9 (S9/S9i/S9j/T9/T9+): never upgrade to firmware newer than 10-Jun-2019
- Antminer Series 17: never upgrade to firmware newer than 01-Dec-2019
```
All newer versions of official firmware have defensive countermeasures against remote tampering, so you won't be able to install Hive OS Client or Hiveon ASIC Firmware.

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
You can install Hive OS Client via firmware file download or via SSH.

&nbsp;

### Three basic install options
---

#### 1. ASIC web interface

##### Antminer Series 15/17 and S9k / S9SE
These models are special. They're loading OS right to the RAM in read-only mode. Hive OS Client installation is possible only by upgrading ASIC with a special firmware file. That file contains stock Bitmain firmware with built-in Hive OS client:

- [Antminer S9k](https://download.hiveos.farm/asic/S9k/stock%2Bclient/S9k-stock%2Bclient-20190929.tar.gz)
- [Antminer S9SE](https://download.hiveos.farm/asic/S9se/stock%2Bclient/S9se-stok%2Bclient.tar.gz)

- [Antminer S11](https://download.hiveos.farm/asic/S11/stock%2Bclient/S11-hive.tar.gz)

- [Antminer S15](https://download.hiveos.farm/asic/S15/stock%2Bclient/S15-%28stock%2Bclient%29-v19.08.12-ln.tar.gz)
- [Antminer T15](http://download.hiveos.farm/asic/T15/stock%2Bclient/T15-%28stock%2Bclient%29-v19.08.12-ln.tar.gz)

- [Antminer S17, S17 pro](http://download.hiveos.farm/asic/s17/stock%2Bclient/)
- [Antminer S17+](http://download.hiveos.farm/asic/S17%2B/stock%2Bclient/)
- [Antminer S17E](http://download.hiveos.farm/asic/S17E/stock%2Bclient/)

- [Antminer T17](http://download.hiveos.farm/asic/T17/stock%2Bclient/)
- [Antminer T17+](http://download.hiveos.farm/asic/T17%2B/stock%2Bclient/)
- [Antminer T17E](http://download.hiveos.farm/asic/T17E/stock%2Bclient/)

>After successful flashing, you have to open up ASIC web interface, click *Hive OS* tab, enter your *FARM_HASH* and then click *Apply&Save* button. The page will refresh itself. Wait a minute and worker will appear in the Hive dashboard.

##### All other Antminer Series 3/7/9
Hive OS Client for Antminer Series 3/7/9, firmware date before 10.06.2019. Just upgrade ASIC firmware with [hive_install_unsig_antminers.tar.gz](http://download.hiveos.farm/asic/repo/unsig/hive_install_unsig_antminers.tar.gz).

#### 2. BTC Tools

All things you do with an ASIC web interface you could do better with [BTC Tools](https://url.btc.com/btc-tools-download) utility. It's the best choice in case you have ASICs in numbers. Scan your network, select ASICs to update and then click "Firmware Upgrade".

#### 3. SSH

Login with SSH to your miner and run the following command:

```sh
cd /tmp && curl -kLsO https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade
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
>- DragonMint T1: user **root**, password **dr4g0nhash**
>- Innosilicon (ssh **OR** telnet on port 8100): user **root**, password **blacksheepwall** (or **innot1t2**, or **t1t2t3a5**)

&nbsp;

### Options for automation 
---
#### Promptless installation

You could add ASIC without entering *RIG_ID*, password and *API Server URL*.

##### To add ASIC without entering *RIG_ID* and password, you should fill *FARM_HASH* variable.
Get your *FARM_HASH* from Hive OS dashboard. Replace `YOUR_FARM_HASH` string you see below with your *FARM_HASH*.  Transform the text below and then run as a single command:
 ```sh
cd /tmp && curl -kLsO https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade --farm-hash=YOUR_FARM_HASH
```

##### To use another *API Server*, you should fill *HIVE_HOST_URL* variable.
Replace `http://your_api_server` string you see below with your *API Server URL*. Transform the text below and then run as a single command:
```sh
cd /tmp && curl -kLsO https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade --hive-host-url=http://your_api_server
```

##### Of course you could set *FARM_HASH* and *API Server* simultaneously.
Replace `YOUR_FARM_HASH` string you see below with your *FARM_HASH*. Replace `http://your_api_server` string you see below with your *API Server URL*. Transform the text below and then run as a single command:
```sh
cd /tmp && curl -kLsO https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade --farm-hash=YOUR_FARM_HASH --hive-host-url=http://your_api_server
```

#### Bulk installation

You can install Hive OS Client on all the ASICs you have on your local network. For this you need to have a running Linux box (like Hive OS GPU rig) or Antminer ASIC with Hive OS Client. You could do it with just three commands.

1. **Skip this step if you're on the ASIC with Hive OS Client.** Install *sshpass* and *curl*:\
```apt-get install -y sshpass curl```
1. Download script:\
```cd /tmp && curl -kLsO https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/hive-asic-net-installer/download.sh && sh download.sh```
1. Execute it:\
```cd /tmp/hive-bulk-install```

Edit `config.txt` to set your *FARM_HASH* or firmware URL, edit `ips.txt` to set IPs list of your new ASICs.
Or you can scan the local network to search for Antminer. Example: ```ipscan.sh 192.168.0.1/24 > ips.txt```  

To install Hive OS Client just run ```install.sh```.\
To install firmware on Antminer S9/i/j just run ```firmware.sh```.

>- Optionally, you can add *WORKER_NAME* to `ips.txt` (e.g. `192.168.1.100 asic_01`)
>- When IP was being processed then it will become *#commented*

&nbsp;

### Downgrade and Version change
---
If you want to install specific version or downgrade to specific version, please append version as an argument to ```selfupgrade```. E.g. 0.1-02:
```sh
cd /tmp && curl -kLsO https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade 0.1-02
```

To see all selfupgrade options, run ```selfupgrade --help```

To install specific version you should provide a release number: ```selfupgrade 0.1-13```

If you want to reinstall current version, add ```--force```: ```selfupgrade --force```

To install stable development version, run ```selfupgrade master```

To install night build development version directly from Github, run ```selfupgrade master --github```

&nbsp;

### Uninstall
---
```sh
hive-uninstall
```
A `cron` jobs might have to be removed manually with ```crontab -e``` even if they are left there the would do nothing.

&nbsp;

## Other models
### Antminer S9 signed  *(please use [Hiveon firmware](https://hiveos.farm/asic/))*
[Hiveon ASIC installation - Antminer S9 Cannot Find Signature Fix](https://forum.hiveos.farm/t/hiveon-asic-installation-antminer-s9-cannot-find-signature-fix/12466)\
[Hiveon ASIC Firmware 1.02 for S9 Installation Manual](https://forum.hiveos.farm/t/hiveon-asic-s9-firmware-v1-02/13944)

### Antminer S9 (mskminer), S10 (mskminer)
You don't need to unlock SSH or do anything complicated. For any ASIC with mskminer custom firmware, you have to download [Hive OS Client Installer for mskminer firmware](http://download.hiveos.farm/asic/repo/s9/hive-msk-installer.tar.gz) and then flash the ASIC with it. That's all.

### Antminer S17, S17 Pro, T17
[Hiveon ASIC Firmware installation manual](https://hiveos.farm/hiveon-asic-firmware-S17-S17-Pro-s17installation)

### Innosilicon new models
[Hive OS Client Installation Manual for Innosilicon](https://forum.hiveos.farm/t/innosilicon-t2t-t3-series/13610)

### Innosilicon old models
Note: some Innosilicon factory firmware have a memory leak, and ASIC freezes every few days. To solve this problem, you can enable the miner or ASIC reboot for every 24 hours. Run the following commands:

```sh
inno-reboot miner enable/disable
inno-reboot asic enable/disable
inno-reboot status
```


### Todek Toddminer C1

```sh
sudo su -
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && bash selfupgrade
```
or, if you need to use FARM_HASH
```sh
sudo su -
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && bash selfupgrade --farm-hash=YOUR_FARM_HASH
```

&nbsp;

### Zig Z1 and Z1+
[Hive OS Client Installation Manual for Zig Z1+](hive/share/zig/README.md)

```sh
sudo su -
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && bash selfupgrade
```
or, if you need to use FARM_HASH
```sh
sudo su -
cd /tmp && wget https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && selfupgrade --farm-hash=YOUR_FARM_HASH
```

&nbsp;

### Blackminer F1 series by Hash Altcoin Technologies
FPGA miners based on Xilinx K7 325t (Gen1) and 420t (Gen2) which works like multialgo ASICs

Installation using FARM_HASH
```sh
cd /tmp && curl -kLsO https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade master --github --farm-hash=YOUR_FARM_HASH
```

&nbsp;

## Recovery boot images

### Antminer

You can find recovery boot images at [our repository](https://download.hiveos.farm/asic/) (highly recommended) or [Bitmain's official site](https://service.bitmain.com/support/download?product=Flashing%20SD%20card%20with%20image).

>Please note the two different file formats of recovery images:
>- `.img` file. It's a raw disk image. Should be written to SD with a special imaging software.
>- `.zip` file. A ZIP archive containing files like `u-boot.img` and `uImage.bin` inside. Unzip that file to SD card formatted with **FAT32**.

- [S9 Recovery image](https://download.hiveos.farm/asic/s9/recovery-stock/Recovery_S9.img)
- [S17 Hiveon recovery image (beta)](https://download.hiveos.farm/asic/s17/SD-S17-S17pro_Hiveon_1.01-200331_sig.zip)
- S17, S17 Pro, T17
  - Download [recovery boot image](https://download.hiveos.farm/asic/s17/recovery-stock/SD_S17-T17_650M.05.06.2019.zip)
  - Use SD card size less than **16 Gb**
  - Format SD card with **FAT32**
  - Unzip it to SD card
  - Boot ASIC with SD card
  - ASIC booted in recovery mode
  - Flash any suitable [old stock Bitmain firmware](https://download.hiveos.farm/asic/) (`.tar.gz` format) via web interface.

In case of issues, please read Bitmain's [control board program recovery manual](https://support.bitmain.com/hc/en-us/articles/360033757513-S17-S17Pro-S9-SE-S9k-Z11-control-board-program-recovery-SD-card-flashing-with-customized-PW-).

&nbsp;

## Useful commands

### ```agent-screen```
```
agent-screen start|stop|restart|log
```

### ```asic-find``` [Antminer]
To search for an Antminer ASIC among a large number of ASICs, you can make it flash a red LED on its front panel. To do this, execute the command from the Hive OS dashboard or via SSH: ```asic-find 5```. The red LED will be blinking for 5 minutes.

### ```asic-oc``` [Antminer]
Overclock profiles management
```
asic-oc status|factory|retune|clear-cache
```

### ```diag-17``` [Antminer]
Series 15/17 diagnostic

### ```hive-passwd``` [Antminer]
Change or show password for ssh and/or web UI
```
hive-passwd [new_password] [--show] [--default]
```

### ```message```
Send a message to Hive OS dashboard\
```message success|danger|warning|info "message"``` - send a message to the dashboard\
```message file /path/filename``` - send a file to the dashboard\
```message file.io|transfer.sh /path/filename``` - send a file to the file sharing service\
```message tag "tag_text"``` - tag a worker with any text. Inside the tag text you can use templates: ```%BUILD%```, ```%FW%```, ```%HOSTNAME%```, ```%IP%```, ```%IP_SAFE%```, ```%MAC%```, ```%MAC_SAFE%```, ```%PROFILE%```, ```%URL%``` and ```%WORKER_NAME_RAW%```

### ```miner```
```
miner start|stop|restart
miner log [all|kernel|watchdog]
```

### ```selfupgrade```
```
selfupgrade [master]
```

### ```ssh-access```
```
ssh-access status
```

### ```virus-check```
```
virus-check
```

### Rename the workers

To rename the workers in the Hive web interface as the hostname, run the command from the Hive OS dashboard:
```sh
hello hostname
```

&nbsp;

Note: almost all commands have a ```--help``` argument.

&nbsp;

## License

Hive OS Client for ASICs is released under Business Source License 1.1. See [LICENSE.txt](LICENSE.txt)
