#!/bin/bash
printf "FOUND `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS\n"
printf "LIST DOMAINS: \n"
for D in /home/* ; do
	if [ -d $D ]; then
		printf " * ${D##*/}\n"
	fi
done
printf " ---------\n"
printf "ENTER: "
read DOMAIN
printf "ARE YOU SURE TO DELETE ${DOMAIN^^}? - Y/N: "
read CONFIRM
if [ $CONFIRM = 0 ]; then
	clear
	printf "YOUR REQUEST DELETE WAS CANCELED\n"
	sh /etc/skt.d/tool/web/web.bash
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
{
	clear
	printf "PROCESS DELETE ${DOMAIN^^}\n"
	# DELETE CODE
	rm -rf /home/$DOMAIN
	rm -rf /etc/nginx/conf.d/$DOMAIN.conf
	rm -rf /etc/nginx/conf.d/$DOMAIN.conf.80
	rm -rf /etc/letsencrypt/live/$DOMAIN
	find /etc/letsencrypt/renewal/ -type f -name "${DOMAIN}*.conf" -delete
	rm -rf /etc/letsencrypt/archive/$DOMAIN

	# DELETE DATABASE
	source /etc/skt.d/data/$DOMAIN/sql.txt
	printf "drop database ${dbn}" | mysql
	printf "DROP USER '${dbu}'@'localhost'" | mysql
	printf "flush privileges" | mysql
	printf "exit" | mysql
	rm -rf /etc/skt.d/data/$DOMAIN
	clear
	printf "${DOMAIN^^} HAS DELETED\n"
	sh /etc/skt.d/tool/web/web.bash
}
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
{
	clear
	sh /etc/skt.d/tool/web/web.bash
}

else
	clear
	printf "INVALID SELECT\n"
	sh /etc/skt.d/tool/web/delete.bash
fi