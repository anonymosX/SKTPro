#!/bin/bash
clear
printf " 				--------------------\n"
printf "				RENAME DATABASE NAME\n"
printf " 				--------------------\n"
printf "\n"
# Available domains
printf "Domain: \n"
for D in /home/* ; do
if [ -d $D ]; then
d=${D##*/}
printf " * $d\n"
fi
done
printf "Enter: "
read d
printf "Rename old ${d^^}'s database? (Y/N): "
read YN
if [ ${YN} = Y -o ${YN} = y ]; then 
{
	source /etc/skt.d/${d}/${d}.mariadb
	# workflow: 
	# 1. export database -> A, create new database name B, import A -> B, remove database A
	# 2. create new username, password. drop user old username, grant access new to database B.
	# 3. re-config wordpress setting
	# export old database
	# variant
	newdbn="`openssl rand -base64 40 | tr -d /+= | cut -c -30`"
	newdbu="`openssl rand -base64 40 | tr -d /+= | cut -c -30`"
	newdbp="`openssl rand -base64 40 | tr -d /+= | cut -c -30`"
	mysqldump -u root -p$mdbp $dbn > $dbn.sql
	mysql -u root -p$mdbp -e "create database ${newdbn}"
	# import old DB to new DB
	mysql -u root -p$mdbp $newdbn < $dbn.sql
	mysql -u root -p$mdbp -e "create user '${newdbu}'@'localhost' identified by '${newdbp}'"
	mysql -u root -p$mdbp -e "grant all on $newdbn.* to ${newdbu}@localhost"
	mysql -u root -p$mdbp -e "flush privileges"
	# drop old DB
	mysql -u root -p$mdbp -e "drop database ${dbn}"
	# drop old USER
	mysql -u root -p$mdbp -e "drop user '$dbu'@'localhost'"
	# re-config wordpress

	sed -i "s/${dbn}/${newdbn}/g" /home/${d}/public_html/wp-config.php
	sed -i "s/${dbu}/${newdbu}/g" /home/${d}/public_html/wp-config.php
	sed -i "s/${dbp}/${newdbp}/g" /home/${d}/public_html/wp-config.php

	# save database info
	sed -i "s/${dbn}/${newdbn}/g" /etc/skt.d/${d}/${d}.mariadb
	sed -i "s/${dbu}/${newdbu}/g" /etc/skt.d/${d}/${d}.mariadb
	sed -i "s/${dbp}/${newdbp}/g" /etc/skt.d/${d}/${d}.mariadb
	# remove trash
	cd /root && rm -f $dbn.sql
}
elif [ ${YN} = N -o ${YN} = n ]; then
{
	printf "You have cancel RENAME database\n"
	cd /root && sh install
}
else 
{
	printf "Code: Invaild Anwers\n"
}
fi