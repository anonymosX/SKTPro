#!/bin/bash
clear
t=`date`

printf "========================================================================\n"
printf "        Server Timezone: $t | IP: `hostname -I | awk '{print $1}'`\n"
printf "========================================================================\n"
printf "1. Website                       3. Tool\n"
printf "2. SSL                           4. System\n"
printf "Select: "
read slc
# Check folder source status
if [ ! -d /etc/skt.d ]; then
mkdir -p /etc/skt.d/web
mkdir -p /etc/skt.d/ssl
mkdir -p /etc/skt.d/tool
mkdir -p /etc/skt.d/system
fi
if [ ${slc} = 0 ]; then
clear
cd /root && ./install
fi
if [ ${slc} = 1 ]; then
clear
cd /etc/skt.d/web && ./web-interface.bash
fi
if [ ${slc} = 2 ]; then
clear
cd /etc/skt.d/ssl && ./ssl-interface.bash
fi
if [ ${slc} = 3 ]; then
clear
if [ ! -f /etc/skt.d/tool/tool-interface.bash ];then
curl -N ${d}/tool/tool-interface.bash | cat >> /etc/skt.d/tool/tool-interface.bash
chmod +x /etc/skt.d/tool/tool-interface.bash
fi
cd /etc/skt.d/tool && ./tool-interface.bash
fi
if [ ${slc} = 4 ]; then
clear
cd /etc/skt.d/system && ./system-interface.bash
fi
if [ ${slc} != 0 -a ${slc} != 1 -a ${slc} != 2 -a ${slc} != 3 -a ${slc} != 4 ]; then
clear
cd /root && ./install
fi
