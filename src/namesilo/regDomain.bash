#!/bin/bash

# WORKFLOW: REGISTER DOMAIN -> CREATE ZONE IN CLOUDFLARE -> UPDATE NAMESERVER -> CREATE DNS A and MX RECORD -> PAUSE CLOUDFLARE 


#ZONE ID: /ect/skt.d/data/$DOMAIN/api_cf.txt

#LOAD BALANCE:
#NAMESILO 1
curl -X GET "https://www.namesilo.com/api/getAccountBalance?version=1&type=xml&key=`sed -n '1p' /etc/skt.d/data/namesilo/namesilo_1.txt`" | cat > /etc/skt.d/tool/data/balance_`sed -n '1p' /etc/skt.d/data/namesilo/namesilo_1.txt`.xml

#NAMESILO 7
curl -X GET "https://www.namesilo.com/api/getAccountBalance?version=1&type=xml&key=`sed -n '1p' /etc/skt.d/data/namesilo/namesilo_7.txt`" | cat > /etc/skt.d/tool/data/balance_`sed -n '1p' /etc/skt.d/data/namesilo/namesilo_7.txt`.xml
namesilo1="/etc/skt.d/tool/data/balance_`sed -n '1p' /etc/skt.d/data/namesilo/namesilo_1.txt`.xml"
namesilo7="/etc/skt.d/tool/data/balance_`sed -n '1p' /etc/skt.d/data/namesilo/namesilo_7.txt`.xml"
clear

printf " ============================\n"
printf " NINJA TOOL | REGISTER DOMAIN\n"
printf " ============================\n"	
printf "REGISTER DOMAIN\n"
printf "ENTER DOMAIN: "
read DOMAIN
printf "\n"
	if [ ! -d /etc/skt.d/data/$DOMAIN ]; then
		mkdir -p /etc/skt.d/data/$DOMAIN
	fi
#NAMESILO ID
printf "A) DOMAIN: \n"
printf " 1. DNVN1 - Balance: `(grep -oP '(?<=balance>)[^<]+' "$namesilo1")` USD\n"
printf " 7. DNVN7 - Balance: `(grep -oP '(?<=balance>)[^<]+' "$namesilo7")` USD\n"
printf "ENTER: "
read NS_NUMBER
printf "\n"
printf "B) CLOUDFLARE: \n"
printf " 4: THANH TRUNG TEAM\n"
printf " 5: HUYNH TAN SANG\n"
read CF_NUMBER
printf "DO YOU WANT REGISTER ${DOMAIN^^} WITH DOMAIN ACCOUNT: ${NS_NUMBER} AND CLOUDFLARE ACCOUNT: ${CF_NUMBER}? - Y/N: "
read QUESTION
if [ $QUESTION = 0 ]; then
	sh /root/install
elif [ $QUESTION = 'Y' -o $QUESTION = 'y' ]; then
{
		curl -X POST "https://www.namesilo.com/api/registerDomain?version=1&type=xml&key=`sed -n '1p' /etc/skt.d/data/namesilo/namesilo_${NS_NUMBER}.txt`&domain=$DOMAIN&years=1&private=1&auto_renew=0"

	#WAIT TO REGISTER COMPLETE
	sleep 30
	#CREATE ZONE CLOUDFLARE
	source /etc/skt.d/data/cloudflare/cloudflare_${CF_NUMBER}.txt
	curl -X POST "https://api.cloudflare.com/client/v4/zones/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: ${CF_API}" \
		-H "Content-Type: application/json" \
		--data '{"name":"'"$DOMAIN"'","jump_start":'false'}' \
		| python -m json.tool | printf "$EMAIL\n${CF_API}\n`jq '.result.id'`" | cat > /ect/skt.d/data/$DOMAIN/api_cf.txt
	sed -i 's/"//g' /ect/skt.d/data/$DOMAIN/api_cf.txt
	#GET NS CLOUDFLARE
	curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=pending&page=1&per_page=20&order=status&direction=desc&match=all" \
		 -H "X-Auth-Email: $EMAIL" \
		 -H "X-Auth-Key: ${CF_API}" \
		 -H "Content-Type: application/json" \
		 | python -m json.tool | printf "`jq -r '.result[].name_servers[0],.result[].name_servers[1] '`" |  cat > /ect/skt.d/data/$DOMAIN/ns_cf.txt

	#CHANGE NAMESERVER
	curl -X POST "https://www.namesilo.com/api/changeNameServers?version=1&type=xml&key=`/etc/skt.d/data/namesilo/namesilo_${NS_NUMBER}.txt`&domain=$DOMAIN&ns1=`sed -n '1p' /ect/skt.d/data/$DOMAIN/ns_cf.txt`&ns2=`sed -n '2p' /ect/skt.d/data/$DOMAIN/ns_cf.txt`&ns3="


	#CREATE DNS A and MX RECORD and PAUSE ZONE
	source /ect/skt.d/data/$DOMAIN/api_cf.txt
	CONTENT="`hostname -I | awk '{print $1}'`"; \
	PROXIED="true"; \
	TTL="1"; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: ${CF_API}" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}' ; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: ${CF_API}" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"www","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}' ; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: ${CF_API}" \
		-H "Content-Type: application/json" \
		--data '{"type":"MX","name":"'"$DOMAIN"'","content":"mx.yandex.net","ttl":'"$TTL"',"priority":10}' ; \
	#PAUSE CLOUDFLARE	
	curl -X PATCH "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "X-Auth-Email: $EMAIL" \
		 -H "X-Auth-Key: ${CF_API}" \
		 -H "Content-Type: application/json" \
		 --data '{"paused":'true'}'
		 
}
elif [ $QUESTION = 'N' -o $QUESTION = 'n' ]; then
	clear
	printf "YOU HAVE CANCEL REGISTER ${DOMAIN^^}\n"
	sh /etc/skt.d/tool/namesilo/manDomain.bash
else
	clear
	printf "NINJA TOOL: CONFIRM ERROR\n"
	sh /etc/skt.d/tool/namesilo/manDomain.bash
fi

find /etc/skt.d/tool/data -type f -name "balance_*.xml" -delete




