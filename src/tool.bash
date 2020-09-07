#!/bin/bash
source /etc/skt.d/data/host.txt
printf "   ##################################\n"
printf "            TOOL | TOOL MANAGE \n"
printf "   ##################################\n"
printf "OPTIONS: \n"
printf " 1. INSTALL\n"
printf " 2. UPDATE\n"
printf " 3. PREVIOUS/BACK\n"
printf "OPTION: "
read OPTION

if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
{
	mkdir -p /etc/skt.d/tool/data
	# DƠWNLOAD CONFIG FILE
	curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/src/data/host.txt        | cat > /etc/skt.d/tool/data/host.txt
	curl -N $host/data/folder_config.txt | cat > /etc/skt.d/tool/data/folder_config.txt
	curl -N $host/data/file_config.txt   | cat > /etc/skt.d/tool/data/file_config.txt
	curl -N $host/data/mail.bash         | cat > /etc/skt.d/tool/data/mail.bash
	# CREATE FOLDERS
	while IFS= read -r line; do
		mkdir -p /etc/skt.d/tool/$line
	done < /etc/skt.d/tool/data/folder_config.txt
	# CREATE FILES
	while IFS= read -r line; do 
		curl -N $host/$line.bash    | cat > /etc/skt.d/tool/$line.bash
	done < /etc/skt.d/tool/data/file_config.txt
	clear
	chmod +x /etc/skt.d/tool/web/export_order.bash
	printf "\n"
	printf "NINJA TOOL: INSTALLED\n"
	sh /root/install
}
elif [ $OPTION = 2 ]; then
	# UPDATE CONFIG FILE
	curl -N $host/data/folder_config.txt | cat > /etc/skt.d/tool/data/folder_config.txt
	curl -N $host/data/file_config.txt   | cat > /etc/skt.d/tool/data/file_config.txt
	curl -N $host/data/mail.txt        | cat > /etc/skt.d/tool/data/mail.txt
	curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/install.bash | cat > /root/install

	# UPDATE FILES
	while IFS= read -r line; do 
		curl -N $host/$line.bash | cat > /etc/skt.d/tool/$line.bash
	done < /etc/skt.d/tool/data/file_config.txt
	clear
	chmod +x /etc/skt.d/tool/web/export_order.bash
	printf "NINJA TOOl: UPDATED\n"
	sleep 5
	sh /etc/skt.d/tool/tool.bash
elif [ $OPTION = 3 ]; then
	clear
	sh /root/install
else 
	clear
	printf "NINJA TOOL: INVALID SELECT\n"
	sh /etc/skt.d/tool/tool.bash
fi
