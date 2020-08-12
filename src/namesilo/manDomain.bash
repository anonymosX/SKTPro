#!/bin/bash
printf " ----------------------\n"
printf "      DOMAIN MANAGE\n"
printf " ----------------------\n"
printf "OPTIONS:\n"
printf " 1. REGISTER\n"
printf " 2. RENEW\n"
printf " 3. STATUS\n"
printf " 4. NEW NAMESILO ACCOUNT\n"
read OPTION


if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh /etc/skt.d/tool/namesilo/regDomain.bash
elif [ $OPTION = 2 ]; then
	clear
	sh /etc/skt.d/tool/namesilo/renewDomain.bash
elif [ $OPTION = 3 ]; then
	clear
	sh /etc/skt.d/tool/namesilo/statusDomain.bash
elif [ $OPTION = 4 ]; then
	clear
	sh /etc/skt.d/tool/namesilo/newAccount.bash
else
	clear
	sh /etc/skt.d/tool/namesilo/manDomain.bash
fi
