#!/bin/bash
printf " --------------------------\n"
printf "   FULFILLMENT | PAYPAL\n"
printf " --------------------------\n"
printf "OPTION: \n"
printf " 1. Declare API\n"
printf " 2. Fulfillment\n"
printf " 3. Update Token\n"
printf " 4. Previous/Back\n"
printf "OPTION: "
read OPTION
#OPTION 0
if [ $OPTION = 0 ]; then
        sh /root/install
#OPTION 1
elif [ $OPTION = 1 ] ; then
	#KHAI BAO CILENT ID vs SECRET KEY
	printf "Declare API PayPal:\n"
	printf "1. VPS name: "
	read VPS
	printf "2. Client ID: "
	read client_id
	printf "3. Secret Key: "
	read secret_key
	printf ${client_id}:${secret_key} | cat > /etc/skt.d/data/paypal/API/${VPS}_clientid_secret_key
	printf "\n$VPS" | cat >> /etc/skt.d/data/paypal/vps.txt
sh /etc/skt.d/tool/paypal/fulfill.bash

#OPTION 2
elif [ $OPTION  = 2 ]; then
printf " --------------------------\n"
printf "   FULFILLMENT | PAYPAL\n"
printf " --------------------------\n"
printf "Do you want to update new access token: "
read OPTION-UPDATE
if [ ${OPTION-UPDATE} = Y -o ${OPTION-UPDATE} = y ]; then
	#UPDATE ALL ACCESS TOKEN
	while IFS= read -r line; do
	curl -v POST https://api.paypal.com/v1/oauth2/token \
	  -H "Accept: application/json" \
	  -H "Accept-Language: en_US" \
	  -u "`sed -n "1p" /etc/skt.d/data/paypal/API/${line}_clientid_secret_key`" \
	  -d "grant_type=client_credentials" \ | python -m json.tool | printf `jq  -r ".access_token"` | cat > /etc/skt.d/data/paypal/token/${line}_access_token
	done < /etc/skt.d/data/paypal/vps.txt
elif [ ${OPTION-UPDATE} = N -o ${OPTION-UPDATE} = n ]; then
	printf "No update this time\n"
else
	printf "OTHER ERROR\n"
fi
#FULFIL TRACKING
while IFS=$'\t' read -r -a TRANSACTION
do
curl -v -X POST https://api.paypal.com/v1/shipping/trackers-batch \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer `sed -n "1p" /etc/skt.d/data/paypal/token/${TRANSACTION[0]}_access_token`" \
  -d '{
  "trackers": [
    {
      "transaction_id": "'${TRANSACTION[1]}'",
      "tracking_number": "'${TRANSACTION[2]}'",
      "status": "SHIPPED",
      "carrier": "OTHER",
      "carrier_name_other": "USPS",
      "notify_buyer":"true"
    }
  ]
}' \ | python -m json.tool | printf "Đã ép thành công transaction id: `jq -r ".tracker_identifiers[].transaction_id"`: ${TRANSACTION[2]}\n"
done < track.txt
#FORMAT track.txt file
#E4 8MC585209K746392H 9400109205568128990983
#E5 8MC585209K746392H 9400109205568743137961
#OPTION 3
elif [ $OPTION  = 3 ]; then
	while IFS= read -r VPS; do
	curl -v POST https://api.paypal.com/v1/oauth2/token \
	  -H "Accept: application/json" \
	  -H "Accept-Language: en_US" \
	  -u "`sed -n "1p" /etc/skt.d/data/paypal/API/${VPS}_clientid_secret_key`" \
	  -d "grant_type=client_credentials" \ | python -m json.tool | printf `jq -r ".access_token"` | cat > /etc/skt.d/data/paypal/token/${VPS}_access_token
	done < /etc/skt.d/data/paypal/vps.txt
	sh /etc/skt.d/tool/paypal/fulfill.bash
#OPTION 4
elif [ $OPTION  = 4 ]; then
	clear
	sh /etc/skt.d/tool/paypal/paypal.bash
else
    sh /etc/skt.d/tool/paypal/fulfill.bash
fi


