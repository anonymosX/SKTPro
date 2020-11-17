#!/bin/bash
#FORMAT track.txt file
#E4 8MC585209K746392H W5-27672 9400109205568128990983 USPS
#E5 8MC585209K746392H W5-27672 9400109205568743137961 USPS
printf " ###############################\n"
printf " REST API | WOOCOMMERCE | PAYPAL\n"
printf " ###############################\n"
printf "1. Declare REST API\n"
printf "2. Import Track (PP + Woo)\n"
printf "3. Export Order\n"
printf "4. Delete On Hold\n"
printf "5. Previous/Back\n"
printf "OPTION: "
read OPTION


if [ $OPTION = 0 ]; then
	sh /root/install
elif [ $OPTION = 1 ]; then
	clear
	printf " ###############################\n"
	printf " Declare | REST API | WEBSITE\n"
	printf " ###############################\n"
	printf "1. Platform: \n"
	printf " 1.Woocommerce\n"
	printf " 2.Shopify\n"
	printf "Enter value-(1 or 2): "
	read PLATFORM
	printf "2. Platform number: "
	read NUMBER
	printf "3. URL: "
	read URL
	printf "4. Key: "
	read KEY
	printf "5. Pass: "
	read PASS
	if [ $PLATFORM = 1 ]; then
	printf "W|${NUMBER}|${URL}|${KEY}|${PASS}\n" | cat >> /etc/skt.d/data/team/api.txt
	printf "${URL}|{KEY}|${PASS}\n" | cat > /etc/skt.d/data/team/W${NUMBER}
	fi
	if [ $PLATFORM = 2 ]; then
	printf "S|${NUMBER}|${URL}|${KEY}|${PASS}\n" | cat >> /etc/skt.d/data/team/api.txt
	printf "${URL}|{KEY}|${PASS}\n" | cat > /etc/skt.d/data/team/S${NUMBER}	
	fi
	
#/etc/skt.d/data/woocommerce/all-invoice.txt
#WC5 url5 consumer_key5:consumer_secret5
#WC6 url6 consumer_key6:consumer_secret6
#	sh /etc/skt.d/tool/web/rest_api.bash
=======
#/etc/skt.d/data/team/api.txt
#W|1|url1|key1|pass1
#W|2|url2|key2|pass2
sh /etc/skt.d/tool/web/rest_api.bash


elif [ $OPTION = 2 ]; then
clear
printf "IMPORTANT: ORDER IS INCLUDED IMPORT TO WOOCOMMERCE, SHOPIFY AND PAYPAL ALSO\n" 
printf "DO YOU WANT TO IMPORT TRACKING NUMBER? - (Y/N): "
read QUESTION
if [ $QUESTION = Y -o $QUESTION = y ]; then
#READ FILE track.txt then find REST API
#IMPORT TRACK TO WOOCOMMERCE PLATFORM

while IFS=$'\t'	read -r -a TRACK
do
PLATFORM="`printf "${TRACK[2]}" | head -c1`"
#IMPORT TRACK TO WOOCOMMERCE
if [ ${PLATFORM} == "W" ]; then
IFS="-" ; read -r -a WOO<<<"${TRACK[2]}"
IFS="|" ; read -r -a WOOCOMMERCE<<<"`cat /etc/skt.d/data/team/${WOO[0]}`"
curl -X POST https://${WOOCOMMERCE[0]}/wp-json/wc/v3/orders/${WOO[1]}/shipment-trackings \
	-# \
	-u "${WOOCOMMERCE[1]}:${WOOCOMMERCE[2]}" \
	-H "Content-Type: application/json" \
	-d '{
	"tracking_provider": "'${TRACK[4]}'",
	"tracking_number": "'${TRACK[3]}'"  
	}' \ | python -m json.tool
curl -X PUT https://${WOOCOMMERCE[0]}/wp-json/wc/v3/orders/${WOO[1]} \
	-# \
    -u "${WOOCOMMERCE[1]}:${WOOCOMMERCE[2]}" \
    -H "Content-Type: application/json" \
    -d '{
  "status": "completed" 
  }' \ | python -m json.tool
