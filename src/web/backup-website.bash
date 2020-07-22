#!/bin/bash
printf "Found `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
for D in /home/* ; do
if [ -d $D ]; then
d=${D##*/}
printf " * $d\n"
fi
done
printf " -------------------------------\n"
printf "Enter domain: "
read d
printf "Want back up ${d^^}? - Y/N\n"
read qs
if [ ${qs} = 'Y' ]; then
{
source /etc/skt.d/${d}/${d}.mariadb
clear
cd /root
# NGINX and SOURCE CODE
printf "1. Backup Source Code\n"
tar -czf $d.tar.gz /etc/letsencrypt/live/${d}/* /etc/letsencrypt/archive/${d}/* /etc/letsencrypt/renewal/${d}.conf /etc/nginx/conf.d/${d}.conf.80 /etc/nginx/conf.d/${d}.conf /home/$d/public_html /etc/skt.d/${d}/${d}.mariadb /etc/skt.d/${d}/${d}.login
printf "2. Done!!! - source code\n"
# MySQL
printf "3. Backup MYSQL\n"
mysqldump -u root -p$mdbp $dbn > $d-$dbn.sql
printf "4. Done!!! - MYSQL\n"
#cd ./
tar -czf full-$d-$(date +"%d-%m-%Y").tar.gz  $d.tar.gz $d-$dbn.sql
printf "5.Removing Trash...\n"
rm -rf  $d.tar.gz $d-$dbn.sql
clear
printf "6.Backup complete\n"
printf "The ${d} has been backup\n"
clear
cd /etc/skt.d/web && ./web-interface.bash
}
fi
if [ ${qs} != 'Y' ]; then
{
clear
cd /etc/skt.d/web && ./web-interface.bash
}
fi