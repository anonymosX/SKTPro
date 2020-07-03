#!/bin/bash

printf "       -----------------------------\n"
printf "        SSL MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "Options: \n"
printf "1. Renew\n"
printf "2. Check\n"
printf "Select: "
read slc1
if [ ${slc1} = 0 ]; then
cd /root && ./install
fi
if [ ${slc1} = 1 ]; then
cd /etc/skt.d/ssl/ && ./ssl-renew.bash
fi
if [ ${slc1} = 2 ]; then
cd /etc/skt.d/ssl/ && ./ssl-status.bash
fi
if [ ${slc1} != 0 -a ${slc1} != 1 -a ${slc1} != 2 ]; then
cd /etc/skt.d/ssl/ && ./ssl-interface.bash
fi



