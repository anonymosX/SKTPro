#!/bin/bash
printf "       -----------------------------\n"
printf "        DATBASE MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` DOMAINS\n"
printf "       -----------------------------\n"
printf "\n"
printf "OPTION:\n"
printf "1. RENAME\n"
printf "2. VIEW\n"
printf "ENTER: "
read OPTION
# RETURN HOME
if [ $OPTION = '0' ]; then
{
	clear
	sh /root/install
}
# RENAME DB
elif [ $OPTION = '1' ]; then
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
		DOMAIN=${D##*/}
		printf " * $DOMAIN\n"
	fi
	done
	printf "ENTER: "
	read DOMAIN
	printf "RENAME OLD ${d^^}'s DATABASE? (Y/N): "
	read CONFIRM
if [ $CONFIRM = Y -o $CONFIRM = y ]; then 
{
	clear
	source /etc/skt.d/data/$DOMAIN/sql.txt
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

	sed -i "s/${dbn}/${newdbn}/g" /home/$DOMAIN/public_html/wp-config.php
	sed -i "s/${dbu}/${newdbu}/g" /home/$DOMAIN/public_html/wp-config.php
	sed -i "s/${dbp}/${newdbp}/g" /home/$DOMAIN/public_html/wp-config.php

	# save database info
	sed -i "s/${dbn}/${newdbn}/g" /etc/skt.d/data/$DOMAIN/sql.txt
	sed -i "s/${dbu}/${newdbu}/g" /etc/skt.d/data/$DOMAIN/sql.txt
	sed -i "s/${dbp}/${newdbp}/g" /etc/skt.d/data/$DOMAIN/sql.txt
	# remove trash
	cd /root && rm -f $dbn.sql
	printf "Success rename\n"
	printf "Result:\n"
	source /etc/skt.d/data/$DOMAIN/sql.txt
	printf "\n"
	printf "${d^^}\nDatabase Name: ${dbn} \nUsername: ${dbu}\nUsername Password: ${dbp}\nRoot Password: ${mdbp}\n"
	printf "End Result.\n"
}
elif [ $CONFIRM = N -o $CONFIRM = n ]; then
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
elif [ $OPTION = '2' ]; then
{
	clear
	printf " 				--------------------\n"
	printf "				VIEW DATABASE NAME\n"
	printf " 				--------------------\n"
	printf "LIST DOMAINS:\n"
	for D in /home/* ; do
	if [ -d $DOMAIN ];then
	d=${D##*/}
	printf "* $DOMAIN\n"
	fi
	done
	printf "Enter: "
	read d
	printf "\n"
	source /etc/skt.d/data/$DOMAIN/sql.txt
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