#!/bin/bash

printf " ---------------------------------------\n"
printf " BACKUP SERVER | CURRENT IP:`hostname -I | awk '{print $1}'`"
printf " ---------------------------------------\n"
printf "\n"
printf "Enter new server: "
read newhost
printf "\n"
printf "Password: "
read passwd
printf "\n"

printf "Do u wanna backup? - (Y/N)\n"
read confirm
if [ $confirm = 0 ];then
	sh /etc/skt.d/tool/server/server.bash
elif [ $confirm = 'Y' -o $confirm = 'y' ]; then
{
	# BackUp BLOCK
	cd /root && tar -czf home.tar.gz /home /etc/skt.d /etc/letsencrypt /etc/nginx/conf.d

	# BackUp MYSQL
	for D in /home/*; do
		if [ -d ${D} ]; then
			d=${D##*/}
			source /etc/skt.d/${d}/${d}.mariadb
			mysqldump -u root -p$mdbp $dbn > $d-$dbn.sql
		fi
	done
	cd /root && tar -zcf mysql.tar.gz *.sql 
	rm -f *.sql
	printf $passwd | scp home.tar.gz root@${newhost}:/root
	printf $passwd | scp mysql.tar.gz root@${newhost}:/root
}
elif [ $confirm = 'N' -o $confirm = 'n' ]; then
{
	printf "Rejected to BACKUP\n"
	sh /etc/skt.d/tool/server/server.bash
}
else 
	sh /etc/skt.d/tool/server/server.bash
fi