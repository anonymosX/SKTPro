#!/bin/bash
printf " -------------------------------------\n"
printf " RESTORE SERVER | IP:`hostname -I | awk '{print $1}'`\n"
printf " -------------------------------------\n"
printf "\n"
printf "DO YOU WANT TO RESTORE ENTIRE SERVER? - Y/N: "
read CONFIRM
if [ $CONFIRM = 0 ]; then
	clear
	sh /etc/skt.d/tool/server/server.bash
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
{
	if [ -f full_backup ]; then
	{
		clear
		cd /root && tar fxvz full_backup
		#move Block to home
		printf " ----------------------------\n"
		printf "1. EXTRACT CODE\n"
		cd /root && tar fxzP home.tar.gz
			yes | cp -rf home/ /home
			yes | cp -rf etc/ /etc
		printf "2. IMPORT SQL\n"
		cd /root && tar fxzP mysql.tar.gz
		for D in /home/*; do
			if [ -d $D ]; then
				DOMAIN=${D##*/}
				source /etc/skt.d/data/$DOMAIN/sql.txt
				mysql -u root -p$mdbp -e "create database ${dbn}"
				mysql -u root -p$mdbp -e "create user '${dbu}'@'localhost' identified by '${dbp}'"
				mysql -u root -p$mdbp -e "grant all on ${dbn}.* to ${dbu}@localhost"
				cd /root ; mysql -u root -p$mdbp ${dbn} < $DOMAIN-$dbn.sql
				chmod 777 -R /home/$DOMAIN/public_html/wp-content
				chmod 777 /home/$DOMAIN/public_html/wp-config.php
			fi
		done
		cd /root
		rm -rf home.tar.gz mysql.tar.gz *.sql etc home
		systemctl restart nginx php-fpm mariadb		
	}
	else 
		clear
		printf "CAN'T FIND BACKUP FILE\n"
		sh /etc/skt.d/tool/server/server.bash
	fi
}
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
	clear
	printf "RESTORE HAS BEEN CANCLED\n"
	sh /etc/skt.d/tool/server/server.bash
else
	clear
	printf "WRONG SELECT\n"
	sh /etc/skt.d/tool/server/server.bash
fi
