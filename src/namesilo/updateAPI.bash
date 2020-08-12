#!/bin/bash
printf " ------------------------------------\n"
printf " UPDATE API | API MANAGE | NAMESILO  \n"
printf " ------------------------------------\n"
printf "Enter Information: \n"
# /etc/skt.d/data/namesilo/namesilo_$NUMBER.txt
printf "Number: "
read NUMBER
printf "New API: "
read newAPI

API=`sed -n "1p" /etc/skt.d/data/namesilo/namesilo_$NUMBER.txt`
for D in home/*; do
	DOMAIN=${D##*/}
	if [ `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_ns.txt` = $API ]; then
		sed -i "s/$API/$newAPI/g" /etc/skt.d/data/$DOMAIN/api_ns.txt
	fi
done

sed -i "s/$API/$newAPI/g" /etc/skt.d/data/namesilo/namesilo_$NUMBER.txt
clear
printf "Update API successful\n"
sh /etc/skt.d/tool/namesilo/manDomain.bash

if [ $NUMBER = 0 -o $newAPI = 0 ]; then
	sh /etc/skt.d/tool/namesilo/manDomain.bash
fi
