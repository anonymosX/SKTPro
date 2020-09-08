#!/bin/bash
host="https://raw.githubusercontent.com/anonymosX/SKTPro/master"
#source /etc/skt.d/tool/data/host.txt
if [ ! -f /etc/skt.d/tool/data/host.txt ]; then
curl -N $host/src/data/host.txt | cat > /etc/skt.d/tool/data/host.txt  
fi
printf "   ##################################\n"
printf "            TOOL | TOOL MANAGE \n"
printf "   ##################################\n"
printf " 1. Install\n"
printf " 2. Update\n"
printf " 3. Previous/back\n"
printf "OPTION: "
read OPTION

if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
{
	mkdir -p /etc/skt.d/tool/data
	# DƠWNLOAD CONFIG FILE
	curl -N $host/src/data/host.txt        | cat > /etc/skt.d/tool/data/host.txt
	curl -N $host/src/data/folder.txt | cat > /etc/skt.d/tool/data/folder.txt
	curl -N $host/src/data/file.txt   | cat > /etc/skt.d/tool/data/file.txt
	curl -N $host/src/data/mail.txt | cat > /etc/skt.d/tool/data/mail.txt
	# CREATE FOLDERS
	while IFS= read -r line; do
		mkdir -p /etc/skt.d/tool/$line
	done < /etc/skt.d/tool/data/folder_config.txt
	# CREATE FILES
	while IFS= read -r download; do 
		curl -N $host/src/$download.bash    | cat > /etc/skt.d/tool/$download.bash
	done < /etc/skt.d/tool/data/file.txt
	clear
	chmod +x /etc/skt.d/tool/web/export_order.bash
	chmod +x /etc/skt.d/tool/web/mail.bash
	printf "\n"
	printf "Status: Installed tools!\n"
	sleep 2
	clear
	sh /root/install
}
elif [ $OPTION = 2 ]; then
	# UPDATE CONFIG FILE
	curl -N $host/src/data/host.txt        | cat > /etc/skt.d/tool/data/host.txt
	curl -N $host/src/data/folder.txt | cat > /etc/skt.d/tool/data/folder.txt
	curl -N $host/src/data/file.txt   | cat > /etc/skt.d/tool/data/file.txt
	curl -N $host/src/data/mail.txt | cat > /etc/skt.d/tool/data/mail.txt	curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/install.bash | cat > /root/install

	# UPDATE FILES
	while IFS= read -r download; do 
		curl -N $host/src/$download.bash | cat > /etc/skt.d/tool/$download.bash
	done < /etc/skt.d/tool/data/file.txt
	clear
	chmod +x /etc/skt.d/tool/web/export_order.bash
	chmod +x /etc/skt.d/tool/web/mail.bash
	printf "Status: Updated tools!\n"
	sleep 2
	clear
	sh /etc/skt.d/tool/tool.bash
elif [ $OPTION = 3 ]; then
	clear
	sh /root/install
else 
	clear
	printf "NINJA TOOL: INVALID SELECT\n"
	sh /etc/skt.d/tool/tool.bash
fi
