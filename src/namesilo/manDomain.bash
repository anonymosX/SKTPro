#!/bin/bash
printf " ----------------------\n"
printf "      DOMAIN MANAGE\n"
printf " ----------------------\n"
printf "OPTIONS:\n"
printf " 1. Register\n"
printf " 2. Renew Domain\n"
printf " 3. Check Exp\n"
printf " 4. New Account\n"
printf " 5. Update API\n"
printf "ENTER: "
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
elif [ $OPTION = 5 ]; then
	clear
	sh /etc/skt.d/tool/namesilo/updateAPI.bash
else
	clear
	sh /etc/skt.d/tool/namesilo/manDomain.bash
fi
