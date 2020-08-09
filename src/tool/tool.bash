#!/bin/bash
url=https://raw.githubusercontent.com/anonymosX/SKTPro/master/src
printf "       -----------------------------\n"
printf "        NINJA TOOL | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains \n"
printf "        USE COMMAND: NINJA to RUN APP\n"
printf "       -----------------------------\n"
printf "OPTIONS: \n"
printf "1. INSTALL\n"
printf "2. UPDATE\n"
printf "ENTER: "
read enter
clear
if [ ${enter} = 0 ]; then
	sh /root/install
elif [ ${enter} = 1 ]; then
{
	yum install -y wget
	mkdir -p /etc/skt.d/tool
	cd /etc/skt.d/tool && mkdir -p web system ssl mariadb server domain
	curl -N $url/config.txt | cat > /etc/skt.d/tool/config.txt
	while IFS= read -r line; do 
		curl -N ${url}/$line.bash | cat > /etc/skt.d/tool/$line.bash
	done < "/etc/skt.d/tool/config.txt"
	clear
	printf "NINJA TOOL: INSTALLED\n"
	sh /root/install
}
elif [ ${enter} = 2 ]; then
	curl -N $url/config.txt | cat > /etc/skt.d/tool/config.txt
	cd /etc/skt.d/tool && rm -f web/* system/* ssl/* mariadb/* server/* domain/*
	while IFS= read -r line; do 
		curl -N ${url}/$line.bash | cat > /etc/skt.d/tool/$line.bash
	done < "/etc/skt.d/tool/config.txt"
	clear
	printf "NINJA TOOl: UPDATED\n"
else 
	clear
	printf "NINJA TOOL: INVALID SELECT\n"
	sh /etc/skt.d/tool/tool.bash
fi
