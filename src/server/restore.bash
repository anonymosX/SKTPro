#!/bin/bash
printf " -------------------------------------\n"
printf " RESTORE SERVER | IP:`hostname -I | awk '{print $1}'`\n"
printf " -------------------------------------\n"
printf "\n"
printf "DO YOU WANT TO RESTORE ENTIRE SERVER? - Y/N: "
read CONFIRM
if [ $CONFIRM = 0 ]; then
	clear
	sh /etc/skt.d/tool/server/server.bash
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
	if [ -f full_backup ]; then
	{
		clear
		cd /root && tar fxvz full_backup
		#move Block to home
		printf " ----------------------------\n"
		printf "1. EXTRACT CODE\n"
		cd /root && tar fxzP home.tar.gz
			yes | cp -rf home/ /home
			yes | cp -rf etc/ /etc
		printf "2. IMPORT SQL\n"
		cd /root && tar fxzP mysql.tar.gz
		for D in /home/*; do
			if [ -d $D ]; then
				DOMAIN=${D##*/}
				source /etc/skt.d/data/$DOMAIN/sql.txt
				mysql -u root -p$mdbp -e "create database ${dbn}"
				mysql -u root -p$mdbp -e "create user '${dbu}'@'localhost' identified by '${dbp}'"
				mysql -u root -p$mdbp -e "grant all on ${dbn}.* to ${dbu}@localhost"
				cd /root ; mysql -u root -p$mdbp ${dbn} < $DOMAIN-$dbn.sql
				chmod 777 -R /home/$DOMAIN/public_html/wp-content
				chmod 777 /home/$DOMAIN/public_html/wp-config.php
			fi
		done
		cd /root
		rm -rf home.tar.gz mysql.tar.gz *.sql
		rm -rf etc home
		systemctl restart nginx php-fpm mariadb		
		#UPDATE DNS
		printf "DO YOU WANT TO UPDATE DNS? - Y/N"
		read CONFIRM2
		if [ $CONFIRM2 = 'Y' -o $CONFIRM2 = 'y' ]; then 	
		for D in /home/*; do
			HOST=`hostname -I | awk '{print $1}'`
			if [ -d $D ]; then
			DOMAIN=${D##*/}
			#GET DNS A RECORD ID
			mkdir -p /root/$DOMAIN
			curl -X GET "https://api.cloudflare.com/client/v4/zones/`sed -n '3p' /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records?type=A&proxied=true&page=1&per_page=20&order=type&direction=desc&match=all" \
				 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 | python -m json.tool | printf "`jq -r '.result[].id'`" | cat > /root/$DOMAIN/current_dns_id_cloudflare; \			
			yes | cp -rf /root/$DOMAIN/current_dns_id_cloudflare /ect/skt.d/data/$DOMAIN/current_dns_id_cloudflare
			#UPDATE NEW DNS RECORD
			PROXIED="true"; \
			TTL="1"; \
			curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n '3p' /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/`sed -n "1p" /ect/skt.d/data/$DOMAIN/current_dns_id_cloudflare`" \
				 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 --data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}'; \
			curl -X PUT "https://api.cloudflare.com/client/v4/zones/`sed -n '3p' /ect/skt.d/data/$DOMAIN/api_cf.txt`/dns_records/`sed -n "2p" /ect/skt.d/data/$DOMAIN/current_dns_id_cloudflare`" \
				 -H "X-Auth-Email: `sed -n "1p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "X-Auth-Key: `sed -n "2p" /ect/skt.d/data/$DOMAIN/api_cf.txt`" \
				 -H "Content-Type: application/json" \
				 --data '{"type":"A","name":"wwww","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}'; \
			printf "UPDATE DNS RECORD SUCESSFUL FOR ${DOMAIN^^}\n"			
			fi
		done
	}
	else 
		clear
		printf "CAN'T FIND BACKUP FILE\n"
		sh /etc/skt.d/tool/server/server.bash
	fi
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
	clear
	printf "RESTORE HAS BEEN CANCLED\n"
	sh /etc/skt.d/tool/server/server.bash
else
	clear
	printf "WRONG SELECT\n"
	sh /etc/skt.d/tool/server/server.bash
fi
