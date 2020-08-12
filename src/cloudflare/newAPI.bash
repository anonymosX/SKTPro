#!/bin/bash
#SAVE: /etc/skt.d/data/cloudflare/cloudflare_$NUMBER.txt
printf " ==================================\n"
printf "  New API | Manage API | Cloudflare\n"
printf " ==================================\n"
if [ ! -d /etc/skt.d/data/cloudflare ]; then
	mkdir -p /etc/skt.d/data/cloudflare
fi
printf "INFORMATION: \n"
printf "Number Account: "
read NUMBER
printf "EMAIL: "
read EMAIL
printf "API: "
read API

printf "CONFIRM NEW CLOUDFLARE ACCOUNT?\n"
printf " - EMAIL: $EMAIL\n"
printf " - API  : $API\n"
printf "YES/NO - (Y/N): "
read CONFIRM
if   [ $CONFIRM = 0 ]; then
	clear ; sh /root/install

# INSERT NEW ACCOUNT
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'n' ]; then
	clear ; printf "EMAIL=$EMAIL\nCF_API=$API\n" | cat > /etc/skt.d/data/cloudflare/cloudflare_$NUMBER.txt
	printf "ADDED CLOUDFLARE $NUMBER TO DATABASE\n"

# CANCEL REQUEST
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
	clear ; printf "Ninja Tool: Cancel \n"
	sh /etc/skt.d/tool/cloudflare/manAPI.bash
else
	clear ; sh /etc/skt.d/tool/cloudflare/manAPI.bash
fi