fi
#IMPORT TRACK TO SHOPIFY PLATFORM
if [ ${PLATFORM} == "S" ]; then
IFS="-" ; read -r -a SHOPIFY<<<"${TRACK[2]}"
IFS="|" ; read -r -a SHOPIFYnumber<<<"`cat /etc/skt.d/data/team/${SHOPIFY[0]}`"
curl -X POST "https://${SHOPIFYnumber[1]}:${SHOPIFYnumber[2]}@${SHOPIFYnumber[0]}/admin/api/2020-07/orders/${SHOPIFY[1]}/fulfillments.json" \
-# \
-H "Content-Type: application/json" \
-d '{
"fulfillment": {
"location_id": 9932406827,
"tracking_company": "'${TRACK[4]}'",
"tracking_number": "'${TRACK[3]}'",
"notify_customer": true
}
}'
fi
done < /root/track.txt
clear
sleep 1
printf "DONE: IMPORTED ORDER TO WOOCOMMERCE AND SHOPIFY\n"
sleep 2

#####                 PAYPAL
printf " ###############################\n"
printf "     FULFILLMENT | PAYPAL API   \n"
printf " ###############################\n"

#UPDATE ALL ACCESS TOKEN
while IFS= read -r VPS; do
curl POST "https://api.paypal.com/v1/oauth2/token" \
  -# \
  -H "Accept: application/json" \
  -H "Accept-Language: en_US" \
  -u "`sed -n '1p' /etc/skt.d/data/paypal/API/${VPS}_clientid_secret_key`" \
  -d "grant_type=client_credentials" \ | python -m json.tool | printf `jq -r ".access_token"` | cat > /etc/skt.d/data/paypal/token/${VPS}_access_token
done < /etc/skt.d/data/paypal/vps.txt

sleep 3

#FULFIL TRACKING
while IFS=$'\t' read -r -a TRANSACTION
do
curl -X POST "https://api.paypal.com/v1/shipping/trackers-batch" \
  -# \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer `sed -n "1p" /etc/skt.d/data/paypal/token/${TRANSACTION[0]}_access_token`" \
  -d '{
  "trackers": [
    {
      "transaction_id": "'${TRANSACTION[1]}'",
      "tracking_number": "'${TRANSACTION[3]}'",
      "status": "SHIPPED",
      "carrier": "OTHER",
      "carrier_name_other": "'${TRANSACTION[4]}'",
      "notify_buyer":"true"
    }
  ]
}' | python -m json.tool | printf "${TRANSACTION[2]} - Transaction : `jq -r ".tracker_identifiers[].transaction_id"` - DONE!!! \n"
done < /root/track.txt




#FORMAT track.txt file
#E4 8MC585209K746392H WC5-27672 9400109205568128990983 USPS
#E5 8MC585209K746392H WC5-27672 9400109205568743137961 USPS
clear
printf "UPDATE: IMPORTED ORDER TO PAYPAL\n"
sleep 1
printf "DONE!!!\n"

python3 /etc/skt.d/tool/python/ImportOrdersEbay.py

elif [ $QUESTION = N -o $QUESTION = n ]; then
printf "STATUS: CANCEL UPDATE\n"
sleep 1
sh /etc/skt.d/tool/web/rest_api.bash
else
	sh /etc/skt.d/tool/web/rest_api.bash
fi
elif [ $OPTION = 3 ]; then
clear
source /etc/skt.d/tool/web/export_order.bash
sh /etc/skt.d/tool/web/rest_api.bash
elif [ $OPTION = 4 ]; then
clear
while IFS='|' read -r -a DATA 
do
rm -rf /root/woocommerce*
if [ ${DATA[0]} = "W" ]; then
printf "Loading: ##"
curl -X GET "https://${DATA[2]}/wp-json/wc/v3/orders?status=on-hold&per_page=100" \
	-# \
    -u "${DATA[3]}:${DATA[4]}" | python -m json.tool | jq -r ".[].id" | cat >> /root/woocommerce.${DATA[0]}${DATA[1]}.orders.onhold.listID
countOrdersOnHold="`cat /root/woocommerce.${DATA[0]}${DATA[1]}.orders.onhold.listID | wc -l`"
for (( i=1; i <= ${countOrdersOnHold}; i++))
do
orderID="`sed -n "${i}p" /root/woocommerce.${DATA[0]}${DATA[1]}.orders.onhold.listID`"
curl -X DELETE "https://${DATA[2]}/wp-json/wc/v3/orders/${orderID}?force=true" \
	-# \
	-u "${DATA[3]}:${DATA[4]}" | python -m json.tool | printf "${i}. Deleted Order ${orderID}: `jq -r ".total"` USD\n"
done
fi
done < /etc/skt.d/data/team/api.txt
sh /etc/skt.d/tool/web/rest_api.bash

elif [ $OPTION = 5 ]; then
sh /etc/skt.d/tool/web/web.bash
else 
	printf "404!! Other\n"
fi
