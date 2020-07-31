#!/bin/bash
clear
printf "       -----------------------------\n"
printf "        VPS MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "OPTIONS: \n"
printf "1. INSTALL LEMP\n"
printf "2. CLEAR MEMCACHED\n"
printf "3. UPDATE VPS\n"
printf "ENTER: "
read enter
if [ ${enter} = 0 ]; then
	sh /root/install
elif [ ${enter} = 1 ]; then
	sh /etc/skt.d/tool/system/lemp.bash
elif [ ${enter} = 2 ]; then
	echo flush_all > /dev/tcp/127.0.0.1/11211	
elif [ ${enter} = 3 ]; then
	yum update -y --skip-broken
else
	sh /etc/skt.d/tool/system/system.bash
fi