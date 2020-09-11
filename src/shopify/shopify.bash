#!/bin/bash
printf " ###############################\n"
printf " REST API | SHOPIFY n"
printf " ###############################\n"
printf "1. Declare REST API\n"
printf "2. Import Order"
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

elif [ $OPTION = 3 ]; then
clear
printf "Export Order is starting soon\n"
sleep 2


 

#GET LIST ORDER ID - UNFULFILLED
while IFS=$'\t' read -r -a API
do
curl -X GET "https://${API[1]}/admin/api/2020-07/orders.json?status=open&limit=250&fulfillment_status=unfulfilled" | python -m json.tool | jq -r ".orders[].id" | cat >> /root/shopify.${API[0]}.orders.unfufilled.id



#COUNT UNFULFILLED ORDERS
curl -X GET "https://${API[1]}/admin/api/2020-07/orders/count.json?fulfillment_status=unfulfilled"| python -m json.tool | jq -r ".count" | cat > /root/shopify.${API[0]}.orders.count

count="`cat /root/shopify.${API[0]}.orders.count`"
for (( n=0; n <= $count -1; n++ ));
do
ORDERID="`sed -n "${n}p" /root/shopify.${API[0]}.orders.unfufilled.id`"

curl -X GET "https://${API[1]}/admin/api/2020-07/orders.json?ids=${ORDERID}" | python -m json.tool | jq -r ".orders[].line_items[].product_id" | cat > /root/shopify.${API[0]}.orders.${ORDERID}.checkquantity
count2="`cat /root/shopify.${API[0]}.orders.${ORDERID}.checkquantity | wc -l`"
for (( j=0; j <= ${count2} - 1; j++))
do

curl -X GET "https://${API[1]}/admin/api/2020-07/orders.json?ids=${ORDERID}" | python -m json.tool | printf "${API[0]},`curl -X GET "https://${API[1]}/admin/api/2020-07/orders/$ORDERID/transactions.json" | python -m json.tool | jq -r ".transactions[].authorization"`, `jq -r "[.orders[].id,.orders[].shipping_address.first_name,.orders[].shipping_address.last_name,.orders[].shipping_address.phone,.orders[].shipping_address.address1,.orders[].shipping_address.address2,.orders[].shipping_address.city,.orders[].shipping_address.province_code,.orders[].shipping_address.zip,.orders[].line_items[$j].sku,.orders[].line_items[$j].quantity] | @csv"`"
done
done
done < /etc/skt.d/data/shopify/api.txt



#GET ORDER DETAIL:


while IFS=$'\t' read -r -a API
do
count="`cat /root/shopify.${API[0]}.orders.count`"
for (( n=1; n <= $count; n++ ));
do
ORDERID="`sed -n "${n}p" /root/shopify.${API[0]}.orders.unfufilled.id`"

curl -X GET "https://${API[1]}/admin/api/2020-07/orders.json?ids=${ORDERID}" | python -m json.tool | printf "${API[0]},`curl -X GET "https://${API[1]}/admin/api/2020-07/orders/$ORDERID/transactions.json" | python -m json.tool | jq -r ".transactions[].authorization"`, `jq -r "[.orders[].id,.orders[].shipping_address.first_name,.orders[].shipping_address.last_name,.orders[].shipping_address.phone,.orders[].shipping_address.address1,.orders[].shipping_address.address2,.orders[].shipping_address.city,.orders[].shipping_address.province_code,.orders[].shipping_address.zip,.orders[].line_items[$j].sku,.orders[].line_items[$j].quantity] | @csv"`"
done
done < /etc/skt.d/data/shopify/api.txt



#GET PAYPAL TRANSACTION ID
curl -X GET "https://${API[1]}/admin/api/2020-07/orders/${ORDERID}/transactions.json" | python -m json.tool | jq -r ".transactions[].authorization"




curl -X GET "https://a307da28a4668162260ed86e32de53e3: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@onlinecentershops.myshopify.com/admin/api/2020-07/orders.json?ids=2466563981378" | python -m json.tool | printf "${API[0]},`jq -r "[.orders[].id,.orders[].shipping_address.first_name,.orders[].shipping_address.last_name,.orders[].shipping_address.phone,.orders[].shipping_address.address1,.orders[].shipping_address.address2,.orders[].shipping_address.city,.orders[].shipping_address.province_code,.orders[].shipping_address.zip,.orders[].line_items[].sku,.orders[].line_items[].quantity] | @csv"`"




curl -X GET "https://a307da28a4668162260ed86e32de53e3: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@onlinecentershops.myshopify.com/admin/api/2020-07/orders.json?ids=2467738419266" | python -m json.tool | printf "${API[0]},`jq -r "[.order[].id,.orders[].shipping_address.first_name] | @csv"`"






while IFS= read -r 
ORDERID="`sed -n "`"
curl -X GET "https://a307da28a4668162260ed86e32de53e3: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@onlinecentershops.myshopify.com/admin/api/2020-07/orders.json?ids=2460109307970" | python -m json.tool | jq -r ".orders[].line_items[].product_id" | cat >> /root/shopify.${API[0]}.orders.${ORDERID}.checkquantity

done < /root/shopify.${API[0]}.orders.unfufilled.id
done < /etc/skt.d/data/shopify/api.txt








INVOICE=S1
while IFS= read -r ORDERID;
do
curl -X GET "https://`sed -n '1p' /etc/skt.d/data/shopify/${INVOICE}.txt`/admin/api/2020-07/orders/count.json?fulfillment_status=unfulfilled" | python -m json.tool
done < 1.txt


curl -X GET "https://a307da28a4668162260ed86e32de53e3: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@onlinecentershops.myshopify.com/admin/api/2020-07/orders.json?ids=2467738419266" | python -m json.tool | jq -r "[.transactions[].authorization,.order[].id,.orders[].shipping_address.first_name,.orders[].shipping_address.last_name,.orders[].shipping_address.phone,.orders[].shipping_address.address1,.orders[].shipping_address.address2,.orders[].shipping_address.city,.orders[].shipping_address.province_code,.orders[].shipping_address.zip,.orders[].line_items[].sku,.orders[].line_items[].quantity] | @csv"


curl -X GET "https://a307da28a4668162260ed86e32de53e3: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@onlinecentershops.myshopify.com/admin/api/2020-07/orders.json?ids=2467738419266" | python -m json.tool | jq -r "[.transactions[].authorization,.orders[].id] | @csv"


















API key: a307da28a4668162260ed86e32de53e3
Pass: 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

Private applications authenticate with Shopify through basic HTTP authentication, using the URL format https://{apikey}:{password}@{hostname}/admin/api/2020-07/orders.json?status=open

Shared Secret: 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

curl -X GET https://a307da28a4668162260ed86e32de53e3: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@onlinecentershops.myshopify.com/admin/api/2020-07/orders.json?status=open \ | python -m json.tool | jq -r ".transactions[0].id"



curl -X GET https://a307da28a4668162260ed86e32de53e3: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@onlinecentershops.myshopify.com/admin/api/2020-07/orders.json?since_id=1049 \ | python -m json.tool | jq -r ".order[].transactions[0].id"




curl -X GET https://a307da28a4668162260ed86e32de53e3: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@onlinecentershops.myshopify.com/admin/api/2020-07/orders/2467738419266/transactions.json | python -m json.tool | jq -r ".transactions[].transaction_id"









