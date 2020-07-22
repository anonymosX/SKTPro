#!/bin/bash
domain=https://raw.githubusercontent.com/anonymosX/SKTPro/master/src
printf "       -----------------------------\n"
printf "        SKT TOOL | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "OPTIONS: \n"
printf "1. Install\n"
printf "2. Update\n"
printf "Enter: "
read slc
clear
if [ ${slc} = 0 ]; then
sh /root/install

elif [ ${slc} = 1 ]; then
{
if [ ! -d /etc/skt.d/tool ];then 
{
mkdir -p /etc/skt.d/tool
}
fi
yum install -y wget
mkdir -p /etc/skt.d/web/ /etc/skt.d/system/ /etc/skt.d/ssl/ /etc/skt.d/tool/ /etc/skt.d/mariadb/
# Install necessary files
# Tool
curl -N ${domain}/tool/tool-interface.bash | cat >> /etc/skt.d/tool/tool-interface.bash

# SSL
curl -N ${domain}/ssl/ssl-install.bash | cat >> /etc/skt.d/ssl/ssl-install.bash
curl -N ${domain}/ssl/ssl-interface.bash | cat >> /etc/skt.d/ssl/ssl-interface.bash
curl -N ${domain}/ssl/ssl-renew.bash | cat >> /etc/skt.d/ssl/ssl-renew.bash
curl -N ${domain}/ssl/ssl-status.bash | cat >> /etc/skt.d/ssl/ssl-status.bash

# System
curl -N ${domain}/system/install-lemp.bash | cat >> /etc/skt.d/system/install-lemp.bash 
curl -N ${domain}/system/mod_pagespeed.bash | cat >> /etc/skt.d/system/mod_pagespeed.bash 
curl -N ${domain}/system/system-interface.bash | cat >> /etc/skt.d/system/system-interface.bash 
# WEB
curl -N ${domain}/web/add-website.bash | cat >> /etc/skt.d/web/add-website.bash
curl -N ${domain}/web/backup-website.bash | cat >> /etc/skt.d/web/backup-website.bash
curl -N ${domain}/web/restore-website.bash | cat >> /etc/skt.d/web/restore-website.bash
curl -N ${domain}/web/web-interface.bash | cat >> /etc/skt.d/web/web-interface.bash
curl -N ${domain}/web/delete-website.bash | cat >> /etc/skt.d/web/delete-website.bash
curl -N ${domain}/web/info-website.bash | cat >> /etc/skt.d/web/info-website.bash
# MARIADB
curl -N ${domain}/mariadb/rename-mariadb.bash | cat >> /etc/skt.d/mariadb/mariadb.bash
chmod +x /etc/skt.d/ssl/* ; chmod +x /etc/skt.d/web/* ; chmod +x /etc/skt.d/system/* ; chmod +x /etc/skt.d/tool/* ; chmod +x /etc/skt.d/mariadb/*


}

elif [ ${slc} = 2 ]; then
{
rm -f /etc/skt.d/web/* /etc/skt.d/system/* /etc/skt.d/ssl/* /etc/skt.d/tool/* /root/install
# Tool
curl -N ${domain}/tool/tool-interface.bash | cat >> /etc/skt.d/tool/tool-interface.bash

# SSL
curl -N ${domain}/ssl/ssl-install.bash | cat >> /etc/skt.d/ssl/ssl-install.bash
curl -N ${domain}/ssl/ssl-interface.bash | cat >> /etc/skt.d/ssl/ssl-interface.bash
curl -N ${domain}/ssl/ssl-renew.bash | cat >> /etc/skt.d/ssl/ssl-renew.bash
curl -N ${domain}/ssl/ssl-status.bash | cat >> /etc/skt.d/ssl/ssl-status.bash

# System
curl -N ${domain}/system/install-lemp.bash | cat >> /etc/skt.d/system/install-lemp.bash 
curl -N ${domain}/system/mod_pagespeed.bash | cat >> /etc/skt.d/system/mod_pagespeed.bash 
curl -N ${domain}/system/system-interface.bash | cat >> /etc/skt.d/system/system-interface.bash 
# WEB
curl -N ${domain}/web/add-website.bash | cat >> /etc/skt.d/web/add-website.bash
curl -N ${domain}/web/backup-website.bash | cat >> /etc/skt.d/web/backup-website.bash
curl -N ${domain}/web/restore-website.bash | cat >> /etc/skt.d/web/restore-website.bash
curl -N ${domain}/web/web-interface.bash | cat >> /etc/skt.d/web/web-interface.bash
curl -N ${domain}/web/delete-website.bash | cat >> /etc/skt.d/web/delete-website.bash 
curl -N ${domain}/web/info-website.bash | cat >> /etc/skt.d/web/info-website.bash
# MARIADB
curl -N ${domain}/mariadb/rename-mariadb.bash | cat >> /etc/skt.d/mariadb/mariadb.bash
# INSTALL 
curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/install.bash | cat >> /root/install
chmod +x /etc/skt.d/ssl/* ; chmod +x /etc/skt.d/web/* ; chmod +x /etc/skt.d/system/* ; chmod +x /etc/skt.d/tool/* ; chmod +x /etc/skt.d/mariadb/* ; chmod +x /root/install
sh /etc/skt.d/tool/tool-interface.bash
}
else 
{
sh /etc/skt.d/tool/tool-interface.bash
}
fi
