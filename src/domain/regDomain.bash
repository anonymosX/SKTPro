#!/bin/bash

# WORKFLOW: REGISTER DOMAIN -> CREATE ZONE IN CLOUDFLARE -> UPDATE NAMESERVER -> CREATE DNS A and MX RECORD -> PAUSE CLOUDFLARE 


#ZONE ID: /ect/skt.d/data/$DOMAIN/api_cf.txt

#LOAD BALANCE:
curl -X GET "https://www.namesilo.com/api/getAccountBalance?version=1&type=xml&key=cf2f45634f0653c9306253" | cat > /etc/skt.d/tool/data/balance_cf2f45634f0653c9306253.xml
curl -X GET "https://www.namesilo.com/api/getAccountBalance?version=1&type=xml&key=a101923b1681e2d5f36a6610" | cat > /etc/skt.d/tool/data/balance_a101923b1681e2d5f36a6610.xml
clear




printf " ============================\n"
printf " NINJA TOOL | REGISTER DOMAIN\n"
printf " ============================\n"	
printf "REGISTER DOMAIN\n"
printf "ENTER DOMAIN: "
read DOMAIN
printf "\n"
#NAMESILO ID
printf "A) SELECT DOMAIN: \n"
printf " 1. DNVN7 | E06 - Balance: `(grep -oP '(?<=balance>)[^<]+' '/etc/skt.d/tool/data/balance_cf2f45634f0653c9306253.xml')` USD\n"
printf " 2. DNVN1 | E11 - Balance: `(grep -oP '(?<=balance>)[^<]+' '/etc/skt.d/tool/data/balance_a101923b1681e2d5f36a6610.xml')` USD\n"
printf "ENTER: "
read DO_ACCOUNT
printf "\n"
printf "B) SELECT CLOUDFLARE: \n"
printf " 4. CloudFlare.com 4: THANH TRUNG TEAM\n"
printf " 5. CloudFlare.com 5: HUYNH TAN SANG\n"
read CF_ACCOUNT
printf "DO YOU WANT REGISTER ${DOMAIN} WITH DOMAIN ACCOUNT: ${DO_ACCOUNT} AND CLOUDFLARE ACCOUNT: ${CF_ACCOUNT}? - Y/N: "
read QUESTION
if [ $QUESTION = 0 ]; then
	sh /root/install
