#!/bin/bash
printf " --------------------------\n"
printf "   BALANCE | PAYPAL\n"
printf " --------------------------\n"
printf "OPTION: \n"
printf " 1. 1 paypal\n"
printf " 2. All paypals\n"
printf " 3. Update Token\n"
printf " 4. Previous/Back\n"
printf "OPTION: "
read OPTION
if [ $OPTION = 0 ]; then
	clear
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	printf "List available: \n"
	cat /etc/skt.d/data/paypal/vps.txt
	printf "OPTION: "
	read VPS
	curl -X GET "https://api.paypal.com/v1/reporting/balances?currency_code=USD" \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer `sed -n "1p" /etc/skt.d/data/paypal/token/${VPS}_access_token`" | python -m json.tool | jq -r ".balances[].total_balance.value,.balances[].available_balance.value,.balances[].withheld_balance.value" | cat > /etc/skt.d/data/paypal/balance/${VPS}_balance
	clear
	printf " * Paypal ${VPS}  Balance: \n"
	printf "Total     : `sed -n "1p" /etc/skt.d/data/paypal/balance/${VPS}_balance` USD\n"
	printf "Available : `sed -n "2p" /etc/skt.d/data/paypal/balance/${VPS}_balance` USD\n"
	printf "Hold      : `sed -n "3p" /etc/skt.d/data/paypal/balance/${VPS}_balance` USD\n"
	sh /etc/skt.d/tool/paypal/balance.bash		
elif [ $OPTION = 2 ]; then
	clear
	#refresh balance
	rm -f /etc/skt.d/data/paypal/balance/*
	while IFS= read -r VPS
	do
	curl -X GET "https://api.paypal.com/v1/reporting/balances?currency_code=USD" \
	-H "Content-Type: application/json" \
	-H "Authorization: Bearer `sed -n "1p" /etc/skt.d/data/paypal/token/${VPS}_access_token`"  | python -m json.tool | jq -r ".balances[].available_balance.value,.balances[].withheld_balance.value" | cat > /etc/skt.d/data/paypal/balance/${VPS}_balance
	done < /etc/skt.d/data/paypal/vps.txt
	clear
	printf "VPS  |   Available  |  Hold \n"
	while IFS= read -r VPS
	do
	printf " + Paypal ${VPS} | `sed -n "1p" /etc/skt.d/data/paypal/balance/${VPS}_balance` | `sed -n "2p" /etc/skt.d/data/paypal/balance/${VPS}_balance` USD\n"
	printf " \n"
	done < /etc/skt.d/data/paypal/vps.txt
	sh /etc/skt.d/tool/paypal/balance.bash
elif [ $OPTION = 3 ]; then
	#UPDATE ALL ACCESS TOKEN
	while IFS= read -r line
	do
printf "Loading: "
	curl -# -POST "https://api.paypal.com/v1/oauth2/token" \
	-H "Accept: application/json" \
	-H "Accept-Language: en_US" \
	-u "`sed -n "1p" /etc/skt.d/data/paypal/API/${line}_clientid_secret_key`" \
	-d "grant_type=client_credentials" | python -m json.tool | printf `jq '.access_token'` | cat > /etc/skt.d/data/paypal/token/${line}_access_token
	sed -i 's/"//g' /etc/skt.d/data/paypal/token/${line}_access_token
	done < /etc/skt.d/data/paypal/vps.txt
	clear
	sh /etc/skt.d/tool/paypal/balance.bash
#OPTION 4
elif [ $OPTION  = 4 ]; then
	clear
	sh /etc/skt.d/tool/paypal/paypal.bash
	
else
	clear
	printf "404: Error, wrong option\n"
	sh /etc/skt.d/tool/paypal/balance.bash
fi

