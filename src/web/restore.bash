#!/bin/bash
printf "       ---------------------------------------\n"
printf "        RESTORE DOMAIN | FOUND `find /root -name 'backup*' -type f | wc -l` BACK UP FILES\n"
printf "       ---------------------------------------\n"
printf "FOUND A LIST BACKUP FILES\n"
find /root -name 'backup*' -type f
printf "\nENTER: "
read d
printf "ARE YOU WANT TO RESTORE ${d^^}? - Y/N: "
read YN

if [ ${YN} = 0 ]; then
	clear
	sh /root/install
elif [ ${YN} = 'Y' -o ${YN} = 'y' ]; then
	clear
	printf "YOU HAVE CHOOSE YES\n"
{
# CREATE SERVER BLOCK, LOG
	printf "PROCESS RESTORE CODE AND CONFIG\n"
	mkdir -p /etc/skt.d/data/${d} /home/$d/public_html /home/$d/log /etc/letsencrypt/live/${d}
	touch /home/$d/log/error.log && chmod +x /home/$d/log/error.log
	cd /root
	find /root -type f -name "backup-${d}*.tar.gz" -exec tar fxz {} \;
	tar fxz $d.tar.gz
# IMPORT CODE
	yes | cp -rf etc/skt.d/* /etc/skt.d
	yes | cp -rf etc/nginx/conf.d/* /etc/nginx/conf.d
	yes | cp -rf home/${d}/public_html/* /home/${d}/public_html
	yes | cp -rf etc/letsencrypt/live/${d}/* /etc/letsencrypt/live/${d}
	yes | cp -rf etc/letsencrypt/renewal/${d}.conf /etc/letsencrypt/renewal/
	yes | cp -rf etc/letsencrypt/archive/${d} /etc/letsencrypt/archive
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
	source /etc/skt.d/data/${d}/sql.txt
	printf "create database ${dbn}" | mysql
	printf "create user '${dbu}'@'localhost' identified by '${dbp}'" | mysql
	printf "grant all on ${dbn}.* to ${dbu}@localhost" | mysql
	printf "flush privileges" | mysql
	mysql -u root -p$mdbp $dbn < $d-$dbn.sql
# REMOVE TRASH
	rm -rf etc home
	find /root -type f -name "backup-{d}*.tar.gz" -delete
	rm -f ${d}-${dbn}.sql
# FIX PERMISSION
	chmod 777 -R /home/$d/public_html/wp-content
	chmod 777 /home/$d/public_html/wp-config.php
	#chmod 755 -R /home/$d/public_html/wp-content
# FINAL
	clear
	printf "${d^^} HAS RESTORED\n"
	systemctl restart nginx
	sh /etc/skt.d/tool/web/web.bash
}

elif [ ${YN} = 'N' -o ${YN} = 'n' ]; then
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