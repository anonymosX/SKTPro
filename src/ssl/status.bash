#!/bin/bash
# SHOW THESE DOMAINS ARE AVAILABLE IN SYSTEM!
printf "LIST DOMAINS:\n"
for D in /home/* ; do
	if [ -d ${D} ]; then
	printf " * ${D##*/}n" 
	fi
done
# GUI interface with user
printf "ENTER: "
read DOMAIN
printf "IS ${DOMAIN^^} CORRECT DOMAIN? - Y/N\: "
read CONFIRM
clear
if [ $CONFIRM = 0 ]; then
	sh /root/install
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
	printf "YOU HAVE CHOOSE YES\n"
# USE CERTBOT TO CHECK DOMAIN EXPIRE DATE
certbot certificates -d $DOMAIN
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
	printf "YOU HAVE CHOOSE NO\n"
	sh /etc/skt.d/tool/ssl/ssl.bash
else
	printf "CODE: INVALID ENTER\n"
	sh /etc/skt.d/tool/ssl/status.bash
fi