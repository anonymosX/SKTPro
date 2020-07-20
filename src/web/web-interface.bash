#!/bin/bash
cd /root
printf "       -----------------------------\n"
printf "        WEBSITE MANAGE | `find /home -mindepth 1 -maxdepth 1 -type d | wc -l` domains\n"
printf "       -----------------------------\n"
printf "\n"
printf "Options:\n"
printf "1. Add                        3. Backup\n"
printf "2. Delete                     4. Restore\n"
printf "5. Infor\n"
printf "Select: "
read slc
if [ ${slc} = 0 ]; then
clear
cd /root && ./install
fi
if [ ${slc} = 1 ]; then
clear
cd /etc/skt.d/web && ./add-website.bash
fi
if [ ${slc} = 2 ]; then
clear
cd /etc/skt.d/web && ./delete-website.bash
fi
if [ ${slc} = 3 ]; then
clear
cd /etc/skt.d/web && ./backup-website.bash
fi
if [ ${slc} = 4 ]; then
clear
cd /etc/skt.d/web && ./restore-website.bash
fi
if [ ${slc} != 0 -a ${slc} != 1 -a ${slc} != 2 -a ${slc} != 3 -a ${slc} != 4 ]; then
clear
cd /etc/skt.d/web && ./web-interface.bash
fi
