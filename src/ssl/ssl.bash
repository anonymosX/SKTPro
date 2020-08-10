#!/bin/bash
printf "       -----------------------------\n"
printf "        SSL MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS\n"
printf "       -----------------------------\n"
printf "OPTIONS: \n"
printf "1. RENEW\n"
printf "2. CHECK\n"
printf "ENTER: "
read OPTION


if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh /etc/skt.d/tool/ssl/renew.bash
elif [ $OPTION = 2 ]; then
	clear
	sh /etc/skt.d/tool/ssl/status.bash
else
	clear
	sh /etc/skt.d/tool/ssl/ssl.bash
fi



