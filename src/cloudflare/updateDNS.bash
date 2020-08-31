#!/bin/bash

#UPDATE DNS RECORD( 2 A RECORD): REPLACE 2 A RECORD DNS
#DNS ID: /etc/skt.d/data/$DOMAIN/current_dns_id_cloudflare
#ZONE ID: /etc/skt.d/data/$DOMAIN/api_cf.txt
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
		curl -X GET "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records?type=A&proxied=true&page=1&per_page=20&order=type&diretcion=desc&match=all" \
			 -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "Content-Type: application/json" \
			 | python -m json.tool | printf "`jq -r '.result[].id'`" | cat > /etc/skt.d/data/$DOMAIN/current_dns_id_cloudflare; \

		#UPDATE NEW DNS RECORD

		curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/`sed -n "1p" /etc/skt.d/data/$DOMAIN/current_dns_id_cloudflare`" \
			 -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "Content-Type: application/json" \
			 --data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}' \
			 | python -m json.tool | jq -r '.suscess'
		curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/`sed -n "2p" /etc/skt.d/data/$DOMAIN/current_dns_id_cloudflare`" \
			 -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
			 -H "Content-Type: application/json" \
			 --data '{"type":"A","name":"wwww","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}';\
			 | python -m json.tool | jq -r '.suscess'
		#PURE CACHE
			curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				-H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				-H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				-H "Content-Type: application/json" \
			--data '{"purge_everything":true}' \
			| python -m json.tool | jq -r '.suscess'			
		clear
		printf "UPDATE DNS SUCCESFULL TO NEW IP: $HOST\n"
		#rm -rf /root/$DOMAIN
		sh /etc/skt.d/tool/cloudflare/manCloudflare.bash
	}
	elif [ $QUESTION = 'N' -o $QUESTION = 'n' ]; then
	{
		clear
		printf "YOU HAVE CANCEL UPDATE DNS FOR ${DOMAIN^^}\n"
		sh /etc/skt.d/tool/cloudflare/manCloudflare.bash
	}
	else
		clear
		printf "NINJA TOOL: ERORR CONFIRM\n"
		sh /etc/skt.d/tool/cloudflare/updateDNS.bash
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
			curl -X GET "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records?type=A&proxied=true&page=1&per_page=20&order=type&diretcion=desc&match=all" \
				 -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 | python -m json.tool | printf "`jq -r '.result[].id'`" | cat > /etc/skt.d/data/$DOMAIN/current_dns_id_cloudflare; \

			#UPDATE NEW DNS RECORD
			PROXIED="true"; \
			TTL="1"; \
			curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/`sed -n "1p" /etc/skt.d/data/$DOMAIN/current_dns_id_cloudflare`" \
				 -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 --data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}'; \
			| python -m json.tool | jq -r '.suscess'
			curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/`sed -n "2p" /etc/skt.d/data/$DOMAIN/current_dns_id_cloudflare`" \
				 -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 --data '{"type":"A","name":"wwww","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}'; \
			| python -m json.tool | jq -r '.suscess'
			#PURE CACHE
			curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				-H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				-H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
				-H "Content-Type: application/json" \
			--data '{"purge_everything":true}' \
			| python -m json.tool | jq -r '.suscess'
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
		sh /etc/skt.d/tool/cloudflare/updateDNS.bash
	fi
else
	clear
	printf "NINJA TOOl: ERROR SELetc\n"
fi