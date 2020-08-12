#!/bin/bash
printf " ===============================\n"
printf " CLOUDFLARE MANAGE | NINJAT TOOL\n"
printf " ===============================\n"
printf "OPTION:\n"
printf " 1. Create ZONE\n"
printf " 2. Update DNS A Record\n"
printf " 3. Manage API\n"
read OPTION
printf "\n"
if   [ $OPTION = 0 ]; then
	clear ; sh /root/install
	
#CREATE ZONE
elif [ $OPTION = 1 ]; then
	clear ; sh /etc/skt.d/tool/cloudflare/createZONE.bash

#UPDATE DNS A RECORD
elif [ $OPTION = 2 ]; then	
	clear ; sh /etc/skt.d/tool/cloudflare/updateDNS.bash

#NEW API
elif [ $OPTION = 3 ]; then	
	clear ; sh /etc/skt.d/tool/cloudflare/newAPI.bash
else
	clear ; sh /etc/skt.d/tool/cloudflare/manCloudflare.bash
fi
