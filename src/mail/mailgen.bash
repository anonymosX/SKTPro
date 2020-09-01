#!/bin/bash
# CREATE MAIL FOR YANDEX API
# DEFINE INFO in yandex.api
DOMAIN=`sed -n "1p" /etc/skt.d/data/mail/yandex.api`
PddToken=`sed -n "2p" /etc/skt.d/data/mail/yandex.api`

# PUT VALUE in /root/name.txt

#while IFS= read -r line; do COMMAND_on $line; done < input.file
sed -i "s/ //g" /root/name.txt
# REFRESH DATA
rm -f /root/mail.txt
touch  /root/mail.txt

# READ USERNAME
while IFS= read -r line; do
USER=$line
PASSWORD=`openssl rand -base64 32 | tr -d /=+ | cut -c -15`
curl -X POST "https://pddimp.yandex.ru/api2/admin/email/add" \
	 -H "PddToken: ${PddToken}" \
	 --data "domain=$DOMAIN&login=${USER,,}&password=$PASSWORD"  | python -m json.tool
printf "${line}|${USER,,}@${DOMAIN}|${PASSWORD}\n" | cat >> /root/mail.txt
done < /root/name.txt

clear
# printf RESULT
cat /root/mail.txt
