#!/bin/bash
printf " ------------------------------------\n"
printf " NEW NAMESILO ACCOUTN | DOMAIN MANAGE\n"
printf " ------------------------------------\n"

if [ ! -d /etc/skt.d/data/namesilo ]; then
	mkdir -p /etc/skt.d/data/namesilo
fi
printf "INFORMATION: \n"
printf "Number Account: "
read NUMBER
printf "API: "
read API
printf "CONFIRM NEW NAMESILO ACCOUNT?\n"
printf " - NAMESILO $NUMBER, API: $API\n"
printf "YES/NO - (Y/N): "
read CONFIRM
if   [ $CONFIRM = 0 ]; then
	clear ; sh /root/install

# INSERT NEW ACCOUNT
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'n' ]; then
	clear 
	printf "$API\n" | cat > /etc/skt.d/data/namesilo/namesilo_$NUMBER.txt
	printf "ADD SUCCESSFUL NAMESILO $NUMBER TO DATABASE \n"

elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
	clear ; printf "Ninja Tool: Cancel \n"
	sh /etc/skt.d/tool/namesilo/manDomain.bash

else
	clear ; sh /etc/skt.d/tool/namesilo/newAccount.bash
fi