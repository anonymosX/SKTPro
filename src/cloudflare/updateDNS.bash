#!/bin/bash

#UPDATE DNS RECORD( 2 A RECORD): REPLACE 2 A RECORD DNS
#DNS ID: /ect/skt.d/data/$DOMAIN/current_dns_id_cloudflare
#ZONE ID: /ect/skt.d/data/$DOMAIN/api_cf.txt
PROXIED="true"
TTL="1"
HOST=`hostname -I | awk '{print $1}'`
printf "OPTION:\n"
printf " 1. UPDATE 1 DOMAIN\n"
printf " 2. UPDATE ALL DOMAINS\n"
read OPTION
printf "\n"


if [ $OPTION = 0 ]; then
	sh /root/install
elif [ $OPTION = 1 ]; then
	for D in /home/*; do
		if [ -d $D ]; then
			DOMAIN=${D##*/}
			printf " - $DOMAIN \n"
		fi
		done
	printf "\n"
	printf  "CHOOSE DOMAIN: "
	read DOMAIN
	printf "\n"
	printf "DO YOU WANT TO UPDATE DNS A RECORD FOR ${DOMAIN^^}? - Y/N: "
	read QUESTION
	if [ $QUESTION = 'Y' -o $QUESTION = 'y' ]; then
	{
		clear
		#GET DNS RECORD ID
		curl -X GET "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records?type=A&proxied=true&page=1&per_page=20&order=type&direction=desc&match=all" \
			 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "Content-Type: application/json" \
			 | python -m json.tool | printf "`jq -r '.result[].id'`" | cat > /root/$DOMAIN/current_dns_id_cloudflare; \
		yes | cp -rf /root/$DOMAIN/current_dns_id_cloudflare /etc/skt.d/data/$DOMAIN/current_dns_id_cloudflare

		#UPDATE NEW DNS RECORD

		curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /root/$DOMAIN/api_cf.txt`/dns_records/`sed -n "1p" /root/$DOMAIN/current_dns_id_cloudflare`" \
			 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "Content-Type: application/json" \
			 --data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}'; \
		curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /root/$DOMAIN/api_cf.txt`/dns_records/`sed -n "2p" /root/$DOMAIN/current_dns_id_cloudflare`" \
			 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "Content-Type: application/json" \
			 --data '{"type":"A","name":"wwww","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}';\
		rm -rf /root/$DOMAIN
		clear
		printf "UPDATE DNS SUCCESFULL TO NEW IP: $HOST\n"
		sh /etc/skt.d/tool/domain/manDomain.bash
		rm -rf /root/$DOMAIN
	}
	elif [ $QUESTION = 'N' -o $QUESTION = 'n' ]; then
	{
		clear
		printf "YOU HAVE CANCEL UPDATE DNS FOR ${DOMAIN^^}\n"
		sh /etc/skt.d/tool/domain/manDomain.bash
	}
	else
		clear
		printf "NINJA TOOL: ERORR CONFIRM\n"
		sh /etc/skt.d/tool/domain/updateDNS.bash
	fi
elif [ $OPTION = 2 ]; then
	printf "DO YOU WANT TO UPDATE DNS FOR ALL DOMAINS - Y/N"
	read QUESTION
	if [ $QUESTION = 'Y' -o $QUESTION = 'y' ]; then
	{
		for D in /home/*; do
			if [ -d $D ]; then
			DOMAIN=${D##*/}
			#GET DNS A RECORD ID
			curl -X GET "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records?type=A&proxied=true&page=1&per_page=20&order=type&direction=desc&match=all" \
				 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 | python -m json.tool | printf "`jq -r '.result[].id'`" | cat > /ect/skt.d/data/$DOMAIN/current_dns_id_cloudflare; \

			#UPDATE NEW DNS RECORD
			PROXIED="true"; \
			TTL="1"; \
			curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/`sed -n "1p" /ect/skt.d/data/$DOMAIN/current_dns_id_cloudflare`" \
				 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 --data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}'; \
			curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/`sed -n "2p" /ect/skt.d/data/$DOMAIN/current_dns_id_cloudflare`" \
				 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 --data '{"type":"A","name":"wwww","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}'; \
			printf "UPDATE DNS SUCESSFUL FOR ${DOMAIN^^}\n"
			fi
		done
	}
	elif [ $QUESTION = 'N' -o $QUESTION = 'n' ]; then
		clear
		printf "YOU HAVE CANCLE REQUEST\n"
	else 
		clear
		printf "NINJA TOOL: CONFIRM ERROR\n"
		sh /etc/skt.d/tool/domain/updateDNS.bash
	fi
else
	clear
	printf "NINJA TOOl: ERROR SELECT\n"
fi