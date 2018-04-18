# hiveos-asic
Hive OS client for ASICs

Supported ASICs:
* Antminer S9
* Antminer L3+
* Antminer D3
* Antminer A3



## Installation
Login with SSH to your miner and run the following command
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade
```

If you want to install specific version or downgrade please append version as an argument to selfupgrade. E.g. 0.1-02
``` sh
cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && sh selfupgrade 0.1-02
```


Locally on ASIC you can run ```selfupgrade``` command. 
To install specific version you should run ```selfupgrade 0.1-02```.
If you want reinstall version please ```-f``` to the command like this ```selfupgrade 0.1-02 -f```.
To install current development version from repository please run ```selfupgrade master```.

## Uninstall
``` sh
rm -rf /hive
rm -rf /hive-config
reboot
```
Maybe cron jobs have to removed manually with `crontab -e` even if they are left there the would do nothing.
