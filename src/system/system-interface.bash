#!/bin/bash
clear
printf "System Manage by SKT Pro\n"
printf "1. Install LEMP\n"
printf "2. Update\n"
printf "My Select: (Ctril + C to Cancel) "
read slc
if [ ${slc} = 0 ]; then
cd /root && ./install
fi
if [ ${slc} = 1 ]; then
cd /etc/skt.d/system && ./install-lemp.bash
fi
if [ ${slc} = 2 ]; then
yum update -y --skip-broken
fi
if [ ${slc} != 0 -a ${slc} != 1 -a ${slc} != 2 ]; then
cd /etc/skt.d/system && ./system-interface.bash
fi