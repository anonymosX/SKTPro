#!/bin/bash
printf " ---------------------------------------\n"
printf " BACKUP SERVER | IP:`hostname -I | awk '{print $1}'`\n"
printf " ---------------------------------------\n"
printf "\n"
printf "DO YOU WANT TO BACKUP ENTIRE SERVER? - (Y/N): "
read confirm
if [ $confirm = 0 ];then
	clear
	sh /etc/skt.d/tool/server/server.bash
elif [ $confirm = 'Y' -o $confirm = 'y' ]; then
{
	clear
	# BackUp BLOCK
	printf "1. PROCESS CODE AND CONFIG\n"
	cd /root && tar fczP home.tar.gz /home /etc/skt.d /etc/letsencrypt /etc/nginx/conf.d
	printf "\n"
    printf "2. PROCESS SQL\n"
	# BackUp MYSQL
	for D in /home/*; do
		if [ -d ${D} ]; then
			d=${D##*/}
			source /etc/skt.d/data/${d}/sql.txt
			mysqldump -u root -p$mdbp $dbn > $d-$dbn.sql
		fi
	done
	cd /root && tar fczvP mysql.tar.gz *.sql
	printf "3. CREATE FULL BACKUP SERVER FILE\n"
	cd /root && tar fczvP full_backup mysql.tar.gz home.tar.gz
	rm -f *.sql home.tar.gz mysql.tar.gz

}
elif [ $confirm = 'N' -o $confirm = 'n' ]; then
{
	clear
	printf "CANCEL BACKUP\n"
	sh /etc/skt.d/tool/server/server.bash
}
else 
	clear
	sh /etc/skt.d/tool/server/server.bash
fi