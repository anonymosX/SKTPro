#!/bin/bash
printf " ------------------------------------\n"
printf " NEW NAMESILO ACCOUTN | DOMAIN MANAGE\n"
printf " ------------------------------------\n"
printf "INFORMATION: \n"
printf "Number Account:( 1 2 3 4 )\n"
read NUMBER
printf "\n"
printf "API: "
read API
printf "\n"
printf "Confirm NEW NAMESILO account?\n"
printf " - API  : $API\n"
printf "YES/NO - (Y/N): "
read CONFIRM
if   [ $CONFIRM = 0 ]; then
	clear ; sh /root/install

# INSERT NEW ACCOUNT
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'n' ]; then
	clear 
	printf "$API\n" | cat > /etc/skt.d/data/namesilo/namesilo_$NUMBER.txt
	printf "Add successful Namesilo $NUMBER to DATABASE \n"

elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
	clear ; printf "Ninja Tool: Cancel \n"
	sh /etc/skt.d/tool/namesilo/manDomain.bash

else
	clear ; sh /etc/skt.d/tool/namesilo/newAccount.bash
fi