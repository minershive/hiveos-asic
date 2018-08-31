# hiveos-asic
Hive OS client for ASICs

Supported ASICs:
* Antminer S9
* Antminer S9i
* Antminer L3+
* Antminer L3++
* Antminer D3
* Antminer A3
* Antminer T9+
* Antminer Z9-Mini
* Antminer X3
* Innosilicon A9 ZMaster



## Installation
Login with SSH to your miner and run the following command
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade
```
For Antminer D3 Blissz, before installation run:
```
ln -s /usr/lib/libcurl-gnutls.so.4 /usr/lib/libcurl.so.5
```

## Promptless installation
You can use FARM_HASH to add ASIC automatically without entering rig id and password. Get your hash and put it on the commandline.
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && FARM_HASH=your_hash_from_web sh selfupgrade
```


## Downgrade and Version changing

If you want to install specific version or downgrade please append version as an argument to selfupgrade. E.g. 0.1-02
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade 0.1-02
```

Locally on ASIC you can run ```selfupgrade``` command. 
To install specific version you should run ```selfupgrade 0.1-02```.
If you want to reinstall version please add ```-f``` to the command like this ```selfupgrade 0.1-02 -f```.
To install current development version from repository please run ```selfupgrade master```.

## Uninstall
``` sh
rm -rf /hive
rm -rf /hive-config
reboot
```
Maybe cron jobs have to removed manually with `crontab -e` even if they are left there the would do nothing.
