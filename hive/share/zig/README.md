# Zig Z1/Z1+ ssh manual
Default ssh login credentials for the different firmware versions=username:password

Firmware 20180914=fa:fa

Firmware 20180930=pi:pi

Before installation run:
```sh
sudo su
```
Firmware 20180926 install cmd:
``` cd /tmp && curl -L --insecure -s -O https://raw.githubusercontent.com/minershive/hiveos-asic/master/hive/bin/selfupgrade && bash selfupgrade```

If credentials is incorrect, use this manual:

by Dakota at Minery.Tech

1. Pull the flash drive from the front of the unit and put in a computer you have root access on
2. Add a line to /etc/sudoers : `www-data ALL=(ALL:ALL) NOPASSWD: ALL`
3. change /etc/ssh/sshd_config to the following:

```sh
Port 22
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
```

4. Change the first line of /etc/passwd to
    `root:root:0:0:root:/root:/bin/bash`
5. Change the first line of /etc/shadow to
    `root::17802:0:99999:7:::`
6. Reinstall the flash drive in the miner and boot
7. When the web panel comes up, navigate to miner.address/phpbash.php
8. Run the following commands 
```sh
sudo systemctl enable ssh && sudo systemctl start ssh && sudo systemctl status ssh
echo "root:root"|sudo chpasswd
```


Ssh should now be accepting connections and the root credentials should be root:root
You may want to remove www-data from /etc/sudoers as it is a security risk, but not a security risk bigger than setting your root password to root.

