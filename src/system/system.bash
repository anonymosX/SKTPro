#!/bin/bash
clear
printf "       -----------------------------\n"
printf "        VPS MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "OPTIONS: \n"
printf "1. INSTALL LEMP\n"
printf "2. UPDATE VPS\n"
printf "ENTER: "
read enter
if [ ${enter} = 0 ]; then
	sh /root/install
elif [ ${enter} = 1 ]; then
	sh /etc/skt.d/tool/system/lemp.bash
elif [ ${enter} = 2 ]; then
	yum update -y --skip-broken
else
	sh /etc/skt.d/tool/system/system.bash
fi