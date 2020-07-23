#!/bin/bash
printf "       -----------------------------\n"
printf "        SSL MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "OPTIONS: \n"
printf "1. RENEW\n"
printf "2. CHECK\n"
printf "ENTER: "
read enter
clear
if [ ${enter} = 0 ]; then
	sh /root/install
elif [ ${enter} = 1 ]; then
	sh /etc/skt.d/tool/ssl/renew.bash
elif [ ${enter} = 2 ]; then
	sh /etc/skt.d/tool/ssl/status.bash
else
	sh /etc/skt.d/tool/ssl/ssl.bash
fi



