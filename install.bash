#!/bin/bash
clear
url=/etc/skt.d/tool
printf "========================================================================\n"
printf " NINJA TOOL | TODAY: `date +%d-%m` |  DOMAINS: `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` | IP: `hostname -I | awk '{print $1}'`\n"
printf "========================================================================\n"
printf "1. WOOCOMMERCE                5. SSL    \n"
printf "2. DOMAIN                     6. TOOL       \n"
printf "3. CLOUDFLARE                 7. SERVER    \n"
printf "4. DATABASE                   8. SYSTEM     \n"
printf "Enter: "
read OPTION



if [ ! -f $url/tool.bash ];then 
	{
		mkdir -p $url
		curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/src/tool.bash | cat > $url/tool.bash
	}
fi
# Check folder source status
if [ ! -d /etc/skt.d ]; then
	mkdir -p $url/web $url/ssl $url/mariadb $url/system
fi
if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh $url/web/web.bash
elif [ $OPTION = 2 ]; then	
	clear
	sh $url/domain/manDomain.bash 
elif [ $OPTION = 3 ]; then
	clear
	sh $url/cloudflare/manCloudflare.bash 
elif [ $OPTION = 4 ]; then
    sh $url/mariadb/mariadb.bash
elif [ $OPTION = 5 ]; then
	clear
	sh $url/ssl/ssl.bash
elif [ $OPTION = 6 ]; then
	clear
	sh $url/tool.bash
elif [ $OPTION = 7 ]; then	
	clear
	sh $url/server/server.bash
elif [ $OPTION = 8 ]; then	
	clear
	sh $url/system/system.bash
else
	clear
	printf "NINJA TOOL: INVALID ENTER\n"
	sh /root/install
fi
