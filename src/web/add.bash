#!/bin/bash
#FLOW: REGISTER DOMAIN -> CLOUDFLARE(PAUSE) -> "CAI WOOCOMMERCE" -> CLOUDFLARE(ENABLE)
url=https://raw.githubusercontent.com/anonymosX/SKTPro/master
printf "ENTER INFORMATIONS\n"
printf "1. URL: "
read DOMAIN
printf "2. ADDRESS: "
read ADDRESS
printf "3. PHONE: "
read PHONE
printf "4. THEMES:(1 OR 2)\n  1/KONTE\n  2/SHOPTIMIZED\n"
printf "ENTER: "
read OPTION
if [ $OPTION = 0 ]; then
	clear
	printf "YOU HAVE CANCEL REQUEST\n"
	sh /etc/skt.d/tool/web/web.bash
else
# THONG TIN MYSQL
DB_NAME="`openssl rand -base64 32 | tr -d /=+ | cut -c -25`"
DB_USER="`openssl rand -base64 32 | tr -d /=+ | cut -c -25`"
DB_PASS="`openssl rand -base64 32 | tr -d /=+ | cut -c -25`"
WP_PASS="`openssl rand -base64 32 | tr -d /=+ | cut -c -25`"
WP_USER="qqteam`openssl rand -base64 32 | tr -d /=+ | cut -c -10`"

#TRUONG HOP DANG KI DOMAIN TU TAO FOLDER THI KO CAN TAO THEM FOLDER, TRANH BI LOI
if [ ! -d /etc/skt.d/data/$DOMAIN ]; then
	mkdir -p /etc/skt.d/data/$DOMAIN
fi
cd /root
EMAIL="`shuf -n 1 /etc/skt.d/tool/data/mail.bash`@${DOMAIN}"
source /root/.my.cnf
printf "#${DOMAIN^^}:\ndbn=${DB_NAME}\ndbu=${DB_USER}\ndbp=${DB_PASS}\nmdbp=$password\n" | cat > /etc/skt.d/data/$DOMAIN/sql.txt
printf "#${DOMAIN^^}:\nwp_usr=${WP_USER}\nwp_pass=${WP_PASS}\nEMAIL=$EMAIL" | cat > /etc/skt.d/data/$DOMAIN/login.txt

