#!/bin/bash
clear
printf "========================================================================\n"
printf " NINJA TOOL | TODAY: `date +%d-%m` |  DOMAINS: `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` | IP: `hostname -I | awk '{print $1}'`\n"
printf "========================================================================\n"
printf "1. WOOCOMMERCE                5. SSL    \n"
printf "2. DOMAIN                     6. TOOL       \n"
printf "3. CLOUDFLARE                 7. SERVER    \n"
printf "4. DATABASE                   8. SYSTEM     \n"
printf "Enter: "
read OPTION


if [ ! -f /etc/skt.d/tool/tool.bash ];then 
		mkdir -p /etc/skt.d/tool
	{
		curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/src/tool.bash | cat > /etc/skt.d/tool/tool.bash
	}
fi
# Check folder source status
if [ ! -d /etc/skt.d ]; then
	mkdir -p /etc/skt.d/tool/web /etc/skt.d/tool/ssl /etc/skt.d/tool/mariadb /etc/skt.d/tool/system
fi
if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh /etc/skt.d/tool/web/web.bash
elif [ $OPTION = 2 ]; then	
	clear
	sh /etc/skt.d/tool/domain/manDomain.bash 
elif [ $OPTION = 3 ]; then
	clear
	sh /etc/skt.d/tool/cloudflare/manCloudflare.bash 
elif [ $OPTION = 4 ]; then
    sh /etc/skt.d/tool/mariadb/mariadb.bash
elif [ $OPTION = 5 ]; then
	clear
	sh /etc/skt.d/tool/ssl/ssl.bash
elif [ $OPTION = 6 ]; then
	clear
	sh /etc/skt.d/tool/tool.bash
elif [ $OPTION = 7 ]; then	
	clear
	sh /etc/skt.d/tool/server/server.bash
elif [ $OPTION = 8 ]; then	
	clear
	sh /etc/skt.d/tool/system/system.bash
else
	clear
	printf "NINJA TOOL: INVALID ENTER\n"
	sh /root/install
fi
