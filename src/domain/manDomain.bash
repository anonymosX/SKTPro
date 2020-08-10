#!/bin/bash
PATH=/etc/skt.d/tool/domain
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
	sh $PATH/regDomain.bash
elif [ $OPTION = 2 ]; then
	clear
	sh $PATH/renewDomain.bash
elif [ $OPTION = 3 ]; then
	clear
	sh $PATH/statusDomain.bash
else
	clear
	sh $PATH/manDomain.bash
fi