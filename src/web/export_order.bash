#!/bin/bash
#AUTOMATE EXPORT ORDER
printf " #######################################\n"
printf " Export Orders | REST API | WOOCOMMERCER\n"
printf " #######################################\n"

#REFRESH ORDER FILE
rm -rf /root/orders.csv
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
	-H "Content-Type: application/json" \ | python -m json.tool | jq -r ".line_items[].sku" | cat >> /root/check_order_${WOOCOMMERCER[0]}_`sed -n "${i}p" /root/export_orders_${WOOCOMMERCER[0]}`
done
done < /etc/skt.d/data/woocommerce/all-invoice.txt



#GET ORDER DETAILS
while IFS=$'\t'	read -r -a WOOCOMMERCER
do
count="`cat /root/export_orders_${WOOCOMMERCER[0]} | wc -l`"
for (( i=0; i <= $count-1; i++ )); do
n=`expr $i + 1`
order_id="`sed -n "${n}p" /root/export_orders_${WOOCOMMERCER[0]}`"
check_order="`cat /root/check_order_${WOOCOMMERCER[0]}_${order_id} | wc -l`"
for (( j=0; j <= ${check_order}-1; j++)); do
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
rm -rf /root/check_order_*
rm -rf /root/export_orders_*
clear
#PRINT RESULTS