printf "1\n${EMAIL}\nA\n1\n" | certbot --nginx -d $DOMAIN -d www.$DOMAIN
#printf "${EMAIL}\nA\n1\n" | certbot --nginx -d $DOMAIN -d www.$DOMAIN
mkdir -p /etc/letsencrypt/live/$DOMAIN
openssl dhparam 2048 -out /etc/letsencrypt/live/$DOMAIN/dhparam.pem
mv /etc/nginx/conf.d/$DOMAIN.conf /etc/nginx/conf.d/$DOMAIN.conf.80
mv /etc/nginx/conf.d/$DOMAIN.conf.443 /etc/nginx/conf.d/$DOMAIN.conf


