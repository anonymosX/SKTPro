#!/bin/bash
printf " ###############################\n"
printf " REST API | WOOCOMMERCE\n"
printf " ###############################\n"
printf "1. Declare REST API\n"
printf "2. Import Tracking\n"
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


elif [ $OPTION = 3 ]; then
clear
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



while IFS=$'\t'	read -r -a WOOCOMMERCER
do
export_order_count="`cat /root/export_orders_${WOOCOMMERCER[0]} | wc -l`"
for i in 0 1 2 3
do
curl -X GET https://${WOOCOMMERCER[1]}/wp-json/wc/v3/orders \
    -u "${WOOCOMMERCER[2]}" \
	-H "Content-Type: application/json" \
	-d '{
	"status": "processing"	
	}' \ | python -m json.tool | printf ${WOOCOMMERCER[0]},`jq -r "[.[$i].transaction_id,.[$i].id,.[$i].shipping.first_name,.[$i].shipping.last_name,.[$i].billing.phone,.[$i].shipping.address_1,.[$i].shipping.address_2,.[$i].shipping.city,.[$i].shipping.state,.[$i].shipping.postcode,.[$i].line_items[].sku] | @csv"`"\n" | cat >> /root/${WOOCOMMERCER[0]}_orders.csv
done
done < /etc/skt.d/data/woocommerce/all-invoice.txt




# /etc/skt.d/data/woocommerce/all-invoice.txt 
#WC5 url5 consumer_key5:consumer_secret5
#WC6 url6 consumer_key6:consumer_secret6




else 
	printf "404!! Other\n"
fi
