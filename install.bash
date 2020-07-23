#!/bin/bash
clear
domain=https://raw.githubusercontent.com/anonymosX/SKTPro/master
printf "========================================================================\n"
printf " Time: `date` | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains | IP: `hostname -I | awk '{print $1}'`\n"
printf "========================================================================\n"
printf "1. WEBSITE                       \n"
printf "2. DATABASE                       \n"
printf "3. SSL                       \n"
printf "4. TOOL                           \n"
printf "5. SYSTEM                       \n"
printf "Enter: "
read enter
clear
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
	sh /etc/skt.d/system/system.bash
else
	printf "CODE: INVALID ENTER\n"
	sh /root/install
fi
