#!/bin/bash
#AUTOMATE EXPORT ORDER
printf " #######################################\n"
printf " Export Orders | REST API | WOOCOMMERCER\n"
printf " #######################################\n"

#REFRESH ORDER FILE
rm -rf /root/orders.csv
#GET NUMBER OF ORDERS
while IFS=$'\t' read -r -a WOOCOMMERCE 
do
curl -X GET "https://${WOOCOMMERCE[1]}/wp-json/wc/v3/orders?status=processing&per_page=100" \
    -u "${WOOCOMMERCE[2]}" | python -m json.tool
done < /etc/skt.d/data/woocommerce/all-invoice.txt

#CHECK QUANTITY VARIANT
while IFS=$'\t'	read -r -a WOOCOMMERCE
do
count="`cat /root/export_orders_${WOOCOMMERCE[0]} | wc -l`"
for (( i=1; i <= $count; i++ )); do
curl -X GET "https://${WOOCOMMERCE[1]}/wp-json/wc/v3/orders/`sed -n "${i}p" /root/export_orders_${WOOCOMMERCE[0]}`" \
    -u "${WOOCOMMERCE[2]}" | python -m json.tool | jq -r ".line_items[].sku" | cat >> /root/total_order_${WOOCOMMERCE[0]}_`sed -n "${i}p" /root/export_orders_${WOOCOMMERCE[0]}`
done
done < /etc/skt.d/data/woocommerce/all-invoice.txt


printf "INVOICE NAME,TRANSACTION ID,ORDER ID,FIRST NAME,LAST NAME,PHONE NUMBER,ADDRESS 1,ADDRESS 2,CITY,STATES,ZIPCODE, SKU,QUANTITY"  | cat >> /root/orders.csv	
#GET ORDER DETAILS
while IFS=$'\t'	read -r -a WOOCOMMERCE
do
count="`cat /root/export_orders_${WOOCOMMERCE[0]} | wc -l`"
for (( i=0; i <= $count-1; i++ )); do
n=`expr $i + 1`
order_id="`sed -n "${n}p" /root/export_orders_${WOOCOMMERCE[0]}`"
total_order="`cat /root/total_order_${WOOCOMMERCE[0]}_${order_id} | wc -l`"
for (( j=0; j <= ${total_order}-1; j++)); do
curl -X GET "https://${WOOCOMMERCE[1]}/wp-json/wc/v3/orders?status=processing&per_page=100" \
    -u "${WOOCOMMERCE[2]}" | python -m json.tool | printf "\n${WOOCOMMERCE[0]}, `jq -r "[.[$i].transaction_id,.[$i].id,.[$i].shipping.first_name,.[$i].shipping.last_name,.[$i].billing.phone,.[$i].shipping.address_1,.[$i].shipping.address_2,.[$i].shipping.city,.[$i].shipping.state,.[$i].shipping.postcode,.[$i].line_items[$j].sku,.[$i].line_items[$j].quantity] | @csv"`" | cat >> /root/orders.csv	

done		
done
done < /etc/skt.d/data/woocommerce/all-invoice.txt
sed -i 's/"//g' /root/orders.csv



# /etc/skt.d/data/woocommerce/all-invoice.txt 
#WC5 url5 consumer_key5:consumer_secret5
#WC6 url6 consumer_key6:consumer_secret6

#REMOVE TRASH
rm -rf /root/total_order_* /root/export_orders_*
clear
