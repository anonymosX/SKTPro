#!/bin/bash
printf "Have `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domain on server\n"
printf "Availables domain: \n"
for D in /home/* ; do
if [ -d ${D} ]; then
d=${D##*/}
printf " - $d\n"
fi
done
printf " -------------------------------\n"
printf "Enter delete domain: "
read d
printf "Do you want to delete ${d^^}? - Y/N\n"
read qs
if [ ${qs} = 'Y' ]; then
{
# Delete CODE
rm -rf /home/${d}
rm -rf /etc/nginx/conf.d/${d}.conf
rm -rf /etc/nginx/conf.d/${d}.conf.80
rm -rf /etc/letsencrypt/live/${d}
find /etc/letsencrypt/renewal/ -type f -name "${d}*.conf" -delete
rm -rf /etc/letsencrypt/archive/${d}

# Delete DATABASE
source /etc/skt.d/${d}/${d}.mariadb
printf "drop database ${dbn}" | mysql
printf "DROP USER '${dbu}'@'localhost'" | mysql
printf "flush privileges" | mysql
printf "exit" | mysql
rm -rf /etc/skt.d/${d}/
printf "The ${d} has been deleted\n"
cd /etc/skt.d/web && ./web-interface.bash
}
fi
if [ ${qs} != 'Y' ]; then
{
clear
cd /etc/skt.d/web && ./web-interface.bash
}
fi