#!/bin/bash
clear
PATH=/etc/skt.d/tool
printf "========================================================================\n"
printf " NINJA TOOL | TODAY: `date +%d-%m` |  DOMAINS: `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` | IP: `hostname -I | awk '{print $1}'`\n"
printf "========================================================================\n"
printf "1. WOOCOMMERCE                5. SSL    \n"
printf "2. DOMAIN                     6. TOOL       \n"
printf "3. CLOUDFLARE                 7. SERVER    \n"
printf "4. DATABASE                   8. SYSTEM     \n"
printf "Enter: "
read OPTION



if [ ! -f $PATH/tool.bash ];then 
		mkdir -p $PATH
	{
		curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/src/tool.bash | cat > $PATH/tool.bash
	}
fi
# Check folder source status
if [ ! -d /etc/skt.d ]; then
	mkdir -p $PATH/web $PATH/ssl $PATH/mariadb $PATH/system
fi
if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	sh $PATH/web/web.bash
elif [ $OPTION = 2 ]; then	
	clear
	sh $PATH/domain/manDomain.bash 
elif [ $OPTION = 3 ]; then
	clear
	sh $PATH/cloudflare/manCloudflare.bash 
elif [ $OPTION = 4 ]; then
    sh $PATH/mariadb/mariadb.bash
elif [ $OPTION = 5 ]; then
	clear
	sh $PATH/ssl/ssl.bash
elif [ $OPTION = 6 ]; then
	clear
	sh $PATH/tool.bash
elif [ $OPTION = 7 ]; then	
	clear
	sh $PATH/server/server.bash
elif [ $OPTION = 8 ]; then	
	clear
	sh $PATH/system/system.bash
else
	clear
	printf "NINJA TOOL: INVALID ENTER\n"
	sh /root/install
fi
