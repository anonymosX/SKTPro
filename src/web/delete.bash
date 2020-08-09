#!/bin/bash
printf "Found `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "List domains: \n"
for D in /home/* ; do
	if [ -d ${D} ]; then
		d=${D##*/}
		printf " * $d\n"
	fi
done
printf " ---------\n"
printf "ENTER: "
read d
printf "ARE YOU SURE TO DELETE ${d^^}? - Y/N: "
read YN
if [ ${YN} = 0 ]; then
	clear
	printf "CANCEL DELETE\n"
	sh /etc/skt.d/tool/web/web.bash
elif [ ${YN} = 'Y' -o ${YN} = 'y' ]; then
{
	clear
	printf "PROCESS DELETE ${d^^}\n"
	# DELETE CODE
	rm -rf /home/${d}
	rm -rf /etc/nginx/conf.d/${d}.conf
	rm -rf /etc/nginx/conf.d/${d}.conf.80
	rm -rf /etc/letsencrypt/live/${d}
	find /etc/letsencrypt/renewal/ -type f -name "${d}*.conf" -delete
	rm -rf /etc/letsencrypt/archive/${d}

	# DELETE DATABASE
	source /etc/skt.d/data/${d}/sql.txt
	printf "drop database ${dbn}" | mysql
	printf "DROP USER '${dbu}'@'localhost'" | mysql
	printf "flush privileges" | mysql
	printf "exit" | mysql
	rm -rf /etc/skt.d/data/${d}
	clear
	printf "${d^^} HAS DELETED\n"
	sh /etc/skt.d/tool/web/web.bash
}
elif [ ${YN} = 'N' -o ${YN} = 'n' ]; then
{
	clear
	sh /etc/skt.d/tool/web/web.bash
}

else
	clear
	printf "INVALID SELECT\n"
	sh /etc/skt.d/tool/web/delete.bash
fi