elif [ $QUESTION = 'Y' -o $QUESTION = 'y' ]; then
{
	if [ ${DO_ACCOUNT} = 1 ]; then
	{
		#DNVN7 - 202.158.247.22 E06
		#Email: fusionboy21@gmail.com
		NS_KEY=cf2f45634f0653c9306253
		curl -X POST "https://www.namesilo.com/api/registerDomain?version=1&type=xml&key=${NS_KEY}&domain=$DOMAIN&years=1&private=1&auto_renew=0"
	}
	elif [ ${DO_ACCOUNT} = 2 ]; then
	{	
		#DNVN1 - 45.117.165.236 E11
		#MAIL-roberthansen916@gmail.com
		NS_KEY=a101923b1681e2d5f36a6610
		curl -X POST "https://www.namesilo.com/api/registerDomain?version=1&type=xml&key=${NS_KEY}&domain=$DOMAIN&years=1&private=1&auto_renew=0"
	}
	else 
		clear
		printf "PLEASE CHOOSE ACCOUNT\n"
		sh /etc/skt.d/tool/domain/regDomain.bash
	fi
	#WAIT TO REGISTER COMPLETE
	sleep 30
	if [ ${CF_ACCOUNT} = 4 ]; then
	{
	#CREATE ZONE CLOUDFLARE
	EMAIL="huynhtanluxury@gmail.com"; \
	KEY="d9a475c1db5f422c5cda733d674aaa1c19f56"; \
	JUMP_START="false"; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: $KEY" \
		-H "Content-Type: application/json" \
		--data '{"name":"'"$DOMAIN"'","jump_start":'"$JUMP_START"'}' \
		| python -m json.tool | printf "$EMAIL\n$KEY\n`jq '.result.id'`" | cat > /ect/skt.d/data/$DOMAIN/api_cf.txt
	sed -i 's/"//g' /ect/skt.d/data/$DOMAIN/api_cf.txt
	#GET NS CLOUDFLARE
	curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=pending&page=1&per_page=20&order=status&direction=desc&match=all" \
		 -H "X-Auth-Email: $EMAIL" \
		 -H "X-Auth-Key: $KEY" \
		 -H "Content-Type: application/json" \
		 | python -m json.tool | printf "`jq -r '.result[].name_servers[0],.result[].name_servers[1] '`" |  cat > /ect/skt.d/data/$DOMAIN/ns_cf.txt

	#CHANGE NAMESERVER
	if [ ${DO_ACCOUNT} = 1 ]; then
	{
	NS_KEY=cf2f45634f0653c9306253
	curl -X POST "https://www.namesilo.com/api/changeNameServers?version=1&type=xml&key=${NS_KEY}&domain=$DOMAIN&ns1=`sed -n '1p' /ect/skt.d/data/$DOMAIN/ns_cf.txt`&ns2=`sed -n '2p' /ect/skt.d/data/$DOMAIN/ns_cf.txt`&ns3="
	}
	elif [ ${DO_ACCOUNT} = 2 ]; then
	{
	NS_KEY=a101923b1681e2d5f36a6610
	curl -X POST "https://www.namesilo.com/api/changeNameServers?version=1&type=xml&key=${NS_KEY}&domain=$DOMAIN&ns1=`sed -n '1p' /ect/skt.d/data/$DOMAIN/ns_cf.txt`&ns2=`sed -n '2p' /ect/skt.d/data/$DOMAIN/ns_cf.txt`&ns3="
	}
	else 
		clear
		printf "PLEASE CHOOSE ACCOUNT\n"
		sh /etc/skt.d/tool/domain/regDomain.bash
	fi

	#CREATE DNS A and MX RECORD and PAUSE ZONE
	source /ect/skt.d/data/$DOMAIN/api_cf.txt
	CONTENT="`hostname -I | awk '{print $1}'`"; \
	PROXIED="true"; \
	TTL="1"; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: $KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}' ; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: $KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"www","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}' ; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: $KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"MX","name":"'"$DOMAIN"'","content":"mx.yandex.net","ttl":'"$TTL"',"priority":10}' ; \
	#PAUSE CLOUDFLARE	
	curl -X PATCH "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "X-Auth-Email: $EMAIL" \
		 -H "X-Auth-Key: $KEY" \
		 -H "Content-Type: application/json" \
		 --data '{"paused":true}'
	}	 
	elif [ ${CF_ACCOUNT} = 5 ]; then
	{
	#CREATE ZONE CLOUDFLARE
	EMAIL="thanhtrungteam.quoc@gmail.com"; \
	KEY="f54b13382bf6c16faafcc1789b7e6aec1a6d3"; \
	JUMP_START="false"; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: $KEY" \
		-H "Content-Type: application/json" \
		--data '{"name":"'"$DOMAIN"'","jump_start":'"$JUMP_START"'}' \
		| python -m json.tool | printf "$EMAIL\n$KEY\n`jq '.result.id'`" | cat > /ect/skt.d/data/$DOMAIN/api_cf.txt

	#GET NS CLOUDFLARE
	curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN&status=pending&page=1&per_page=20&order=status&direction=desc&match=all" \
		 -H "X-Auth-Email: $EMAIL" \
		 -H "X-Auth-Key: $KEY" \
		 -H "Content-Type: application/json" \
		 | python -m json.tool | printf "`jq -r '.result[].name_servers[0],.result[].name_servers[1] '`" |  cat > /ect/skt.d/data/$DOMAIN/ns_cf.txt

	#CHANGE NAMESERVER
	if [ ${DO_ACCOUNT} = 1 ]; then
	{
	NS_KEY=cf2f45634f0653c9306253
	curl -X POST "https://www.namesilo.com/api/changeNameServers?version=1&type=xml&key=${NS_KEY}&domain=$DOMAIN&ns1=`sed -n '1p' /ect/skt.d/data/$DOMAIN/ns_cf.txt`&ns2=`sed -n '2p' ns.txt`&ns3="
	}
	elif [ ${DO_ACCOUNT} = 2 ]; then
	{
	NS_KEY=
	curl -X POST "https://www.namesilo.com/api/changeNameServers?version=1&type=xml&key=${NS_KEY}&domain=$DOMAIN&ns1=`sed -n '1p' /ect/skt.d/data/$DOMAIN/ns_cf.txt`&ns2=`sed -n '2p' ns.txt`&ns3="
	}
	else 
		clear
		printf "PLEASE CHOOSE ACCOUNT\n"
		sh /etc/skt.d/tool/domain/regDomain.bash
	fi

	#CREATE DNS A and MX RECORD and PAUSE ZONE

	cd 
	CONTENT="`hostname -I | awk '{print $1}'`"; \
	PROXIED="true"; \
	TTL="1"; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: $KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}' ; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: $KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"A","name":"www","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}' ; \
	curl -X POST "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/" \
		-H "X-Auth-Email: $EMAIL" \
		-H "X-Auth-Key: $KEY" \
		-H "Content-Type: application/json" \
		--data '{"type":"MX","name":"'"$DOMAIN"'","content":"mx.yandex.net","ttl":'"$TTL"',"priority":10}' ; \
	#PAUSE CLOUDFLARE	
	curl -X PATCH "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
		 -H "X-Auth-Email: $EMAIL" \
		 -H "X-Auth-Key: $KEY" \
		 -H "Content-Type: application/json" \
		 --data '{"paused":true}'	
	}
	else 
		clear
		printf "PLEASE CHOOSE CLOUDFLARE ACCOUNT\n"
		sh /etc/skt.d/tool/domain/regDomain.bash
	fi
}
elif [ $QUESTION = 'N' -o $QUESTION = 'n' ]; then
	clear
	printf "YOU HAVE CANCEL REGISTER ${DOMAIN^^}\n"
	sh /etc/skt.d/tool/domain/manDomain.bash
else
	clear
	printf "NINJA TOOL: CONFIRM ERROR\n"
fi

find /etc/skt.d/tool/data -type f -name "balance_*.xml" -delete




