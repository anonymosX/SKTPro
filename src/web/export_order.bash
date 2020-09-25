#!/bin/bash
#AUTOMATE EXPORT ORDER
printf " #######################################\n"
printf " Export Orders | REST API | NINJA TEAM\n"
printf " #######################################\n"



# /etc/skt.d/data/team/api.txt 
#W 1 url1 consumer_key1 consumer_secret1
#W 2 url2 consumer_key2 consumer_secret2
#S 1 url1 api           pass




#REFRESH ORDER FILE
rm -rf /root/orders.csv
#######################################START CODE WOOCOMMERCE #######################################
#GET NUMBER OF ORDERS
while IFS="|" read -r -a DATA 
do
if [ ${DATA[0]} == "W" ]; then
curl -X GET "https://${DATA[2]}/wp-json/wc/v3/orders?status=processing&per_page=100" \
	-# \
    -u "${DATA[3]}:${DATA[4]}" | python -m json.tool | jq -r ".[].id" | cat >> /root/woocommerce.${DATA[0]}${DATA[1]}.orders.listID



#CHECK QUANTITY VARIANT

count="`cat /root/woocommerce.${DATA[0]}${DATA[1]}.orders.listID | wc -l`"
for (( i=1; i <= $count; i++ )); do
curl -X GET "https://${DATA[2]}/wp-json/wc/v3/orders/`sed -n "${i}p" /root/woocommerce.${DATA[0]}${DATA[1]}.orders.listID`" \
	-# \
    -u "${DATA[3]}:${DATA[4]}" | python -m json.tool | jq -r ".line_items[].sku" | cat >> /root/woocommerce.${DATA[0]}${DATA[1]}.order.id.`sed -n "${i}p" /root/woocommerce.${DATA[0]}${DATA[1]}.orders.listID`
done


#GET ORDER DETAILS

count="`cat /root/woocommerce.${DATA[0]}${DATA[1]}.orders.listID | wc -l`"
for (( i=0; i <= $count-1; i++ )); do
n=`expr $i + 1`
orderID="`sed -n "${n}p" /root/woocommerce.${DATA[0]}${DATA[1]}.orders.listID`"
qttProducts="`cat /root/woocommerce.${DATA[0]}${DATA[1]}.order.id.${orderID} | wc -l`"
#GET PAYPAL ACCOUNT LABEL
PAYPAL="`curl -X GET "https://${DATA[2]}/wp-json/wc/v3/payment_gateways/paypal" \
-u "${DATA[3]}:${DATA[4]}" | python -m json.tool | jq -r ".settings.invoice_prefix.value"`"

for (( j=0; j <= ${qttProducts}-1; j++)); do
curl -X GET "https://${DATA[2]}/wp-json/wc/v3/orders?status=processing&per_page=100" \
	-# \
    -u "${DATA[3]}:${DATA[4]}" | python -m json.tool | printf "${PAYPAL},${DATA[0]}${DATA[1]}, `jq -r "[.[$i].transaction_id,.[$i].id,.[$i].shipping.first_name,.[$i].shipping.last_name,.[$i].billing.phone,.[$i].shipping.address_1,.[$i].shipping.address_2,.[$i].shipping.city,.[$i].shipping.state,.[$i].shipping.postcode,.[$i].line_items[$j].sku,.[$i].line_items[$j].quantity] | @csv"`\n" | cat >> /root/results.csv	

done		
done
fi
#SHOPIFY EXPORT ORDERS
if [ ${DATA[0]} == "S" ]; then
#1. Get list unfulfilled orders id
curl -X GET "https://${DATA[3]}:${DATA[4]}@${DATA[2]}/admin/api/2020-07/orders.json?status=open&limit=250&fulfillment_status=unfulfilled" \
	-#  | python -m json.tool | jq -r ".orders[].id" | cat >> /root/shopify.${DATA[0]}${DATA[1]}.orders.unfufilled.listID

#2. Count unfulfilled
curl -X GET "https://${DATA[3]}:${DATA[4]}@${DATA[2]}/admin/api/2020-07/orders/count.json?fulfillment_status=unfulfilled" \
	-# | python -m json.tool | jq -r ".count" | cat > /root/shopify.${DATA[0]}${DATA[1]}.orders.count 
countOrders="`cat /root/shopify.${DATA[0]}${DATA[1]}.orders.count`"
#3. Get order details
for (( n=1; n <= $countOrders; n++ ));
do
orderID="`sed -n "${n}p" /root/shopify.${DATA[0]}${DATA[1]}.orders.unfufilled.listID`"

curl -X GET "https://${DATA[3]}:${DATA[4]}@${DATA[2]}/admin/api/2020-07/orders.json?ids=${orderID}" \
	-# | python -m json.tool | jq -r ".orders[].line_items[].product_id" | cat > /root/shopify.${DATA[0]}${DATA[1]}.orders.${orderID}.qttProducts
qttProducts="`cat /root/shopify.${DATA[0]}${DATA[1]}.orders.${orderID}.qttProducts | wc -l`"
for (( j=0; j <= ${qttProducts} - 1; j++))
do
curl -X GET "https://${DATA[3]}:${DATA[4]}@${DATA[2]}/admin/api/2020-07/orders.json?ids=${orderID}" \
	-# | python -m json.tool | printf "D90,${DATA[0]}${DATA[1]},`curl -X GET "https://${DATA[3]}:${DATA[4]}@${DATA[2]}/admin/api/2020-07/orders/${orderID}/transactions.json" \ -#  | python -m json.tool | jq -r ".transactions[].authorization"`, `jq -r "[.orders[].id,.orders[].shipping_address.first_name,.orders[].shipping_address.last_name,.orders[].shipping_address.phone,.orders[].shipping_address.address1,.orders[].shipping_address.address2,.orders[].shipping_address.city,.orders[].shipping_address.province_code,.orders[].shipping_address.zip,.orders[].line_items[$j].sku,.orders[].line_items[$j].quantity] | @csv"`\n" | cat >> /root/results.csv
done
done
fi
done < /etc/skt.d/data/team/api.txt
sed -i 's/"//g' /root/results.csv

#ARANGE DATA
while IFS="," read -r -a CONVERT
do
#REPLACE SPACE STRING
CONVERT[2]="`echo "${CONVERT[2]}" | sed "s/ //"`"
CONVERT[3]="`echo "${CONVERT[3]}" | sed "s/ //"`"
CONVERT[7]="`echo "${CONVERT[7]}" | sed "s/,/ /"`"
NAME="${CONVERT[4]} ${CONVERT[5]}"
INVOICE="${CONVERT[1]}-${CONVERT[3]}"
FULLADDRESS="${CONVERT[7]} ${CONVERT[8]}"
printf "${CONVERT[0]},${CONVERT[2]},${INVOICE},${NAME},${CONVERT[6]},${FULLADDRESS},${CONVERT[9]},${CONVERT[10]},${CONVERT[11]},${CONVERT[12]},${CONVERT[13]}\n" | cat >> /root/orders.csv
done <  /root/results.csv


















#REMOVE TRASH
rm -rf /root/woocommerce* /root/shopify* /root/results.csv
clear
