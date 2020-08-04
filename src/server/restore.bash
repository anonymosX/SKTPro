#!/bin/bash
printf " -------------------------------------\n"
printf " RESTORE SERVER | IP:`hostname -I | awk '{print $1}'`\n"
printf " -------------------------------------\n"
printf "\n"
printf "DO YOU WANT TO RESTORE ENTIRE SERVER? - Y/N: "
read confirm
if [ $confirm = 0 ]; then
	clear
	sh /etc/skt.d/tool/server/server.bash
elif [ $confirm = 'Y' -o $confirm = 'y' ]; then
	if [ -f full_backup ]; then
	{
		clear
		cd /root && tar fxvz full_backup
		#move Block to home
		printf " ----------------------------\n"
		printf "1. EXTRACT CODE\n"
		cd /root && tar fxzP home.tar.gz
			yes | cp -rf home/* /home
			yes | cp -rf etc/* /etc
		printf "2. IMPORT SQL\n"
		cd /root && tar fxzP mysql.tar.gz
		for D in /home/*; do
			if [ -d ${D} ]; then
				d=${D##*/}
				source /etc/skt.d/data/${d}/${d}.mariadb
				mysql -u root -p$mdbp -e "create database ${dbn}"
				mysql -u root -p$mdbp -e "create user '${dbu}'@'localhost' identified by '${dbp}'"
				mysql -u root -p$mdbp -e "grant all on ${dbn}.* to ${dbu}@localhost"
				cd /root ; mysql -u root -p$mdbp ${dbn} < $d-$dbn.sql
				chmod 777 -R /home/${d}/public_html/wp-content
				chmod 777 /home/${d}/public_html/wp-config.php
			fi
		done
		cd /root
		rm -rf home.tar.gz mysql.tar.gz *.sql
		rm -rf etc home
	}
	else 
		clear
		printf "CAN'T FIND BACKUP FILE\n"
		sh /etc/skt.d/tool/server/server.bash
	fi
elif [ $confirm = 'N' -o $confirm = 'n' ];then
	clear
	printf "CANCEL RESTORE\n"
	sh /etc/skt.d/tool/server/server.bash
else
	clear
	printf "WRONG SELECT\n"
	sh /etc/skt.d/tool/server/server.bash
fi
