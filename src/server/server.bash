#!/bin/bash
printf "       ----------------\n"
printf "         MOVE SERVER \n"
printf "       ----------------\n"
printf "OPTIONS: \n"
printf "1. BACKUP SERVER\n"
printf "2. RESTORE SERVER\n"
read OPTION 
if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh /etc/skt.d/tool/server/move.bash
elif [ $OPTION = 2 ]; then
	clear
	#RESTORE
	sh /etc/skt.d/tool/server/restore.bash

else
	clear
	sh /root/install
fi