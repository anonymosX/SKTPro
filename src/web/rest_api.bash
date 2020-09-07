#!/bin/bash
printf " ###############################\n"
printf " REST API | WOOCOMMERCE | PAYPAL\n"
printf " ###############################\n"
printf "1. Declare REST API\n"
printf "2. Import Track (PP + Woo)\n"
printf "3. Export Order\n"
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
	
	
#WC5 url5 consumer_key5:consumer_secret5
#WC6 url6 consumer_key6:consumer_secret6
#	sh /etc/skt.d/tool/web/rest_api.bash
elif [ $OPTION = 2 ]; then
clear
printf "IMPORTANT: ORDER IS INCLUDED IMPORT TO WOOCOMMERCER AND PAYPAL ALSO\n" 
printf "DO YOU WANT TO IMPORT TRACKING NUMBER? - (Y/N): "
read QUESTION
if [ $QUESTION = Y -o $QUESTION = y ]; then
#READ FILE track.txt then find REST API
while IFS=$'\t'	read -r -a TRACK
do
	#spilit invoice name and invoice number, example WC1-21
	IFS="-" ; read -r -a INVOICE<<<"${TRACK[2]}" 
	curl -X POST https://`sed -n '1p' /etc/skt.d/data/woocommerce/API_${INVOICE[0]}`/wp-json/wc/v3/orders/${INVOICE[1]}/shipment-trackings \
		-u "`sed -n '2p' /etc/skt.d/data/woocommerce/API_${INVOICE[0]}`" \
		-H "Content-Type: application/json" \
		-d '{
	  "tracking_provider": "'${TRACK[4]}'",
	  "tracking_number": "'${TRACK[3]}'"
	  
	}' \ | python -m json.tool
	curl -X PUT https://`sed -n '1p' /etc/skt.d/data/woocommerce/API_${INVOICE[0]}`/wp-json/wc/v3/orders/${INVOICE[1]} \
    -u "`sed -n '2p' /etc/skt.d/data/woocommerce/API_${INVOICE[0]}`" \
    -H "Content-Type: application/json" \
    -d '{
  "status": "completed"
}' \ | python -m json.tool
done < /root/track.txt
#FORMAT track.txt file
#E4 8MC585209K746392H WC5-27672 9400109205568128990983 USPS
#E5 8MC585209K746392H WC5-27672 9400109205568743137961 USPS

clear
sleep 3
printf "UPDATE: IMPORTED ORDER TO WOOCOMMERCE\n"
sleep 5


#FULFILLMENT ORDERS TO PAYPAL
printf " ###############################\n"
printf "     FULFILLMENT | PAYPAL API   \n"
printf " ###############################\n"

#UPDATE ALL ACCESS TOKEN
while IFS= read -r line; do
curl -v POST https://api.paypal.com/v1/oauth2/token \
  -H "Accept: application/json" \
  -H "Accept-Language: en_US" \
  -u "`sed -n "1p" /etc/skt.d/data/paypal/API/${line}_clientid_secret_key`" \
  -d "grant_type=client_credentials" \ | python -m json.tool | printf `jq  -r ".access_token"` | cat > /etc/skt.d/data/paypal/token/${line}_access_token
done < /etc/skt.d/data/paypal/vps.txt

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
sleep 2
printf "DONE!!!\n"
sleep 1
elif [ $QUESTION = N -o $QUESTION = n ]; then
printf "STATUS: CANCEL UPDATE\n"
else
	sh /etc/skt.d/tool/web/rest_api.bash
fi
elif [ $OPTION = 3 ]; then
clear
# REFRESH ORDER FILE
rm -rf /root/orders.csv
printf " #######################################\n"
printf " Export Orders | REST API | WOOCOMMERCE\n"
printf " #######################################\n"

#GET NUMBER OF ORDERS
while IFS=$'\t'	read -r -a WOOCOMMERCER
do
curl -X GET https://${WOOCOMMERCER[1]}/wp-json/wc/v3/orders \
    -u "${WOOCOMMERCER[2]}" \
	-H "Content-Type: application/json" \
	-d '{
	"status": "processing"	
	}' \ | python -m json.tool | jq -r ".[].id" | cat > /root/export_orders_${WOOCOMMERCER[0]}
done < /etc/skt.d/data/woocommerce/all-invoice.txt

#CHECK QUANTITY VARIANT
while IFS=$'\t'	read -r -a WOOCOMMERCER
do
count="`cat /root/export_orders_${WOOCOMMERCER[0]} | wc -l`"
for (( i=1; i <= $count; i++ )); do
curl -X GET https://${WOOCOMMERCER[1]}/wp-json/wc/v3/orders/`sed -n "${i}p" /root/export_orders_${WOOCOMMERCER[0]}` \
    -u "${WOOCOMMERCER[2]}" \
	-H "Content-Type: application/json" \ | python -m json.tool | jq -r ".line_items[].sku" | cat >> /root/total_order_${WOOCOMMERCER[0]}_`sed -n "${i}p" /root/export_orders_${WOOCOMMERCER[0]}`
done
done < /etc/skt.d/data/woocommerce/all-invoice.txt



#GET ORDER DETAILS
while IFS=$'\t'	read -r -a WOOCOMMERCER
do
count="`cat /root/export_orders_${WOOCOMMERCER[0]} | wc -l`"
for (( i=0; i <= $count-1; i++ )); do
n=`expr $i + 1`
order_id="`sed -n "${n}p" /root/export_orders_${WOOCOMMERCER[0]}`"
total_order="`cat /root/total_order_${WOOCOMMERCER[0]}_${order_id} | wc -l`"
for (( j=0; j <= ${total_order}-1; j++)); do
curl -X GET https://${WOOCOMMERCER[1]}/wp-json/wc/v3/orders \
    -u "${WOOCOMMERCER[2]}" \
	-H "Content-Type: application/json" \
	-d '{
	"status": "processing"	
	}' \ | python -m json.tool | printf "\n${WOOCOMMERCER[0]}, `jq -r "[.[$i].transaction_id,.[$i].id,.[$i].shipping.first_name,.[$i].shipping.last_name,.[$i].billing.phone,.[$i].shipping.address_1,.[$i].shipping.address_2,.[$i].shipping.city,.[$i].shipping.state,.[$i].shipping.postcode,.[$i].line_items[$j].sku,.[$i].line_items[$j].quantity] | @csv"`" | cat >> /root/orders.csv	

done		
done
done < /etc/skt.d/data/woocommerce/all-invoice.txt




# /etc/skt.d/data/woocommerce/all-invoice.txt 
#WC5 url5 consumer_key5:consumer_secret5
#WC6 url6 consumer_key6:consumer_secret6

#REMOVE TRASH
rm -rf /root/total_order_*
rm -rf /root/export_orders/*
clear
#PRINT RESULTS

else 
	printf "404!! Other\n"
fi
