#!/bin/bash
printf " ###############################\n"
printf "  BACKUP | WEBSITE | WOOCOMMERCE n"
printf " ###############################\n"
printf "FOUND `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS\n"
for D in /home/* ; do
	if [ -d $D ]; then
		DOMAIN=${D##*/}
		printf " - $DOMAIN\n"
	fi
done
printf " ---------\n"
printf "ENTER: "
read DOMAIN
printf "YOU REALLY WANT BACK UP ${DOMAIN^^} - Y/N: "
read CONFIRM

if [ $CONFIRM = 0 ]; then
	clear
	printf "CANCEL BACKUP\n"
	sh /etc/skt.d/tool/web/web.bash
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
{
	source /etc/skt.d/data/$DOMAIN/sql.txt
	cd /root
	# NGINX and SOURCE CODE
	printf "1.PROCESS CODE AND CONFIG\n"
		tar fczP $DOMAIN.tar.gz /etc/letsencrypt/live/$DOMAIN/* /etc/letsencrypt/archive/$DOMAIN/* /etc/letsencrypt/renewal/$DOMAIN.conf /etc/letsencrypt/accounts/* /etc/letsencrypt/certbot-auto /etc/letsencrypt/csr/* /etc/letsencrypt/keys/* /etc/letsencrypt/options-ssl-nginx.conf /etc/letsencrypt/ssl-dhparams.pem /etc/letsencrypt/renewal-hooks/* /etc/nginx/conf.d/$DOMAIN.conf.80 /etc/nginx/conf.d/$DOMAIN.conf /home/$DOMAIN/public_html /etc/skt.d/data/$DOMAIN/* 
	printf "STEP 1: DONE\n"
	# MySQL
	printf "2. PROCESS SQL\n"
		mysqldump -u root -p$mdbp $dbn > $DOMAIN-$dbn.sql
	printf "STEP 2: DONE\n"
	#cd ./
		tar fczvP backup-$DOMAIN-$(date +"%d%m").tar.gz  $DOMAIN.tar.gz $DOMAIN-$dbn.sql
		printf "3.REMOVE TRASH\n"
		rm -rf  $DOMAIN.tar.gz $DOMAIN-$dbn.sql
	clear
	printf "==> THE $DOMAIN HAS BEEN BACKUPED\n"
	sleep 5
	printf "\n"
	sh /etc/skt.d/tool/web/web.bash
}
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
{
	clear
	sh /etc/skt.d/tool/web/web.bash
}
else
	clear
	printf "CODE: INVALID ENTER\n"
	sh /etc/skt.d/tool/web/backup.bash	
fi



