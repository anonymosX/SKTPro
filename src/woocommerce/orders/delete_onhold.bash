#!/bin/bash
#/etc/skt.d/data/woocommerce/all-invoice.txt
#WC5 url5 consumer_key5:consumer_secret5
#WC6 url6 consumer_key6:consumer_secret6




#LIST ON HOLD ORDERS
while IFS=$'\t' read -r -a WOOCOMMERCE; do
curl -X GET https://${WOOCOMMERCE[1]}/wp-json/wc/v3/orders \
-u ${WOOCOMMERCE[2]} \
-H "Content-Type: application/json" \
-d '{ 
	"status": "on-hold"	
	}' \ | python -m json.tool | jq -r ".[].id" | cat >> /root/order_onhold-${WOOCOMMERCE[0]}.txt
done < /etc/skt.d/data/woocommerce/all-invoice.txt



#DELETE ON HOLD ORDERS
while IFS=$'\t' read -r -a WOOCOMMERCE; do
count="`cat /root/order_onhold-${WOOCOMMERCE[0]}.txt | wc -l`"
for (( n = 1; n <= $count ; n ++)); do
curl -X DELETE https://${WOOCOMMERCE[1]}/wp-json/wc/v3/orders/`sed -n "${n}p" /root/order_onhold-${WOOCOMMERCE[0]}.txt` \
-u ${WOOCOMMERCE[2]}
done
done < /etc/skt.d/data/woocommerce/all-invoice.txt



