#!/bin/bash
# SHOW THESE DOMAINS ARE AVAILABLE IN SYSTEM!
printf "LIST DOMAINS: \n"
for D in /home/* ; do
	if [ -d ${D} ]; then
		printf " - ${D##*/}\n" 
	fi
done
printf "ENTER: "
read DOMAIN
printf "\n"
printf "DO YOU WANT RENEW SSL FOR ${DOMAIN^^}? - Y/N: "
read CONFIRM


if [ $CONFIRM = 0 ]; then
	clear
	sh /root/install
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
	clear
	printf "YOU HAVE CHOOSE YES\n"
	# PAUSE CLOUDFLARE - PAUSE ZONE ID
	curl -X PATCH "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "Content-Type: application/json" \
		 --data '{"paused":'true'}'	
	# WAIT 60s TO A RECORD UPDATE
	sleep 60
	# CERTBOT RENEW - SSL
	certbot renew --cert-name $DOMAIN
	# ENABLE CLOUDFLARE AGAIN - ENABLE ZONE ID
	curl -X PATCH "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "Content-Type: application/json" \
		 --data '{"paused":'false'}'		
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
	clear
	printf "YOU HAVE CHOOSE NO\n"
	sh /etc/skt.d/tool/ssl/ssl.bash
else
	clear
	printf "CODE: INVALID ENTER\n"
	sh /etc/skt.d/tool/ssl/renew.bash	
fi
