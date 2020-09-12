#!/bin/bash
printf " ###############################\n"
printf " REST API | SHOPIFY n"
printf " ###############################\n"
printf "1. Declare REST API\n"
printf "2. Import Order(SHOPIFY ONLY)\n"
printf "3. Export Order\n"
printf "4. Previous/Back\n"
printf "OPTION: "
read OPTION
if [ $OPTION = 0 ]; then
	sh /root/install
elif [ $OPTION = 1 ]; then
clear
printf "Nhap API key: "
read APIKEY
printf "Nhap Pass: "
read PASSWORD
printf "Nhap Shared Secret: "
read SHAREDSECRET
printf "Nhap Hostname: "
read HOST
printf "Nhap INVOICE: "
read INVOICE
printf "${INVOICE}	${APIKEY}:${PASSWORD}@${HOST}" | cat > /etc/skt.d/data/shopify/api.txt
elif [ $OPTION = 2 ]; then

while IFS=$'\t' read -r -a TRACK
do

IFS="-" ; read -r -a INVOICE<<<"${TRACK[2]}" 
if [ ${INVOICE[0]} = "S1" ]; then


curl -X POST "https://`sed -n "1p" /etc/skt.d/data/shopify/${INVOICE[0]}.txt`/admin/api/2020-07/orders/${INVOICE[1]}/fulfillments.json" \
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



elif [ $OPTION = 3 ]; then
clear
printf "Export Order is starting soon\n"
sleep 2


 

#GET LIST ORDER ID - UNFULFILLED
rm -rf /root/orders.csv
while IFS=$'\t' read -r -a API
do
curl -X GET "https://${API[1]}/admin/api/2020-07/orders.json?status=open&limit=250&fulfillment_status=unfulfilled" | python -m json.tool | jq -r ".orders[].id" | cat >> /root/shopify.${API[0]}.orders.unfufilled.id

#COUNT UNFULFILLED ORDERS
curl -X GET "https://${API[1]}/admin/api/2020-07/orders/count.json?fulfillment_status=unfulfilled" | python -m json.tool | jq -r ".count" | cat > /root/shopify.${API[0]}.orders.count

count="`cat /root/shopify.${API[0]}.orders.count`"
for (( n=1; n <= $count; n++ ));
do
ORDERID="`sed -n "${n}p" /root/shopify.${API[0]}.orders.unfufilled.id`"

curl -X GET "https://${API[1]}/admin/api/2020-07/orders.json?ids=${ORDERID}" | python -m json.tool | jq -r ".orders[].line_items[].product_id" | cat > /root/shopify.${API[0]}.orders.${ORDERID}.checkquantity
count2="`cat /root/shopify.${API[0]}.orders.${ORDERID}.checkquantity | wc -l`"
for (( j=0; j <= ${count2} - 1; j++))
do
curl -X GET "https://${API[1]}/admin/api/2020-07/orders.json?ids=${ORDERID}" | python -m json.tool | printf "${API[0]},`curl -X GET "https://${API[1]}/admin/api/2020-07/orders/${ORDERID}/transactions.json" | python -m json.tool | jq -r ".transactions[].authorization"`, `jq -r "[.orders[].id,.orders[].shipping_address.first_name,.orders[].shipping_address.last_name,.orders[].shipping_address.phone,.orders[].shipping_address.address1,.orders[].shipping_address.address2,.orders[].shipping_address.city,.orders[].shipping_address.province_code,.orders[].shipping_address.zip,.orders[].line_items[$j].sku,.orders[].line_items[$j].quantity] | @csv"`\n" | cat >> orders.csv
sed -i 's/"//g' /root/orders.csv
done
done
done < /etc/skt.d/data/shopify/api.txt


elif [ $OPTION = 4 ]; then
sh /etc/skt.d/tool/web/web.bash
else 
printf "404: Other\n"
sh /etc/skt.d/tool/shopify/shopify.bash
fi









