#!/bin/bash
printf "       ----------------\n"
printf "         MOVE SERVER \n"
printf "       ----------------\n"
printf "Options: \n"
printf "1. Backup Server\n"
printf "2. Restore Server\n"
read select 
if [ $select = 0 ]; then
	clear
	sh /root/install
elif [ $select = 1 ]; then
	clear
	sh /etc/skt.d/tool/server/move.bash
elif [ $select = 2 ]; then
	clear
	sh /etc/skt.d/tool/server/restore.bash
else
	clear
	sh /root/install
fi