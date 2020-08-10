#!/bin/bash
printf " ----------------------\n"
printf "      DOMAIN MANAGE\n"
printf " ----------------------\n"
printf "OPTIONS:\n"
printf " 1. REG DOMAIN\n"
printf " 2. RENEW DOMAIN\n"
printf " 3. STATUS DOMAIN\n"
printf " 4. DEPOSIT BALANCE\n"
read OPTION


if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh /etc/skt.d/tool/domain/regDomain.bash
elif [ $OPTION = 2 ]; then
	clear
	sh /etc/skt.d/tool/domain/renewDomain.bash
elif [ $OPTION = 3 ]; then
	clear
	sh /etc/skt.d/tool/domain/statusDomain.bash
else
	clear
	sh /etc/skt.d/tool/domain/manDomain.bash
fi