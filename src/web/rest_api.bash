#!/bin/bash
#FORMAT track.txt file
#E4 8MC585209K746392H W-5-27672 9400109205568128990983 USPS
#E5 8MC585209K746392H W-5-27672 9400109205568743137961 USPS
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
	printf " Declare | REST API | WOOCOMMERCE\n"
	printf " ###############################\n"
	printf "1. Invoice name: "
	read INVOICE
	printf "2. URL: "
	read URL
	printf "3. Consumer key: "
	read CONSUMER_KEY
	printf "4. Consumer secret: "
	read CONSUMER_SECRET
	printf "${URL}\n${CONSUMER_KEY}:${CONSUMER_SECRET}" | cat > /etc/skt.d/data/woocommerce/API_${INVOICE}
	printf "\n${INVOICE}	${URL}	${CONSUMER_KEY}:${CONSUMER_SECRET}" | cat >> /etc/skt.d/data/woocommerce/all-invoice.txt
	
#/etc/skt.d/data/woocommerce/all-invoice.txt
#WC5 url5 consumer_key5:consumer_secret5
#WC6 url6 consumer_key6:consumer_secret6
#	sh /etc/skt.d/tool/web/rest_api.bash
elif [ $OPTION = 2 ]; then
clear
printf "IMPORTANT: ORDER IS INCLUDED IMPORT TO WOOCOMMERCE, SHOPIFY AND PAYPAL ALSO\n" 
printf "DO YOU WANT TO IMPORT TRACKING NUMBER? - (Y/N): "
read QUESTION
if [ $QUESTION = Y -o $QUESTION = y ]; then
#READ FILE track.txt then find REST API
#####                 WOOCOMMERCE

while IFS=$'\t'	read -r -a TRACK
do
IFS="-"; read -r -a PLATFORM<<<"${TRACK[2]}"
#IMPORT TRACK TO WOOCOMMERCE
if [ ${PLATFORM[0]} == "W" ]; then
#spilit invoice name and invoice number, example WC1-21
IFS="-" ; read -r -a INVOICE<<<"${TRACK[2]}" 
curl -X POST https://`sed -n '1p' /etc/skt.d/data/team/W-${INVOICE[1]}`/wp-json/wc/v3/orders/${INVOICE[2]}/shipment-trackings \
	-u "`sed -n '2p' /etc/skt.d/data/woocommerce/W-${INVOICE[1]}`" \
	-H "Content-Type: application/json" \
	-d '{
	"tracking_provider": "'${TRACK[4]}'",
	"tracking_number": "'${TRACK[3]}'"  
	}' \ | python -m json.tool
curl -X PUT https://`sed -n '1p' /etc/skt.d/data/team/W-${INVOICE[1]}`/wp-json/wc/v3/orders/${INVOICE[2]} \
    -u "`sed -n '2p' /etc/skt.d/data/woocommerce/W-${INVOICE[1]}`" \
    -H "Content-Type: application/json" \
    -d '{
  "status": "completed" 
  }' \ | python -m json.tool
fi
#IMPORT TRACK TO SHOPIFY
if [ ${PLATFORM[0]} == "S" ]; then
IFS="-" ; read -r -a INVOICE<<<"${TRACK[2]}" 
curl -X POST "https://`sed -n "1p" /etc/skt.d/data/team/S-${INVOICE[1]}`/admin/api/2020-07/orders/${INVOICE[2]}/fulfillments.json" \
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
curl -v POST "https://api.paypal.com/v1/oauth2/token" \
  -H "Accept: application/json" \
  -H "Accept-Language: en_US" \
  -u "`sed -n '1p' /etc/skt.d/data/paypal/API/${VPS}_clientid_secret_key`" \
  -d "grant_type=client_credentials" \ | python -m json.tool | printf `jq -r ".access_token"` | cat > /etc/skt.d/data/paypal/token/${VPS}_access_token
done < /etc/skt.d/data/paypal/vps.txt

sleep 3

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
      "tracking_number": "'${TRANSACTION[3]}'",
      "status": "SHIPPED",
      "carrier": "OTHER",
      "carrier_name_other": "'${TRANSACTION[4]}'",
      "notify_buyer":"true"
    }
  ]
}' \ | python -m json.tool | printf "Đã ép thành công transaction id: `jq -r ".tracker_identifiers[].transaction_id"`: ${TRANSACTION[2]}\n"
done < /root/track.txt




#FORMAT track.txt file
#E4 8MC585209K746392H WC5-27672 9400109205568128990983 USPS
#E5 8MC585209K746392H WC5-27672 9400109205568743137961 USPS
clear
printf "UPDATE: IMPORTED ORDER TO PAYPAL\n"
sleep 1
printf "DONE!!!\n"

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
while IFS=$'\t' read -r -a DATA 
do
if [ ${DATA[0]} == "W" ]; then
curl -X GET "https://${DATA[2]}/wp-json/wc/v3/orders?status=on-hold&per_page=100" \
    -u "${DATA[3]}:${DATA[4]}" | python -m json.tool | jq -r ".[].id" | cat >> /root/woocommerce.${DATA[0]}${DATA[1]}.orders.onhold.listID
countOrdersOnHold="`cat /root/woocommerce.${DATA[0]}${DATA[1]}.orders.onhold.listID | wc -l`"
for (( i = 1; i <= ${countOrdersOnhold} ; i ++ ))
do
curl -X DELETE "https://${DATA[2]}/wp-json/wc/v3/orders/`sed -n "${i}p" /root/woocommerce.${DATA[0]}${DATA[1]}.orders.onhold.listID`?force=true" \
	-u "${DATA[3]}:${DATA[4]}" | python -m json.tool | printf "`jq -r ".status"`\n"
done
fi
done < /etc/skt.d/data/team/api.txt


elif [ $OPTION = 5 ]; then
sh /etc/skt.d/tool/web/web.bash
else 
	printf "404!! Other\n"
fi