# TAI WORDPRESS OPEN SOURCE
mkdir -p /home/$DOMAIN/public_html && cd /home/$DOMAIN/public_html
wget https://wordpress.org/latest.tar.gz && tar -xzf latest.tar.gz
mv wordpress/* ./ && rm -rf wordpress latest.tar.gz
chmod 777 /home/$DOMAIN/public_html ; chown -R nginx:nginx /home/$DOMAIN/public_html

# CREATE DATABASE
source /etc/skt.d/data/$DOMAIN/sql.txt
printf "create database ${DB_NAME}" | mysql
printf "create user '${DB_USER}'@'localhost' identified by '${DB_PASS}'" | mysql
printf "grant all on ${DB_NAME}.* to ${DB_USER}@localhost" | mysql
printf "flush privileges" | mysql
printf "exit" | mysql

cat > /etc/nginx/conf.d/$DOMAIN.conf<<"EOF"
server {
            server_name www.domain.com;
            return       301 http://domain.com$request_uri;
        }
server {
        listen   80;
        server_name domain.com;
        root /home/domain.com/public_html;
        index index.php index.html index.htm;
        location /{
        try_files $uri $uri/ /index.php?q=$uri&$args;
      }
        access_log off;
        # access_log   /home/domain.com/logs/access_log;
        error_log off;
        # error_log /home/domain.com/logs/error.log;
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        include /etc/nginx/conf/php.conf;
        include /etc/nginx/conf/staticfiles.conf;
        include /etc/nginx/conf/block.conf;
        include /etc/nginx/conf/gzip.conf;
        include /etc/nginx/conf/upload.conf;
        # Access to .well-known verify SSL
        location ^~ /.well-known/ {
        allow all;
                    }
        # Error Page
        #error_page 403 /errorpage_html/403.html;
        #error_page 404 /errorpage_html/404.html;
        #error_page 405 /errorpage_html/405.html;
        #error_page 502 /errorpage_html/502.html;
        #error_page 503 /errorpage_html/503.html;
        #error_page 504 /errorpage_html/504.html;
        #location ^~ /errorpage_html/ {
        #   internal;
        #    root /home/domain.com;
        #    access_log              off;
        #}
    }
EOF
cat > /etc/nginx/conf.d/$DOMAIN.conf.443<<"EOF"
server {
    listen 80;
    server_name domain.com www.domain.com;
    return       301 https://domain.com$request_uri;
}
server {
    listen       443 ssl http2;
    server_name  www.domain.com;
    return       301 https://domain.com$request_uri;
    ssl_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/domain.com/privkey.pem;
}
server {
    listen 443 ssl http2;
    # Enable HSTS (cache 1 year)
    add_header Strict-Transport-Security "max-age=31536000" always;
    ssl_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/domain.com/privkey.pem;
    ssl_dhparam /etc/letsencrypt/live/domain.com/dhparam.pem;
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_prefer_server_ciphers on;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/domain.com/fullchain.pem;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 30s;
    ssl_buffer_size 1400;
    ssl_session_tickets on;
    add_header Strict-Transport-Security max-age=31536000;
    access_log off;
    #access_log   /home/domain.com/logs/access_log;
    error_log off;
    #error_log /home/domain.com/logs/error.log;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    root /home/domain.com/public_html;
    index index.php index.html index.htm;
    server_name domain.com;
    include /etc/nginx/conf/php.conf;
    include /etc/nginx/conf/staticfiles.conf;
    include /etc/nginx/conf/pagespeed.conf;
    include /etc/nginx/conf/block.conf;
    include /etc/nginx/conf/gzip.conf;
    include /etc/nginx/conf/upload.conf;
    # Config for Free SSL (LetEncrypt) - Do not Delete !
    #location ~ /.well-known {
    #        allow all;
    #        root /home/domain.com/public_html;
    #    }
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    # Error Page
    #error_page 403 /errorpage_html/403.html;
    #error_page 404 /errorpage_html/404.html;
    #error_page 405 /errorpage_html/405.html;
    #error_page 502 /errorpage_html/502.html;
    #error_page 503 /errorpage_html/503.html;
    #error_page 504 /errorpage_html/504.html;
    #location ^~ /errorpage_html/ {
    #   internal;
    #    root /home/domain.com;
    #    access_log              off;
    #}
}
EOF
sed -i "s/domain.com/$DOMAIN/g" /etc/nginx/conf.d/$DOMAIN.conf
sed -i "s/domain.com/$DOMAIN/g" /etc/nginx/conf.d/$DOMAIN.conf.443

#    Install Let's Enscrypt
source /etc/skt.d/tool/ssl/install.bash
#    Install WordPress
#    Generate wp-config.php

wp config create --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASS}  --extra-php --path=/home/$DOMAIN/public_html<<PHP
define('WP_DEBUG', false);
define('FS_METHOD','direct');
PHP

printf "${DOMAIN^^}" | cat > /etc/skt.d/data/$DOMAIN/title
TITLE=`sed "s/.COM/ /g" /etc/skt.d/data/$DOMAIN/title`
#${d^^}&nbsp;|&nbsp;Online&nbsp;Store
# INSTALL WORDPRESS
wp core install --url=$DOMAIN  --title=$TITLE --admin_user=${WP_USER} --admin_password=${WP_PASS} --admin_email=$EMAIL --path=/home/$DOMAIN/public_html
# REMOVE TRASH
rm -f /etc/skt.d/data/$DOMAIN/title
# FIX ERROR INSTALLATION FAILED: COULD NOT CREATE DIRECTORY.
#chmod 777 -R /home/$DOMAIN/public_html/wp-content
chmod 777 /home/$DOMAIN/public_html/wp-config.php

# XOA PLUGIN KHONG CAN THIET
wp plugin delete hello --path=/home/$DOMAIN/public_html
wp plugin delete akismet --path=/home/$DOMAIN/public_html

if [ $OPTION = 1 ];then
{
# CAI DAT KONTE THEME
wp plugin install woocommerce --path=/home/$DOMAIN/public_html --activate
wp theme install $url/themes/konte/konte_1_6_4.zip --path=/home/$DOMAIN/public_html --activate
# CAT DAT PLUGIN CAN THIET CUA KONTE
wp plugin install woocommerce-currency-switcher --path=/home/$DOMAIN/public_html --activate
wp plugin install $url/plugins/fommerce.zip --path=/home/$DOMAIN/public_html
wp plugin install kirki --path=/home/$DOMAIN/public_html --activate
wp plugin install variation-swatches-for-woocommerce --path=/home/$DOMAIN/public_html
wp plugin install $url/plugins/js_composer/js_composer_62.zip --path=/home/$DOMAIN/public_html --activate
wp plugin install https://uix.store/plugins/konte-addons.zip --path=/home/$DOMAIN/public_html --activate
wp plugin install https://uix.store/plugins/revslider.zip --path=/home/$DOMAIN/public_html --activate
wp plugin install https://uix.store/plugins/soo-wishlist.zip --path=/home/$DOMAIN/public_html --activate
}
elif [ $OPTION = 2 ];then
{
# Khu vuc theme Shoptimized

wp plugin install woocommerce --path=/home/$DOMAIN/public_html --activate
wp plugin install woocommerce-google-dynamic-retargeting-tag --path=/home/$DOMAIN/public_html --activate
wp theme install $url/themes/shoptimizer/shoptimizer.zip --path=/home/$DOMAIN/public_html --activate
wp plugin install https://files.commercegurus.com/commercegurus-commercekit.zip --path=/home/$DOMAIN/public_html --activate
wp plugin install smart-woocommerce-search --path=/home/$DOMAIN/public_html --activate
wp plugin install perfect-woocommerce-brands --path=/home/$DOMAIN/public_html --activate
wp plugin install one-click-demo-import --path=/home/$DOMAIN/public_html --activate
wp plugin install no-category-base-wpml --path=/home/$DOMAIN/public_html --activate
wp plugin install elementor --path=/home/$DOMAIN/public_html --activate
wp plugin install kirki --path=/home/$DOMAIN/public_html --activate
wp plugin install hurrytimer --path=/home/$DOMAIN/public_html --activate
wp plugin install $url/plugins/notification.zip --path=/home/$DOMAIN/public_html 
wp plugin install product-tabs-manager-for-woocommerce --path=/home/$DOMAIN/public_html --activate
# Widget for Shoptimized
# Delete some widget is not nessecery
wp widget delete search-2 recent-posts-2 recent-comments-2 archives-2 categories-2 meta-2 --path=/home/$DOMAIN/public_html

# Add a Text to Below Header

wp widget add custom_html header-1 --content="The impact of the COVID-19 crisis made transit time potentially affected. We will try to serve you the best. Hope you are always well" --path=/home/$DOMAIN/public_html
# Add a custom html to Single Product Custom Area
wp widget add custom_html single-product-field --content="<strong>Free USA shipping on all orders</strong><ul><li>30 days easy returns</li><li>Order yours before 2.30pm for same day dispatch</li></ul><fieldset><legend>Guaranteed Safe Checkout</legend><img class='alignnone size-large wp-image-1191' src='https://themedemo.commercegurus.com/shoptimizer/wp-content/uploads/sites/52/2018/07/trust-symbols_a-1024x108.jpg' alt='' width='1024' height='108' /></fieldset>" --path=/home/$DOMAIN/public_html

# Add a custom html to Cart Custom Area
wp widget add custom_html cart-field --content="<img class='alignnone size-large wp-image-1192' src='https://themedemo.commercegurus.com/shoptimizer/wp-content/uploads/sites/52/2018/07/trust-symbols_b-1024x108.jpg' alt='' width='1024' height='108' />" --path=/home/$DOMAIN/public_html

# Add Product Categories and Recent viewed products to Sidebar
wp widget add woocommerce_product_categories sidebar-1 1 --title="Product categories" --orderby="name" --dropdown=0 --count=0 --hierarchical=1 --show_chidren_only=0 --hide_empty=1 --max_depth="" --path=/home/$DOMAIN/public_html
wp widget add woocommerce_recently_viewed_products sidebar-1 2 --title="Recently Viewed Products" --number=5 --path=/home/$DOMAIN/public_html
# Add a custom html to Checkout Custom Area 
wp widget add custom_html checkout-field --content="<img class='alignnone size-large wp-image-1192' src='https://themedemo.commercegurus.com/shoptimizer/wp-content/uploads/sites/52/2018/07/trust-symbols_b-1024x108.jpg' alt='' width='1024' height='108' /> <h4>What they are saying</h4><img class='alignleft wp-image-829 size-thumbnail' style='width: 60px; border-radius: 50%; margin-right: 1.5em;' src='https://themedemo.commercegurus.com/shoptimizer/wp-content/uploads/sites/52/2018/05/reviews02-150x150.jpg' alt='Joel B' width='150' height='150' />Amazing card and it's a Steal for the price" --path=/home/$DOMAIN/public_html
wp widget add custom_html footer --content="<h4 style='color:white'>About Company</h4><ul><li><a href='/about-us'>Company info</a></li> <li><a href='/contact-us'>Contact Us</a></li> <li><a href='https://facebook.com'>Facebook</a></li>  <li><a href='https://twitter.com'>Twitter</a></li> <li><a href='https://instagram.com'>Instagram</a></li> </ul>" 1 --path=/home/$DOMAIN/public_html
wp widget add custom_html footer --content="<h4 style='color:white'>Tools &amp; apps</h4><ul><li><a href='/my-account/'>My Account</a></li><li><a href='/payment'>Payment</a></li><li><a href='/track-order'>Track Orders</a></li><li><a href='/checkout/'>Checkout</a></li> <li><a href='/cart/'>Cart</a></li> </ul>" 2 --path=/home/$DOMAIN/public_html
wp widget add custom_html footer --content="<h4 style='color:white'>Help & Contact</h4><ul><li><a href='/refund-policy'>Returns and Refund</a></li><li><a href='/privacy-policy'>Privacy Policy</a></li><li><a href='/term-of-service'>Terms &amp; Conditions</a></li><li><a href='/contact-us'>Contact Us</a></li><li><a href='/about-us'>About Us</a></li></ul> " 3 --path=/home/$DOMAIN/public_html
wp widget add custom_html footer --content="
<h4 style='color:white'>Company Info</h4><ul><li>Location: $ADDRESS</li><li>Phone: $PHONE </li><li>Email: $EMAIL </li></ul>" 4 --path=/home/$DOMAIN/public_html
wp widget add custom_html copyright --content="Copyright © 2012-2020 ${DOMAIN^^} Inc. All Rights Reserved<br/>" 1 --path=/home/$DOMAIN/public_html
wp widget add custom_html copyright --content="<img class='alignright size-full wp-image-183' src='https://themedemo.commercegurus.com/shoptimizer-demodata/wp-content/uploads/sites/53/2018/05/credit-cards.png' alt='' width='718' height='78' />" 2 --path=/home/$DOMAIN/public_html
}
else
	printf "Unknown themes\n"
fi

# WATCH LIST SIDEBAR ACTIVE
# wp sidebar list --path=/home/$DOMAIN/public_html

# THAY DOI CAU TRUC URL
wp rewrite structure '/%postname%/' --path=/home/$DOMAIN/public_html

# CAT DAT PLUGIN CAN THIET WOOCOMMERCE

wp plugin install woo-order-export-lite --path=/home/$DOMAIN/public_html --activate
wp plugin install woo-advanced-shipment-tracking --path=/home/$DOMAIN/public_html --activate
wp plugin install fast-velocity-minify --path=/home/$DOMAIN/public_html --activate
wp plugin install wp-product-feed-manager --path=/home/$DOMAIN/public_html --activate
wp plugin install woo-bought-together --path=/home/$DOMAIN/public_html --activate
wp plugin install contact-form-7 --path=/home/$DOMAIN/public_html --activate
wp plugin install mailchimp-for-wp --path=/home/$DOMAIN/public_html --activate
wp plugin install jetpack --path=/home/$DOMAIN/public_html --activate
wp plugin install wordpress-seo --path=/home/$DOMAIN/public_html --activate
wp plugin install wp-mail-smtp --path=/home/$DOMAIN/public_html --activate
wp plugin install kadence-woocommerce-email-designer --path=/home/$DOMAIN/public_html --activate
wp plugin install woocommerce-google-adwords-conversion-tracking-tag --path=/home/$DOMAIN/public_html --activate
wp plugin install meta-box --path=/home/$DOMAIN/public_html --activate
wp plugin install $url/plugins/woocommerce-shipping-tracking.zip --path=/home/$DOMAIN/public_html --activate
wp plugin install really-simple-ssl --path=/home/$DOMAIN/public_html
wp plugin install w3-total-cache --path=/home/$DOMAIN/public_html --activate
wp plugin install autoptimize --path=/home/$DOMAIN/public_html --activate
wp plugin install varnish-http-purge --path=/home/$DOMAIN/public_html --activate
chmod 777 -R /home/$DOMAIN/public_html/wp-content



# TAO MAIN MENU
wp menu create "Main Menu" --path=/home/$DOMAIN/public_html --allow-root
wp menu location assign main-menu primary --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'HOME' --position=1 / --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'TRACK' --position=2 /track-order --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'POLICY' --position=3 /# --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'Billing Term' --position=4  /billing-terms --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'Refund & Return' --position=5 /refund-policy --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'Term of Service' --position=6  /term-of-service --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'PAYMENT' --position=7 /payment --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'CONTACT' --position=8 /contact-us --path=/home/$DOMAIN/public_html --allow-root
wp menu item add-custom main-menu 'ABOUT' --position=9 /about-us --path=/home/$DOMAIN/public_html --allow-root

# TAO FOOOTER MENU
wp menu create "Footer Menu" --path=/home/$DOMAIN/public_html
wp menu item add-custom footer-menu 'TERM OF SERVICE' /term-of-service --path=/home/$DOMAIN/public_html
wp menu item add-custom footer-menu 'RETURN POLICY' /refund-policy --path=/home/$DOMAIN/public_html
wp menu item add-custom footer-menu 'PRIVACY POLICY' /privacy-policy --path=/home/$DOMAIN/public_html
wp menu item add-custom footer-menu 'CONTACT US' /contact-us --path=/home/$DOMAIN/public_html
wp menu item add-custom footer-menu 'ABOUT US' /about-us --path=/home/$DOMAIN/public_html

# XOA HELLO POST
wp post delete 1 --force --path=/home/$DOMAIN/public_html
# XOA PRIVACY POLICY PAGE
wp post delete 3 --force --path=/home/$DOMAIN/public_html

# Generate Necessary Page
# about us



curl -N $url/page/about.html | wp post generate --post_type=page --post_content --post_title="About Us" --count=1 --path=/home/$DOMAIN/public_html
# contact us
curl -N $url/page/contact.html | wp post generate --post_type=page --post_content --post_title="Contact Us" --count=1 --path=/home/$DOMAIN/public_html
# privacy policy
curl -N $url/page/privacy.html | wp post generate --post_type=page --post_content --post_title="Privacy Policy" --count=1 --path=/home/$DOMAIN/public_html
# refund and return
curl -N $url/page/refund.html | wp post generate --post_type=page --post_content --post_title="Refund Policy" --count=1 --path=/home/$DOMAIN/public_html
# term of service
curl -N $url/page/term.html | wp post generate --post_type=page --post_content --post_title="Term of Service" --count=1 --path=/home/$DOMAIN/public_html
# track order
curl -N $url/page/track-order.html | wp post generate --post_type=page --post_content --post_title="Track Order" --count=1 --path=/home/$DOMAIN/public_html
# thank you
curl -N $url/page/thank-you.html | wp post generate --post_type=page --post_content --post_title="Thank You" --count=1 --path=/home/$DOMAIN/public_html
# home page
curl -N $url/page/home.html | wp post generate --post_type=page --post_content --post_title="Home Page" --count=1 --path=/home/$DOMAIN/public_html
# billing page
curl -N $url/page/billing.html | wp post generate --post_type=page --post_content --post_title="Billing Terms" --count=1 --path=/home/$DOMAIN/public_html


#payment
mkdir -p /home/$DOMAIN/public_html/img
wget $url/img/paypal1.png && mv paypal1.png /home/$DOMAIN/public_html/img
wget $url/img/paypal2.png && mv paypal2.png /home/$DOMAIN/public_html/img
curl -N $url/page/payment.html | wp post generate --post_type=page --post_content --post_title="Payment" --count=1 --path=/home/$DOMAIN/public_html

wp search-replace 'changedomainhere' ${DOMAIN^^} wp_posts --path=/home/$DOMAIN/public_html
wp search-replace 'changeaddresshere' $ADDRESS wp_posts --path=/home/$DOMAIN/public_html
wp search-replace 'changebusinessnamehere' ${DOMAIN^^} wp_posts --path=/home/$DOMAIN/public_html
wp search-replace 'changemailhere' $EMAIl wp_posts --path=/home/$DOMAIN/public_html
chmod 777 -R /home/$DOMAIN/public_html/wp-content

# ENABLE ZONE - CLOUDFLARE
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "Content-Type: application/json" \
     --data '{"paused":'false'}'
#FULL SSL
curl -X PATCH "https://api.cloudflare.com/client/v4/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/settings/ssl" \
     -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "Content-Type: application/json" \
     --data '{"value":"full"}'
#ALWAYS HTTPS
curl -X GET "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/settings/always_use_https" \
     -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "Content-Type: application/json"


#source /etc/skt.d/data/$DOMAIN/sql.txt
#source /etc/skt.d/data/$DOMAIN/login.txt
clear
printf "${DOMAIN^^}\USERNAME: ${WP_USER}\PASSWORD: ${WP_PASS}\EMAIL: $EMAIL\n"
systemctl restart nginx php-fpm mariadb
fi