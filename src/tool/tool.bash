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
alias ninja="sh install"
yum install -y wget
mkdir -p /etc/skt.d/tool/web /etc/skt.d/tool/system /etc/skt.d/tool/ssl /etc/skt.d/tool /etc/skt.d/tool/mariadb
# Install necessary files

# SSL
curl -N ${url}/ssl/install.bash | cat >> /etc/skt.d/tool/ssl/install.bash
curl -N ${url}/ssl/ssl.bash | cat >> /etc/skt.d/tool/ssl/ssl.bash
curl -N ${url}/ssl/renew.bash | cat >> /etc/skt.d/tool/ssl/renew.bash
curl -N ${url}/ssl/status.bash | cat >> /etc/skt.d/tool/ssl/status.bash

# System
curl -N ${url}/system/install.bash | cat >> /etc/skt.d/tool/system/install.bash 
curl -N ${url}/system/mod_pagespeed.bash | cat >> /etc/skt.d/tool/system/mod_pagespeed.bash 
curl -N ${url}/system/system.bash | cat >> /etc/skt.d/tool/system/system.bash 
curl -N ${url}/system/lemp.bash | cat >> /etc/skt.d/tool/system/lemp.bash 
# WEB
curl -N ${url}/web/add.bash | cat >> /etc/skt.d/tool/web/add.bash
curl -N ${url}/web/backup.bash | cat >> /etc/skt.d/tool/web/backup.bash
curl -N ${url}/web/restore.bash | cat >> /etc/skt.d/tool/web/restore.bash
curl -N ${url}/web/web.bash | cat >> /etc/skt.d/tool/web/web.bash
curl -N ${url}/web/delete.bash | cat >> /etc/skt.d/tool/web/delete.bash
# MARIADB
curl -N ${url}/mariadb/mariadb.bash | cat >> /etc/skt.d/tool/mariadb/mariadb.bash
}
	printf "INSTALLED NINJA TOOL\n"
	sh /root/install
elif [ ${enter} = 2 ]; then
{
rm -rf /etc/skt.d/tool/web/* /etc/skt.d/tool/system/* /etc/skt.d/tool/ssl/* /etc/skt.d/tool/mariadb/*
mkdir -p /etc/skt.d/tool/web /etc/skt.d/tool/system /etc/skt.d/tool/ssl /etc/skt.d/tool /etc/skt.d/tool/mariadb
# SSL
curl -N ${url}/ssl/install.bash | cat >> /etc/skt.d/tool/ssl/install.bash
curl -N ${url}/ssl/ssl.bash | cat >> /etc/skt.d/tool/ssl/ssl.bash
curl -N ${url}/ssl/renew.bash | cat >> /etc/skt.d/tool/ssl/renew.bash
curl -N ${url}/ssl/status.bash | cat >> /etc/skt.d/tool/ssl/status.bash

# System
curl -N ${url}/system/install.bash | cat >> /etc/skt.d/tool/system/install.bash 
curl -N ${url}/system/mod_pagespeed.bash | cat >> /etc/skt.d/tool/system/mod_pagespeed.bash 
curl -N ${url}/system/system.bash | cat >> /etc/skt.d/tool/system/system.bash 
curl -N ${url}/system/lemp.bash | cat >> /etc/skt.d/tool/system/lemp.bash 
# WEB
curl -N ${url}/web/add.bash | cat >> /etc/skt.d/tool/web/add.bash
curl -N ${url}/web/backup.bash | cat >> /etc/skt.d/tool/web/backup.bash
curl -N ${url}/web/restore.bash | cat >> /etc/skt.d/tool/web/restore.bash
curl -N ${url}/web/web.bash | cat >> /etc/skt.d/tool/web/web.bash
curl -N ${url}/web/delete.bash | cat >> /etc/skt.d/tool/web/delete.bash
# MARIADB
curl -N ${url}/mariadb/mariadb.bash | cat >> /etc/skt.d/tool/mariadb/mariadb.bash
# INSTALL 
curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/install.bash | cat >> /root/install
	printf "UPDATED NINJA TOOL\n"
	sh /root/install
}
else 
	sh /etc/skt.d/tool/tool.bash
fi
