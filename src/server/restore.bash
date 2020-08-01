#!/bin/bash
printf " ---------------------------------------\n"
printf " RESTORE SERVER | CURRENT IP:`hostname -I | awk '{print $1}'`"
printf " ---------------------------------------\n"
printf "\n"
printf "Do u wannt to RESTORE server? - Y/N\n"
read confirm
if [ $confirm = 0 ]; then
	sh /etc/skt.d/tool/server/server.bash
elif [ $confirm = 'Y' -o $confirm = 'y' ];then
	#move Block to home
	cd /root ; tar -xzf home.tar.gz
		mv home/* /home
		mv etc/* /etc
	cd /root ; tar -xzf mysql.tar.gz
	for D in /home/*; do
		if [ -d ${D} ]; then
			d=${D##*/}
			source /etc/skt.d/${d}/${d}.mariadb
			mysql -u root -p$mdbp -e "create dababase ${dbn}"
			mysql -u root -p$mdbp -e "create user '${dbu}'@'localhost' identified by '${dbp}"
			mysql -u root -p$mdbp -e "grant all on ${dbn}.* to ${dbu}@localhost"
			mysql -u root -p$mdbp ${dbn} < $d-$dbn.sql
			chmod 777 -R /home/${d}/public_html/wp-content
			chmod 777 /home/${d}/public_html/wp-config.php
		fi
	rm -rf *.tar.gz *.sql
	done
elif [ $confirm = 'N' -o $confirm = 'n' ];then
	printf "You have cancel RESTORE\n"
	sh /etc/skt.d/tool/server/server.bash
else
	printf "Have error in restore server\n"
fi
