#!/bin/bash
#SAVE: /etc/skt.d/data/cloudflare/cloudflare_$NUMBER.txt
printf " ==================================\n"
printf "  update API | Manage API | Cloudflare\n"
printf " ==================================\n"
printf "UPDATE NEW API\n"
printf "CHOOSE ACCOUNT: "
read NUMBER
printf "ENTER NEW API: "
read newAPI
printf "DO YOU WANT TO UPDATE NEW API: $newAPI TO CLOUDFLARE $NUMBER? - Y/N: "
read CONFIRM
printf "\n"
if   [ $CONFIRM = 0 ]; then
	clear ; sh /root/install
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
	clear
	source /etc/skt.d/data/cloudflare/cloudflare_$NUMBER.txt
	for D in /home/*; do
		if [ -d ${D} ]; then
			DOMAIN=${D##*/}
			
			if [ `sed -n '3p' /etc/skt.d/data/$DOMAIN/api_cf.txt` = ${CF_API} ]; then
				sed -i "s+`sed -n '3p' /etc/skt.d/data/$DOMAIN/api_cf.txt`+$newAPI+g" /etc/skt.d/data/$DOMAIN/api_cf.txt
			fi
		fi
	done	
	sed -i "s/${CF_API}/$newAPI/g" /etc/skt.d/data/cloudflare/cloudflare_$NUMBER.txt
	printf "UPDATE new API successful \n"
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
	clear ; printf "Cancel: update API\n"
else
	clear ; printf "DON'T KNOW YOUR ANSWERS \n"
	sh /etc/skt.d/tool/cloudflare/updateAPI.bash
fi
