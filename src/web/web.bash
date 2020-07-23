#!/bin/bash
printf "       ---------------------------------\n"
printf "        WEBSITE MANAGE | Found `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       ---------------------------------\n"
printf "\n"
printf "OPTIONS:\n"
printf "1. ADD                         5. UPDATE PLUGIN\n"
printf "2. DELETE                      6. LOGIN DETAIL\n"
printf "3. BACKUP                      7. LIST DOMAINS      \n"
printf "4. RESTORE\n" 
printf "ENTER: " 
read enter
clear
if [ ${enter} = 0 ]; then
	sh /root/install
elif [ ${enter} = 1 ]; then
	sh /etc/skt.d/tool/web/add.bash
elif  [ ${enter} = 2 ]; then	
	sh /etc/skt.d/tool/web/delete.bash
elif  [ ${enter} = 3 ]; then	
	sh /etc/skt.d/tool/web/backup.bash
elif  [ ${enter} = 4 ]; then
	sh /etc/skt.d/tool/web/restore.bash
elif  [ ${enter} = 5 ]; then
	printf "       ---------------------------------\n"
	printf "        UPDATE PLUGIN | Found `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
	printf "       ---------------------------------\n"
	printf "CHOOSE VERSION\n"
	printf "1. 1 website\n2. All website\n"
	read version
	if [ ${version} = 0 ];then
		sh /etc/skt.d/tool/web/web.bash
	elif [ ${version} = 1 ];then
		for D in /home/* ; do
		if [ -d ${D} ];then
			d=${D##*/}
			printf " * ${d}\n"
		fi
		done
		printf "ENTER: "
		read d
		printf "\n"
		printf "DO YOU WANT TO UPDATE PLUGIN FOR ${d^^}? -Y/N\n"
		read YN
		if [ ${YN} = 0 ]; then
			sh /etc/skt.d/tool/web/web.bash
		elif [ ${YN} = 'Y' -o ${YN} = 'y' ]; then
			wp plugin update --all --path=/home/${d}/public_html
		elif [ ${YN} = 'N' -o ${YN} = 'n' ]; then
			sh /etc/skt.d/tool/web/web.bash
		else
			printf "CODE: INVALID VERSION\n"
			sh /etc/skt.d/tool/web/web.bash
		fi
	elif [ ${version} = 2 ];then
		for D in /home/* ; do
		if [ -d ${D} ];then
			d=${D##*/}
			wp plugin update --all --path=/home/${d}/public_html
			printf " Updated plugin for ${d}\n"
		fi
		done
	else
		printf "CODE: INVALID VERSION\n"
		sh /etc/skt.d/tool/web/web.bash
	fi	
elif  [ ${enter} = 6 ]; then	
	printf "Found `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains:\n"
	for D in /home/* ; do
	if [ -d ${D} ];then
		d=${D##*/}
		printf " * ${d}\n"
	fi
	done
	printf "Enter: "
	read d
	printf "\n"
	source /etc/skt.d/${d}/${d}.login
	printf " ----------------\n"
		printf "Result:\n"
		printf "${d^^} login\n Username: ${wp_usr}\n Password: ${wp_pass}\n Email: ${e}\n"
		printf "End Result.\n"
	sh /etc/skt.d/tool/web/web.bash
elif [ ${enter} = 7 ]; then
	printf "       ------------------------------------\n"
	printf "        AVAILABLE DOMAIN | Found `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
	printf "       -----------------------------------\n"
	for D in /home/* ; do
	if [ -d ${D} ];then
		d=${D##*/}
		printf " * ${d}\n"
	fi
	done
	printf "\n"
	sh /etc/skt.d/tool/web.bash
	
	
else
	sh /etc/skt.d/tool/web/web.bash
fi
