#!/bin/bash
clear
domain=https://raw.githubusercontent.com/anonymosX/SKTPro/master
printf "========================================================================\n"
printf " Server Timezone: `date` | IP: `hostname -I | awk '{print $1}'`\n"
printf "========================================================================\n"
printf "1. Website                       \n"
printf "2. Database                       \n"
printf "3. SSL                       \n"
printf "4. Tool                           \n"
printf "5. System                       \n"
printf "Enter: "
read slc
clear
# Check folder source status
if [ ! -d /etc/skt.d ]; then
	mkdir -p /etc/skt.d/web /etc/skt.d/ssl /etc/skt.d/mariadb /etc/skt.d/tool /etc/skt.d/system
fi
if [ ${slc} = 0 ]; then
	sh /root/install
elif [ ${slc} = 1 ]; then
	sh /etc/skt.d/web/web-interface.bash
elif [ ${slc} = 2 ]; then	
	sh /etc/skt.d/mariadb/mariadb.bash 
elif [ ${slc} = 3 ]; then
	sh /etc/skt.d/ssl/ssl-interface.bash
elif [ ${slc} = 4 ]; then
	if [ ! -f /etc/skt.d/tool/tool-interface.bash ];then
	curl -N ${domain}/src/tool/tool-interface.bash | cat >> /etc/skt.d/tool/tool-interface.bash
	chmod +x /etc/skt.d/tool/tool-interface.bash
	fi
    sh /etc/skt.d/tool/tool-interface.bash
elif [ ${slc} = 5 ]; then
	sh /etc/skt.d/system/system-interface.bash
else
	printf "CODE: INVALID ANSWER\n"
	sh /root/install
fi
