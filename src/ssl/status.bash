#!/bin/bash
# SHOW THESE DOMAINS ARE AVAILABLE IN SYSTEM!
printf "LIST DOMAINS:\n"
for D in /home/* ; do
	if [ -d ${D} ]; then
	d=${D##*/}
	printf " * ${d}\n" 
	fi
done
# GUI interface with user
printf "ENTER: "
read d
printf "IS ${d^^} CORRECT DOMAIN? - Y/N\n"
read YN
clear
if [ ${YN} = 0 ]; then
	sh /root/install
elif [ ${YN} = 'Y' -o ${YN} = 'y' ]; then
	printf "YOU HAVE CHOOSE YES\n"
# USE CERTBOT TO CHECK DOMAIN EXPIRE DATE
certbot certificates -d ${d}
elif [ ${YN} = 'N' -o ${YN} = 'n' ]; then
	printf "YOU HAVE CHOOSE NO\n"
	sh /etc/skt.d/tool/ssl/ssl.bash
else
	printf "CODE: INVALID ENTER\n"
	sh /etc/skt.d/tool/ssl/status.bash
fi