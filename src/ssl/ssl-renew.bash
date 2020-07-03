#!/bin/bash
clear
# Show these domains are available in system!
printf "Domains in server\n"
for D in /home/* ; do
if [ -d ${D} ]; then
d=${D##*/}
printf " - ${d}\n" 
fi
done
# GUI interface with user
printf "Enter domain: "
read d
# Use certbot to renew domain expire
certbot renew --cert-name ${d}
