#!/bin/bash
clear
printf "       -----------------------------\n"
printf "        VPS MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "1. Install LEMP\n"
printf "2. Update VPS\n"
printf "My Select: (Ctril + C to Cancel) "
read slc
if [ ${slc} = 0 ]; then
cd /root && ./install
fi
if [ ${slc} = 1 ]; then
printf "Do you want to install LEMP? -Y/N\n"
read qs
if [ $qs = 'Y' ]; then
cd /etc/skt.d/system && ./install-lemp.bash
fi
fi
if [ ${slc} = 2 ]; then
yum update -y --skip-broken
fi
if [ ${slc} != 0 -a ${slc} != 1 -a ${slc} != 2 ]; then
cd /etc/skt.d/system && ./system-interface.bash
fi