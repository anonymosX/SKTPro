#!/bin/bash
clear
printf "Enter Restore Domain: "
read d
printf "Do you want to restore ${d^^}? - Y/N\n"
read qs
clear
if [ ${qs} = 'Y' -o ${qs} = 'y' ]; then
{
# create server block, log
mkdir -p /etc/skt.d/${d} /home/$d/public_html /home/$d/log /etc/letsencrypt/live/${d}
touch /home/$d/log/error.log && chmod +x /home/$d/log/error.log


cd /root
find /root -type f -name "full-${d}*.tar.gz" -exec tar -xzf {} \;
tar -xzf $d.tar.gz
yes | cp -rf etc/skt.d/* /etc/skt.d
yes | cp -rf etc/nginx/conf.d/* /etc/nginx/conf.d
yes | cp -rf home/${d}/public_html/* /home/${d}/public_html
yes | cp -rf etc/letsencrypt/live/${d}/* /etc/letsencrypt/live/${d}
yes | cp -rf etc/letsencrypt/renewal/${d}.conf /etc/letsencrypt/renewal/
yes | cp -rf etc/letsencrypt/archive/${d} /etc/letsencrypt/archive
# IMPORT DATABASES
source /etc/skt.d/${d}/${d}.mariadb
printf "create database ${dbn}" | mysql
printf "create user '${dbu}'@'localhost' identified by '${dbp}'" | mysql
printf "grant all on ${dbn}.* to ${dbu}@localhost" | mysql
printf "flush privileges" | mysql
mysql -u root -p$mdbp $dbn < $d-$dbn.sql
rm -rf etc home
find /root -type f -name "full-{d}*.tar.gz" -delete
rm -rf ${d}-${dbn}.sql
chmod 777 -R /home/$d/public_html/wp-content
chmod 777 /home/$d/public_html/wp-config.php
#chmod 755 -R /home/$d/public_html/wp-content
printf "The ${d} has been RESTORED\n"
systemctl restart nginx
sh /etc/skt.d/web/web-interface.bash
}
fi
if [ ${qs} != 'Y' ]; then
{
sh /etc/skt.d/web/web-interface.bash
}
fi