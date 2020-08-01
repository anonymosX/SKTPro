#!/bin/bash
clear
url=https://raw.githubusercontent.com/anonymosX/SKTPro/master/src
printf "========================================================================\n"
printf " NINJA TOOL | TODAY: `date +%d-%m` |  DOMAINS: `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` | IP: `hostname -I | awk '{print $1}'`\n"
printf "========================================================================\n"
printf "1. WEBSITE                5. SYSTEM       \n"
printf "2. DATABASE               6. SERVER       \n"
printf "3. SSL                       \n"
printf "4. TOOL                           \n"
printf "Enter: "
read enter
clear
	if [ ! -f /etc/skt.d/tool/tool.bash ];then 
	{
		mkdir -p /etc/skt.d/tool
		curl -N ${url}/tool/tool.bash | cat >> /etc/skt.d/tool/tool.bash
	}
	fi
# Check folder source status
if [ ! -d /etc/skt.d ]; then
	mkdir -p /etc/skt.d/tool/web /etc/skt.d/tool/ssl /etc/skt.d/tool/mariadb /etc/skt.d/tool/system
fi
if [ ${enter} = 0 ]; then
	sh /root/install
elif [ ${enter} = 1 ]; then
	sh /etc/skt.d/tool/web/web.bash
elif [ ${enter} = 2 ]; then	
	sh /etc/skt.d/tool/mariadb/mariadb.bash 
elif [ ${enter} = 3 ]; then
	sh /etc/skt.d/tool/ssl/ssl.bash
elif [ ${enter} = 4 ]; then
	if [ ! -f /etc/skt.d/tool/tool.bash ];then
	curl -N ${domain}/src/tool/tool.bash | cat >> /etc/skt.d/tool/tool.bash
	chmod +x /etc/skt.d/tool/tool.bash
	fi
    sh /etc/skt.d/tool/tool.bash
elif [ ${enter} = 5 ]; then
	sh /etc/skt.d/tool/system/system.bash
elif [ ${enter} = 6 ]; then
	sh /etc/skt.d/tool/server.bash
else
	printf "CODE: INVALID ENTER\n"
	sh /root/install
fi
