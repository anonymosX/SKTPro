#!/bin/bash
#workflow: show login info, database info <- show all website
#count how many domain in server: find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "                Have `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n" 
printf "Option: \n"
printf "1. Login                  2. Database\n"
printf "\n"
printf "Select: "
read slc
# Return Home
if [ ${slc} = 0 ]; then
clearcd
cd /root && ./install
fi
# Show Login
if [ $slc = 1 ]; then
printf "List domains:\n"
for D in /home/* ; do
if [ -d ${D} ];then
d=${D##*/}
printf "* ${d}\n"
fi
done
printf "Enter: "
read enter
printf "\n"
source /etc/skt.d/${enter}/${enter}.login
printf "${enter^^} login\n Username: ${wp_usr}\n Password: ${wp_pass}\n Email: ${e}\n"
cd /etc/skt.d/web && ./info-interface.bash
fi

# Show DataBase
if [ $slc = 2 ]; then
printf "List domains:\n"
for D in /home/* ; do
if [ -d ${D} ];then
d=${D##*/}
printf "* ${d}\n"
fi
done
printf "Enter: "
read enter
printf "\n"
source /etc/skt.d/${enter}/${enter}.mariadb
printf "${enter^^}\nDatabase Name: ${dbn} \nUsername: ${dbu}\nUsername Password: ${dbp}\nRoot Password: ${mdbp}\n"
cd /etc/skt.d/web && ./info-interface.bash
fi
# Else
if [ ${slc} != 0 -a ${slc} != 1 -a ${slc} != 2 ]; then
clear
cd /etc/skt.d/web && ./web-interface.bash
fi