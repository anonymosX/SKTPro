#printf "1\n${e}\nA\n1\n" | certbot --nginx -d ${d} -d www.${d}
printf "${e}\nA\n1\n" | certbot --nginx -d ${d} -d www.${d}
mkdir -p /etc/letsencrypt/live/${d}
openssl dhparam 2048 -out /etc/letsencrypt/live/${d}/dhparam.pem
mv /etc/nginx/conf.d/${d}.conf /etc/nginx/conf.d/${d}.conf.80
mv /etc/nginx/conf.d/${d}.conf.443 /etc/nginx/conf.d/${d}.conf


