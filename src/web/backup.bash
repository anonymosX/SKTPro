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
printf "YOU REALLY WANT BACK UP ${d^^} - Y/N\n"
read YN
clear
if [ ${YN} = 0 ]; then
	printf "You have cancel request\n"
	sh /etc/skt.d/tool/web/web.bash
elif [ ${YN} = 'Y' -o ${YN} = 'n']; then
{
	source /etc/skt.d/${d}/${d}.mariadb
	cd /root
	# NGINX and SOURCE CODE
	printf "1.Get source code\n"
		tar -czf $d.tar.gz /etc/letsencrypt/live/${d}/* /etc/letsencrypt/archive/${d}/* /etc/letsencrypt/renewal/${d}.conf /etc/nginx/conf.d/${d}.conf.80 /etc/nginx/conf.d/${d}.conf /home/$d/public_html /etc/skt.d/${d}/${d}.mariadb /etc/skt.d/${d}/${d}.login
	printf "2. Source code -> Done\n"
	# MySQL
	printf "3. Get mysql\n"
		mysqldump -u root -p$mdbp $dbn > $d-$dbn.sql
	printf "4. MYSQL -> Done\n"
	#cd ./
		tar -czf backup-$d-$(date +"%d%m").tar.gz  $d.tar.gz $d-$dbn.sql
		printf "5.Remove trash\n"
		rm -rf  $d.tar.gz $d-$dbn.sql
		printf "==> THE ${d} HAS BEEN BACKUPED\n"
	cd root && ls
	printf "\n"
	sh /etc/skt.d/tool/web/web.bash
}
elif [ ${YN} = 'N' -o ${YN} = 'n' ]; then
{
	sh /etc/skt.d/tool/web/web.bash
}
else
	printf "CODE: INVALID ENTER\n"
	sh /etc/skt.d/tool/web/backup.bash	
fi