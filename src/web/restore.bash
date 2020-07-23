#!/bin/bash
printf "       ---------------------------------------\n"
printf "        RESTORE DOMAIN | FOUND `find /root -name 'backup*' -type f | wc -l` BACK UP FILES\n"
printf "       ---------------------------------------\n"
printf "FOUND A LIST BACKUP FILES\n"
find /root -name 'backup*' -type f
printf "\nENTER: "
read d
printf "ARE YOU WANT TO RESTORE ${d^^}? - Y/N\n"
read YN
clear
if [ ${YN} = 0 ]; then
	sh /root/install
elif [ ${YN} = 'Y' -o ${YN} = 'y' ]; then
	printf "YOU HAVE CHOOSE YES\n"
{
# CREATE SERVER BLOCK, LOG
mkdir -p /etc/skt.d/${d} /home/$d/public_html /home/$d/log /etc/letsencrypt/live/${d}
touch /home/$d/log/error.log && chmod +x /home/$d/log/error.log


cd /root
find /root -type f -name "backup-${d}*.tar.gz" -exec tar -xzf {} \;
tar -xzf $d.tar.gz
# IMPORT CODE
	yes | cp -rf etc/skt.d/* /etc/skt.d
	yes | cp -rf etc/nginx/conf.d/* /etc/nginx/conf.d
	yes | cp -rf home/${d}/public_html/* /home/${d}/public_html
	yes | cp -rf etc/letsencrypt/live/${d}/* /etc/letsencrypt/live/${d}
	yes | cp -rf etc/letsencrypt/renewal/${d}.conf /etc/letsencrypt/renewal/
	yes | cp -rf etc/letsencrypt/archive/${d} /etc/letsencrypt/archive
# IMPORT DATABASES
	source /etc/skt.d/${d}/${d}.mariadb
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
printf "THE ${d} HAS BEEN RESTORED\n"
systemctl restart nginx
	sh /etc/skt.d/tool/web/web.bash
}

elif [ ${YN} = 'N' -o ${YN} = 'n' ]; then
{	
	printf "YOU HAVE CHOOSE NO\n"
	clear
	printf "You have cancel request\n"
	sh /etc/skt.d/tool/web/web.bash
}
else
	clear
	printf "CODE: INVALID ENTER\n"
	printf "\n"
	sh /etc/skt.d/tool/web/restore.bash
fi