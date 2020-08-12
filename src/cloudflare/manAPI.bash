#!/bin/bash
#SAVE: /etc/skt.d/data/cloudflare/cloudflare_$NUMBER.txt
printf " ===============================\n"
printf "  Manage API | CLOUDFLARE\n"
printf " ===============================\n"
printf "OPTION: \n"
printf " 1. New API\n"
printf " 2. Update API\n"
read OPTION
printf "\n"
if   [ $OPTION = 0 ]; then
	clear ; sh /root/install
#New API
elif [ $OPTION = 1 ]; then
	clear ; sh /etc/skt.d/tool/cloudflare/newAPI.bash
	
#Update API
elif [ $OPTION = 2 ]; then
	clear ; sh /etc/skt.d/tool/cloudflare/updateAPI.bash

else 
	clear ; sh /etc/skt.d/tool/cloudflare/manAPI.bash
fi

