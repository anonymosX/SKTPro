#!/bin/bash
sh /root
printf "       -----------------------------\n"
printf "        WEBSITE MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "\n"
printf "Options:\n"
printf "1. Add                        5. Login Detail\n"
printf "2. Delete                            \n"
printf "3. Backup                            \n"
printf "4. Restore\n" 
printf "Select: " 
read slc
clear
if [ ${slc} = 0 ]; then
	sh /root/install
elif [ ${slc} = 1 ]; then
	sh /etc/skt.d/web/add-website.bash
elif  [ ${slc} = 2 ]; then	
	sh /etc/skt.d/web/delete-website.bash
elif  [ ${slc} = 3 ]; then	
	sh /etc/skt.d/web/backup-website.bash
elif  [ ${slc} = 4 ]; then
	sh /etc/skt.d/web/restore-website.bash
elif  [ ${slc} = 5 ]; then	
	printf "List domains:\n"
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
	sh /etc/skt.d/web/web-interface.bash
}
else
{	
	sh /etc/skt.d/web/web-interface.bash
}
fi
