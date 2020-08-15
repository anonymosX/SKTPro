#!/bin/bash
printf " ============================================\n"
printf " CREATE ZONE | CLOUDFLARE MANAGE | NINJA TOOL\n"
printf " ============================================\n"
	printf "1. DOMAIN: "
	read DOMAIN
	printf "2. NAMESILO: "
	read NS_NUMBER	
	printf "3. CLOUDFLARE: "
	read CF_NUMBER
	mkdir -p /root/$DOMAIN
	CONTENT="`hostname -I | awk '{print $1}'`"; \
	TTL="1"; \
if [ ! -d /etc/skt.d/data/$DOMAIN ]; then
	mkdir -p /etc/skt.d/data/$DOMAIN
fi
	#CREATE NEW ZONE ID
	source /etc/skt.d/data/cloudflare/cloudflare_${CF_NUMBER}.txt
curl -X POST "https://api.cloudflare.com/client/v4/zones/" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: ${CF_API}" \
	-H "Content-Type: application/json" \
	--data '{"name":"'"$DOMAIN"'","jump_start":'false'}' \
	| python -m json.tool | printf "$EMAIL\n${CF_API}\n`jq '.result.id'`" | cat > /root/$DOMAIN/api_cf.txt
	sed -i 's/"//g' /root/$DOMAIN/api_cf.txt
	yes | cp -rf /root/$DOMAIN/api_cf.txt /etc/skt.d/data/$DOMAIN/api_cf.txt

	
	#GET NS CLOUDFLARE
curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=pending&page=1&per_page=20&order=status&direction=desc&match=all" \
	-H "X-Auth-Email: $EMAIL" \
	-H "X-Auth-Key: ${CF_API}" \
	-H "Content-Type: application/json" \
 | python -m json.tool | printf "`jq -r '.result[].name_servers[0],.result[].name_servers[1] '`" |  cat > /root/$DOMAIN/ns_cf.txt 
	yes | cp -rf /root/$DOMAIN/ns_cf.txt /etc/skt.d/data/$DOMAIN/ns_cf.txt

	#CHANGE NAMESERVER
	cat /etc/skt.d/data/namesilo/namesilo_${NS_NUMBER}.txt | cat > /root/$DOMAIN/api_ns.txt
	yes | cp -rf /root/$DOMAIN/api_ns.txt /etc/skt.d/data/$DOMAIN/api_ns.txt
	curl -X POST "https://www.namesilo.com/api/changeNameServers?version=1&type=xml&key=`sed -n '1p' /root/$DOMAIN/api_ns.txt`&domain=$DOMAIN&ns1=`sed -n '1p' /root/$DOMAIN/ns_cf.txt `&ns2=`sed -n '2p' /root/$DOMAIN/ns_cf.txt `&ns3="

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
