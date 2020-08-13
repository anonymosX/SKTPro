#!/bin/bash
url=https://raw.githubusercontent.com/anonymosX/SKTPro/master/src
printf "       -----------------------------\n"
printf "        NINJA TOOL | TOOL MANAGE \n"
printf "       -----------------------------\n"
printf "OPTIONS: \n"
printf "1. INSTALL\n"
printf "2. UPDATE\n"
printf "OPTION: "
read OPTION

if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
{
	mkdir -p /etc/skt.d/tool
	# DƠWNLOAD CONFIG FILE
	curl -N $url/data/folder_config.txt | cat > /etc/skt.d/tool/data/folder_config.txt
	curl -N $url/data/file_config.txt   | cat > /etc/skt.d/tool/data/file_config.txt
	curl -N $url/data/mail.bash         | cat > /etc/skt.d/tool/data/mail.bash
	# CREATE FOLDERS
	while IFS= read -r line; do
		mkdir -p /etc/skt.d/tool/$line
	done < "/etc/skt.d/tool/data/folder_config.txt"
	# CREATE FILES
	while IFS= read -r line; do 
		curl -N $url/$line.bash    | cat > /etc/skt.d/tool/$line.bash
	done < "/etc/skt.d/tool/data/file_config.txt"
	clear
	printf "\n"
	printf "NINJA TOOL: INSTALLED\n"
	sh /root/install
}
elif [ $OPTION = 2 ]; then
	# UPDATE CONFIG FILE
	curl -N $url/data/folder_config.txt | cat > /etc/skt.d/tool/data/folder_config.txt
	curl -N $url/data/file_config.txt   | cat > /etc/skt.d/tool/data/file_config.txt
	curl -N $url/data/mail.bash         | cat > /etc/skt.d/tool/data/mail.bash
	curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/install.bash | cat > /root/install

	# UPDATE FILES
	while IFS= read -r line; do 
		curl -N $url/$line.bash | cat > /etc/skt.d/tool/$line.bash
	done < "/etc/skt.d/tool/data/file_config.txt"
	clear
	printf "NINJA TOOl: UPDATED\n"
	sh /etc/skt.d/tool/tool.bash
else 
	clear
	printf "NINJA TOOL: INVALID SELECT\n"
	sh /etc/skt.d/tool/tool.bash
fi
