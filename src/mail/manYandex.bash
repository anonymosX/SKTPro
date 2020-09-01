#!/bin/bash
#Manage YANDEX API
printf " ----------------------\n"
printf "      YANDEX API\n      "
printf " ----------------------\n"
printf "OPTIONS:\n"
printf "1. REGISTER MAIL\n"
printf "2. DELETE MAILBOX\n"
if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh /etc/skt.d/tool/mail/mailgen.bash
	printf "\n"
	sh /etc/skt.d/tool/mail/manYandex.bash
elif [ $OPTION = 2 ]; then
	clear
	#PUT CODE HERE
	
	#curl -X POST "https://pddimp.yandex.ru/api2/admin/email/del" \
	 -H "PddToken: ${PddToken}" \
	 --data "domain=$DOMAIN&uid=$UID"  | python -m json.tool	
	sh /etc/skt.d/tool/mail/manYandex.bash
else
	clear
	sh /etc/skt.d/tool/mail/manYandex.bash
fi
