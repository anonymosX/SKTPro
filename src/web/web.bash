#!/bin/bash
printf "       ---------------------------------\n"
printf "        WEBSITE MANAGE | FOUND `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS\n"
printf "       ---------------------------------\n"
printf "\n"
printf "OPTIONS:\n"
printf "1. ADD                         6. Update Plugins\n"
printf "2. DELETE                      7. Update Wordpress\n"
printf "3. BACKUP                      8. Login Detail      \n"
printf "4. RESTORE                     9. List Domains\n" 
printf "5. IMPORT/EXPORT ORDERS        \n" 
printf "ENTER: " 
read OPTION
clear
if [ $OPTION = 0 ]; then
	sh /root/install
elif [ $OPTION = 1 ]; then
	sh /etc/skt.d/tool/web/add.bash
elif  [ $OPTION = 2 ]; then	
	sh /etc/skt.d/tool/web/delete.bash
elif  [ $OPTION = 3 ]; then	
	sh /etc/skt.d/tool/web/backup.bash
elif  [ $OPTION = 4 ]; then
	sh /etc/skt.d/tool/web/restore.bash
elif  [ $OPTION = 5 ]; then
	sh /etc/skt.d/tool/web/rest_api.bash
elif  [ $OPTION = 6 ]; then
	printf "       ---------------------------------\n"
	printf "        UPDATE PLUGIN | FOUND `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS\n"
	printf "       ---------------------------------\n"
	printf "CHOOSE VERSION\n"
	printf "1. 1 WEBSITE\n2. ALL WEBSITE\n"
	read OPTION2
	if [ ${OPTION2} = 0 ];then
		sh /etc/skt.d/tool/web/web.bash
	elif [ ${OPTION2} = 1 ];then
		for D in /home/* ; do
		if [ -d ${D} ];then
			DOMAIN=${D##*/}
			printf " - ${DOMAIN}\n"
		fi
		done
		printf "ENTER: "
		read DOMAIN
		printf "\n"
		printf "DO YOU WANT TO UPDATE PLUGIN FOR ${d^^}? -Y/N: "
		read CONFIRM
		if [ $CONFIRM = 0 ]; then
			sh /etc/skt.d/tool/web/web.bash
		elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
			wp plugin update --all --path=/home/$DOMAIN/public_html
		elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
			sh /etc/skt.d/tool/web/web.bash
		else
			printf "CODE: INVALID VERSION\n"
			sh /etc/skt.d/tool/web/web.bash
		fi
	elif [ ${OPTION2} = 2 ];then
		for D in /home/* ; do
		if [ -d ${D} ];then
			DOMAIN=${D##*/}
			wp plugin update --all --path=/home/$DOMAIN/public_html
			printf " UPDATED PLUGIN FOR $DOMAIN\n"
		fi
		done
	else
		printf "CODE: INVALID VERSION\n"
		sh /etc/skt.d/tool/web/web.bash
	fi	
elif  [ $OPTION = 7 ]; then
		for D in /home/* ; do
		if [ -d ${D} ];then
			DOMAIN=${D##*/}
			wp core update --path=/home/$DOMAIN/public_html
		fi
		done
elif  [ $OPTION = 8 ]; then	
	printf "FOUND `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS:\n"
	for D in /home/* ; do
	if [ -d ${D} ];then
		DOMAIN=${D##*/}
		printf " - $DOMAIN\n"
	fi
	done
	printf "ENTER: "
	read DOMAIN
	printf "\n"
	source /etc/skt.d/data/$DOMAIN/login.txt
	printf " ----------------\n"
		printf "RESULT:\n"
		printf "${DOMAIN^^}\n Username: ${wp_usr}\n Password: ${wp_pass}\n Email: $EMAIL\n"
		printf "End Result.\n"
	sh /etc/skt.d/tool/web/web.bash
elif [ $OPTION = 9 ]; then
	printf "       ------------------------------------\n"
	printf "        AVAILABLE DOMAIN | FOUND `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS\n"
	printf "       -----------------------------------\n"
	for D in /home/* ; do
	if [ -d ${D} ];then
		DOMAIN=${D##*/}
		printf " * $DOMAIN\n"
	fi
	done
	printf "\n"
	sh /etc/skt.d/tool/web/web.bash
	
	
else
	sh /etc/skt.d/tool/web/web.bash
fi
