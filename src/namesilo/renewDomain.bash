#!/bin/bash
printf " =========================\n"
printf " NINJA TOOL | RENEW DOMAIN\n"
printf " =========================\n"
printf "LIST DOMAINS: \n"
for D in /home/*; do
        if [ -d $D ]; then
                printf " - ${D##*/}\n"
        fi
done
printf "ENTER: "
read DOMAIN
printf "\n"
printf "DO YOU WANT TO RENEW ${DOMAIN^^}? - (Y/N)"
read CONFIRM
if [ $CONFIRM = 0 ]; then
        clear
        sh /root/install
elif [ $CONFIRM = 'Y' -o $CONFIRM = 'y' ]; then
        clear
        mkdir -p /root/$DOMAIN
        curl -X GET "https://www.namesilo.com/api/renewDomain?version=1&type=xml&key=`sed -n "1p" /etc/skt.d/data/$DOMAIN/api_ns.txt`&domain=$DOMAIN&years=1" | cat > /root/$DOMAIN/renew_result.xml
        CODE=(grep -oP '(?<=code>)[^<]+' "/root/renew_result.xml")
        printf "\n"
        if [ $CODE = 300 ]; then
                printf "YOUR ${DOMAIN^^} REGISTRATION WAS SUCCESSFULLY PROCESSED.\n"
        elif [ $CODE = 110 ]; then
                printf "INVALID API KEY\n"
        elif [ $CODE = 200 ]; then
                printf "DOMAIN IS NOT ACTIVE, OR DOES NOT BELONG TO THIS USER\n"
        else
                printf "OTHER ERROR\n"
        fi
        rm -rf /root/$DOMAIN
elif [ $CONFIRM = 'N' -o $CONFIRM = 'n' ]; then
        clear
        printf "THE REQUEST WAS CANCELED\n"
        sh /etc/skt.d/tool/namesilo/renewDomain.bash
else
        clear
        printf "CONFIRM ERROR\n"
        sh /etc/skt.d/tool/namesilo/manDomain.bash
fi
