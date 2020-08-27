#!/bin/bash
printf " ===============================\n"
printf " CLOUDFLARE MANAGE | NINJA TOOL\n"
printf " ===============================\n"
printf "OPTION:\n"
printf " 1. Create ZONE\n"
printf " 2. 70k domain create zone\n"
printf " 3. Update DNS A Record\n"
printf " 4. Manage API\n"
read OPTION
printf "\n"
if   [ $OPTION = 0 ]; then
	clear ; sh /root/install
	
#CREATE ZONE
elif [ $OPTION = 1 ]; then
	clear ; sh /etc/skt.d/tool/cloudflare/createZONE.bash
#70k create zone
elif [ $OPTION = 2 ]; then	
	clear ; sh /etc/skt.d/tool/cloudflare/70kcreatezone.bash
#UPDATE DNS A RECORD
elif [ $OPTION = 3 ]; then	
	clear ; sh /etc/skt.d/tool/cloudflare/updateDNS.bash

#NEW API
elif [ $OPTION = 4 ]; then	
	clear ; sh /etc/skt.d/tool/cloudflare/manAPI.bash
else
	clear ; sh /etc/skt.d/tool/cloudflare/manCloudflare.bash
fi
