#!/bin/bash
printf "       -----------------------------\n"
printf "        DATBASE MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "\n"
printf "Option:\n"
printf "1. Rename\n"
printf "2. View\n"
printf "Enter: "
read answer
# RETURN HOME
if [ $answer = '0' ]; then
{
	clear
	sh /root/install
}
# RENAME DB
elif [ $answer = '1' ]; then
{
	clear
	printf " --------------------\n"
	printf " RENAME DATABASE NAME\n"
	printf " --------------------\n"
	printf "\n"
	# LIST DOMAINS
	printf "LIST DOMAINS: \n"
	for D in /home/* ; do
	if [ -d $D ]; then
		d=${D##*/}
		printf " * $d\n"
	fi
	done
	printf "ENTER: "
	read d
	printf "RENAME OLD ${d^^}'s DATABASE? (Y/N): "
	read YN
if [ ${YN} = Y -o ${YN} = y ]; then 
{
	clear
	source /etc/skt.d/data/${d}/${d}.mariadb
	# WORKFLOW: 
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
	sed -i "s/${dbn}/${newdbn}/g" /etc/skt.d/data/${d}/${d}.mariadb
	sed -i "s/${dbu}/${newdbu}/g" /etc/skt.d/data/${d}/${d}.mariadb
	sed -i "s/${dbp}/${newdbp}/g" /etc/skt.d/data/${d}/${d}.mariadb
	# remove trash
	cd /root && rm -f $dbn.sql
	printf "Success rename\n"
	printf "Result:\n"
	source /etc/skt.d/data/${d}/${d}.mariadb
	printf "\n"
	printf "${d^^}\nDatabase Name: ${dbn} \nUsername: ${dbu}\nUsername Password: ${dbp}\nRoot Password: ${mdbp}\n"
	printf "End Result.\n"
}
elif [ ${YN} = N -o ${YN} = n ]; then
{
	clear
	printf "CANCEL RENAME\n"
	sh /etc/skt.d/tool/mariadb/mariadb.bash
}
else 
{
	clear
	printf "Code: Invaild Anwers\n"
}
fi
	sh /etc/skt.d/tool/mariadb/mariadb.bash
}

# VIEW DB
elif [ $answer = '2' ]; then
{
	clear
	printf " 				--------------------\n"
	printf "				VIEW DATABASE NAME\n"
	printf " 				--------------------\n"
	printf "List domains:\n"
	for D in /home/* ; do
	if [ -d ${D} ];then
	d=${D##*/}
	printf "* ${d}\n"
	fi
	done
	printf "Enter: "
	read d
	printf "\n"
	source /etc/skt.d/data/${d}/${d}.mariadb
	printf " ----------------\n"
	printf "Result:\n"
	printf "${d^^}\nDatabase Name: ${dbn} \nUsername: ${dbu}\nUsername Password: ${dbp}\nRoot Password: ${mdbp}\n"
	printf "End Result.\n"
	sh /etc/skt.d/tool/mariadb/mariadb.bash
}
# ELSE
else	
	printf "Code: Invaild Answer!\n"
	sh /etc/skt.d/tool/mariadb/mariadb.bash
fi