#!/bin/bash
printf " ################################\n"
printf " RESTORE 1 WEBSITE | WOOCOMMERCE\n"
printf " ################################\n"
printf "FOUND `find /root -name 'backup*' -type f | wc -l` BACK UP FILES\n"
printf "FOUND A LIST BACKUP FILES\n"
find /root -name 'backup*' -type f
printf "\nENTER: "
read DOMAIN
printf "ARE YOU WANT TO RESTORE ${d^^}? - Y/N: "
read CONFIRM

if [ $CONFIRM = 0 ]; then
	clear
	sh /root/install
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
	clear
	printf "YOU HAVE CHOOSE YES\n"
	sleep 5
{
# CREATE SERVER BLOCK, LOG
	printf "PROCESS RESTORE CODE AND CONFIG\n"
	mkdir -p /etc/skt.d/data/$DOMAIN /home/$DOMAIN/public_html /home/$DOMAIN/log /etc/letsencrypt/live/$DOMAIN
	touch /home/$DOMAIN/log/error.log && chmod +x /home/$DOMAIN/log/error.log
	cd /root
	find /root -type f -name "backup-$DOMAIN*.tar.gz" -exec tar fxz {} \;
	tar fxz $DOMAIN.tar.gz
# IMPORT CODE
	yes | cp -rf etc/skt.d/* /etc/skt.d
	yes | cp -rf etc/nginx/conf.d/* /etc/nginx/conf.d
	yes | cp -rf home/$DOMAIN/public_html/* /home/$DOMAIN/public_html
	yes | cp -rf etc/letsencrypt/live/$DOMAIN/* /etc/letsencrypt/live/$DOMAIN
	yes | cp -rf etc/letsencrypt/renewal/$DOMAIN.conf /etc/letsencrypt/renewal/
	yes | cp -rf etc/letsencrypt/archive/$DOMAIN /etc/letsencrypt/archive
	if [ ! -d /etc/letsencrypt/accounts ]; then 
		mkdir -p /etc/letsencrypt/accounts
		yes | cp -rf /root/etc/letsencrypt/accounts/* /etc/letsencrypt/accounts
	else 
		yes | cp -rf /root/etc/letsencrypt/accounts/* /etc/letsencrypt/accounts
	fi
	if [ ! -d /etc/letsencrypt/csr ]; then 
		mkdir -p /etc/letsencrypt/csr
		yes | cp -rf /root/etc/letsencrypt/csr/* /etc/letsencrypt/csr
	else 
		yes | cp -rf /root/etc/letsencrypt/csr/* /etc/letsencrypt/csr
	fi
	if [ ! -d /etc/letsencrypt/keys ];then
		mkdir -p /etc/letsencrypt/keys
		yes | cp -rf /root/etc/letsencrypt/keys/* /etc/letsencrypt/keys
	else
		yes | cp -rf /root/etc/letsencrypt/keys/* /etc/letsencrypt/keys	
	fi
	if [ ! -d /etc/letsencrypt/renewal-hooks ];then
		mkdir -p /etc/letsencrypt/renewal-hooks
		yes | cp -rf /root/etc/letsencrypt/renewal-hooks/* /etc/letsencrypt/renewal-hooks
	else
		yes | cp -rf /root/etc/letsencrypt/renewal-hooks/* /etc/letsencrypt/renewal-hooks
	fi
	yes | cp -rf etc/letsencrypt/certbot-auto /etc/letsencrypt/certbot-auto
	yes | cp -rf etc/letsencrypt/options-ssl-nginx.conf /etc/letsencrypt/options-ssl-nginx.conf
	yes | cp -rf etc/letsencrypt/ssl-dhparams.pem /etc/letsencrypt/ssl-dhparams.pem 
# IMPORT DATABASES
	source /etc/skt.d/data/$DOMAIN/sql.txt
	printf "create database ${dbn}" | mysql
	printf "create user '${dbu}'@'localhost' identified by '${dbp}'" | mysql
	printf "grant all on ${dbn}.* to ${dbu}@localhost" | mysql
	printf "flush privileges" | mysql
	mysql -u root -p$mdbp $dbn < $DOMAIN-$dbn.sql
# REMOVE TRASH
	rm -rf etc home
	find /root -type f -name "backup-DOMAIN*.tar.gz" -delete
	rm -f $DOMAIN-${dbn}.sql
# FIX PERMISSION
	chmod 777 -R /home/$DOMAIN/public_html/wp-content
	chmod 777 /home/$DOMAIN/public_html/wp-config.php
	#chmod 755 -R /home/$DOMAIN/public_html/wp-content
# FINAL
	clear
	printf "${DOMAIN^^} HAS RESTORED\n"
	sleep 5
	systemctl restart nginx
	PROXIED="true"
	TTL="1"
	HOST=`hostname -I | awk '{print $1}'`
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
			 --data '{"type":"A","name":"'"$DOMAIN"'","content":"'"$HOST"'","ttl":'"$TTL"',"proxied":'"$PROXIED"'}'; \
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
	sh /etc/skt.d/tool/web/web.bash
}

elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
{	
	clear
	printf "YOU HAVE CHOOSE NO\n"
	sh /etc/skt.d/tool/web/web.bash
}
else
	clear
	printf "CODE: INVALID ENTER\n"
	printf "\n"
	sh /etc/skt.d/tool/web/restore.bash
fi