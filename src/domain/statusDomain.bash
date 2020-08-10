#!/bin/bash
for D in /home/*; do
	if [ -d $D ]; then
		DOMAIN=${D##*/}
		mkdir -p /root/$DOMAIN
		curl -X GET "https://www.namesilo.com/api/getDomainInfo?version=1&type=xml&key=`sed -n "1p" /etc/skt.d/data/$DOMAIN/api_ns.txt`&domain=$DOMAIN" | cat > /root/$DOMAIN/expire_status.xml
	fi
done
clear
printf " ==========================\n"
printf " NINJA TOOL | STATUS DOMAIN\n"
printf " ==========================\n"
printf "\n"
printf "LIST DOMAINS: \n"
#SHOW EXPIRE DAYS
for D in /home/*; do
	if [ -d $D ]; then
		DOMAIN=${D##*/}
		expire=`cat /root/$DOMAIN/expire_status.xml | grep -oP '(?<=expires>)[^<]+'`
		printf " $expire - ${DOMAIN^^}\n"	
	fi
done
#REMOVE TRASH
for D in /home/*; do
	if [ -d $D ]; then
		rm -rf /root/${D##*/}
	fi
done
