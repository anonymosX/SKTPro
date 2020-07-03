#!/bin/bash
domain=https://raw.githubusercontent.com/anonymosX/SKTPro/master
printf "       -----------------------------\n"
printf "        SKT TOOL | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "1. Install\n"
printf "2. Update\n"
printf "Select: "
read slc
if [ ${slc} = 0 ]; then
cd /root && ./install
fi
if [ ${slc} = 1 ]; then
{
yum install -y wget
mkdir -p /etc/skt.d/web/
mkdir -p /etc/skt.d/system/
mkdir -p /etc/skt.d/ssl/
mkdir -p /etc/skt.d/tool/
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
# 

chmod +x /etc/skt.d/ssl/* ; chmod +x /etc/skt.d/web/* ; chmod +x /etc/skt.d/system/* ; chmod +x /etc/skt.d/tool/*

}
fi
if [ ${slc} = 2 ]; then
{
rm -f /etc/skt.d/web/*
rm -f /etc/skt.d/system/*
rm -f /etc/skt.d/ssl/*
# Tool
cur.l -N ${domain}/tool/tool-interface.bash | cat >> /etc/skt.d/tool/tool-interface.bash

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

chmod +x /etc/skt.d/ssl/* ; chmod +x /etc/skt.d/web/* ; chmod +x /etc/skt.d/system/* ; chmod +x /etc/skt.d/tool/*
cd /etc/skt.d/tool && ./tool-interface.bash
}
fi
if [ ${slc} != 0 -a ${slc} != 1 -a ${slc} != 2 ]; then
{
clear
cd /etc/skt.d/tool && ./tool-interface.bash
}
fi
