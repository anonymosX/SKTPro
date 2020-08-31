#!/bin/bash
printf " ============================================\n"
printf " Domain FREE | CLOUDFLARE MANAGE | NINJA TOOL\n"
printf " ============================================\n"
printf "1. DOMAIN 70k: "
read DOMAIN
printf "2. CLOUDFLARE: "
read CF_NUMBER

CONTENT="`hostname -I | awk '{print $1}'`"
TTL="1"
	mkdir -p /etc/skt.d/data/$DOMAIN
	#CREATE NEW ZONE ID
	source /etc/skt.d/data/cloudflare/cloudflare_${CF_NUMBER}.txt
curl -X POST "https://api.cloudflare.com/client/v4/zones/" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: ${CF_API}" \
	-H "Content-Type: application/json" \
	--data '{"name":"'"$DOMAIN"'","jump_start":'false'}' \
	| python -m json.tool | printf "$EMAIL\n${CF_API}\n`jq '.result.id'`" | cat > /etc/skt.d/data/$DOMAIN/api_cf.txt
	sed -i 's/"//g' /etc/skt.d/data/$DOMAIN/api_cf.txt
	
	#GET NS CLOUDFLARE
curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=pending&page=1&per_page=20&order=status&direction=desc&match=all" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: ${CF_API}" \
	-H "Content-Type: application/json" \
 | python -m json.tool | printf "`jq -r '.result[].name_servers[0],.result[].name_servers[1] '`" |  cat > /etc/skt.d/data/$DOMAIN/ns_cf.txt 

	#CREATE DNS A and MX RECORD and PAUSE ZONE
curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: ${CF_API}" \
	-H "Content-Type: application/json" \
	--data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$CONTENT"'","proxied":'true',"ttl":'"$TTL"'}' \ | python -m json.tool
curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: ${CF_API}" \
	-H "Content-Type: application/json" \
	--data '{"type":"A","name":"www","content":"'"$CONTENT"'","proxied":'true',"ttl":'"$TTL"'}'  \ | python -m json.tool
curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: ${CF_API}" \
	-H "Content-Type: application/json" \
	--data '{"type":"MX","name":"'"$DOMAIN"'","content":"mx.yandex.net","ttl":'"$TTL"',"priority":10}' ; \ | python -m json.tool
	#PAUSE CLOUDLARE

curl -X PATCH "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: ${CF_API}" \
	-H "Content-Type: application/json" \
	--data '{"paused":'true'}' \ | python -m json.tool
clear

printf "ĐÃ ÉP THÀNH CÔNG $DOMAIN VÀO CLOUDFLARE $CF\n"








