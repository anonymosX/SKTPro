#!/bin/bash
printf "Found `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
for D in /home/* ; do
	if [ -d $D ]; then
		d=${D##*/}
		printf " * $d\n"
	fi
done
printf " ---------\n"
printf "ENTER: "
read d
printf "YOU REALLY WANT BACK UP ${d^^} - Y/N: "
read YN

if [ ${YN} = 0 ]; then
	clear
	printf "CANCEL BACKUP\n"
	sh /etc/skt.d/tool/web/web.bash
elif [ ${YN} = 'Y' -o ${YN} = 'n' ]; then
{
	source /etc/skt.d/data/${d}/sql.txt
	cd /root
	# NGINX and SOURCE CODE
	printf "1.PROCESS CODE AND CONFIG\n"
		tar fczP $d.tar.gz /etc/letsencrypt/live/${d}/* /etc/letsencrypt/archive/${d}/* /etc/letsencrypt/renewal/${d}.conf /etc/letsencrypt/accounts/* /etc/letsencrypt/certbot-auto /etc/letsencrypt/csr/* /etc/letsencrypt/keys/* /etc/letsencrypt/options-ssl-nginx.conf /etc/letsencrypt/ssl-dhparams.pem /etc/letsencrypt/renewal-hooks/* /etc/nginx/conf.d/${d}.conf.80 /etc/nginx/conf.d/${d}.conf /home/$d/public_html /etc/skt.d/data/${d}/* 
	printf "STEP 1: DONE\n"
	# MySQL
	printf "2. PROCESS SQL\n"
		mysqldump -u root -p$mdbp $dbn > $d-$dbn.sql
	printf "STEP 2: DONE\n"
	#cd ./
		tar fczvP backup-$d-$(date +"%d%m").tar.gz  $d.tar.gz $d-$dbn.sql
		printf "3.REMOVE TRASH\n"
		rm -rf  $d.tar.gz $d-$dbn.sql
	clear
	printf "==> THE ${d} HAS BEEN BACKUPED\n"
	printf "\n"
	sh /etc/skt.d/tool/web/web.bash
}
elif [ ${YN} = 'N' -o ${YN} = 'n' ]; then
{
	clear
	sh /etc/skt.d/tool/web/web.bash
}
else
	clear
	printf "CODE: INVALID ENTER\n"
	sh /etc/skt.d/tool/web/backup.bash	
fi



