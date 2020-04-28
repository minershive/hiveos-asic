#!/bin/sh

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/hive/bin:/hive/sbin

mkdir -p /tmp/_dump
cd /tmp/_dump

#model
[ -e "/usr/bin/compile_time" ] && cat /usr/bin/compile_time > model

#raw stats json
echo '{"command":"stats"}' | nc localhost 4028 | tr -d '\0\n' > raw_stats.json

#raw pools json
echo '{"command":"pools"}' | nc localhost 4028 | tr -d '\0\n' > raw_pools.json


#raw api
if which "cgminer-api" > /dev/null; then
    cgminer-api -o stats > cgminer_stats.api
    cgminer-api -o pools > cgminer_pools.api
elif which "bmminer-api" > /dev/null; then
    bmminer-api -o stats > bmminer_stats.api
    bmminer-api -o pools > bmminer_pools.api
fi

df -h > system
echo >> system
mount >> system
echo >> system
ls -la / >> system
echo >> system
ls -la /var/log/ >> system
echo >> system

#