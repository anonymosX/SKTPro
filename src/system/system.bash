#!/bin/bash
clear
printf "       -----------------------------\n"
printf "        SYSTEM MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS\n"
printf "       -----------------------------\n"
printf "OPTIONS: \n"
printf "1. INSTALL LEMP\n"
printf "2. CLEAR MEMCACHED\n"
printf "3. UPDATE VPS\n"
printf "ENTER: "
read OPTION
if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh /etc/skt.d/tool/system/lemp.bash
elif [ $OPTION = 2 ]; then
	clear
	echo flush_all > /dev/tcp/127.0.0.1/11211
	printf "CLEAR SUCCESFUL\n"
	sh /etc/skt.d/tool/system/system.bash
elif [ $OPTION = 3 ]; then
	clear
	yum update -y --skip-broken
else
	clear
	sh /etc/skt.d/tool/system/system.bash
fi