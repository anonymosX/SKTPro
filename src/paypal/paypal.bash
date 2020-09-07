#!/bin/bash
printf " #######################################\n"
printf "     PAYPAL | REST API | NINJA TOOL     \n"
printf " #######################################\n"
printf " 1. Fulfilment\n"
printf " 2. Check Balance\n"
printf " 3. Previous/Back\n"
printf "OPTION: "
read OPTION
if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh /etc/skt.d/tool/paypal/fulfill.bash
elif [ $OPTION = 2 ]; then
	clear
	sh /etc/skt.d/tool/paypal/balance.bash
elif [ $OPTION  = 3 ]; then
	clear
	sh /root/install
else
	clear
	printf "404: Error, wrong option\n"
	sh /etc/skt.d/tool/paypal/paypal.bash
fi
