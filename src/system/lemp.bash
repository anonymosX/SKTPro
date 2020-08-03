#!/bin/bash
printf "ARE YOU SURE TO INSTALL LEMP? - Y/N: "
read YN
if [ ${YN} = 0 ]; then
	sh /root/install
elif [ ${YN} = 'Y' -o ${YN} = 'y' ]; then
{
printf "YOU HAVE CHOOSE YES\n"
yum update -y
yum install -y wget
# MARIADB 10.3 REPO
cat > /etc/yum.repos.d/mariadb.repo<<"EOF"
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos73-amd64/
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

# Create nginx stable line repo
#cat > /etc/yum.repos.d/nginx.repo<<"EOF"
#[nginx]
#name=nginx repo
#baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
#gpgcheck=0
#enabled=1
#EOF

# EPEL and REMI REPO
yum install -y epel-release 
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -ivh http://nginx.org/packages/centos/7/x86_64/RPMS/nginx-1.16.1-1.el7.ngx.x86_64.rpm

# HTTP, HTTPS PORT (80,443)
yum install -y firewalld
systemctl start firewalld && systemctl enable firewalld
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
# MEMCACHED PORT (11211)
firewall-cmd --zone=public --add-port=11211/tcp --permanent
firewall-cmd --reload

# NGINX and PHP 7.4 INSTALL
yum --enablerepo=remi,remi-php74 install -y php-common php-mbstring php-fpm php-mysql php-xml php-pecl-memcache php-pecl-memcached php-mcrypt php-cli php-opcache php-pecl-apc php-gd php-mysqlnd
systemctl start nginx ; systemctl enable nginx ;  systemctl start php-fpm ; systemctl enable php-fpm

# REFRESH HOME
rm -rf /home/*

# PHP-FPM CONFIG
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.owner/listen.owner/g' /etc/php-fpm.d/www.conf
sed -i 's/;listen.group/listen.group/g' /etc/php-fpm.d/www.conf
sed -i 's/nobody/nginx/g' /etc/php-fpm.d/www.conf
sed -i 's+listen = 127.0.0.1:9000+listen = /run/php-fpm/php-fpm.sock+g' /etc/php-fpm.d/www.conf
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /etc/php.ini

# SELINUX DISABLE
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl restart nginx ; systemctl restart php-fpm

# MARIADB-MYSQL INSTALL
yum install -y mariadb-server mariadb-client
systemctl start mariadb ; systemctl enable mariadb

# Mail 
mkdir -p /etc/skt.d/tool/data
curl -N https://raw.githubusercontent.com/anonymosX/SKTPro/master/src/data/randmail.txt | cat >> /etc/skt.d/tool/data/randmail

# PHP CONFIG EXTENSION
mkdir -p /etc/nginx/conf
cd /etc/nginx/conf
cat > php.conf <<"EOF"
#Ep xu ly PHP thong qua PHP-FPM
location ~* \.php$ {
    fastcgi_index   index.php;
    #fastcgi_pass    127.0.0.1:9000;
    fastcgi_pass   unix:/run/php-fpm/php-fpm.sock;
    include         fastcgi_params;
    fastcgi_param   SCRIPT_FILENAME   $document_root$fastcgi_script_name;
    fastcgi_param   SCRIPT_NAME   $fastcgi_script_name;
    # Thiết lập timeout cho proxy
    fastcgi_connect_timeout 60;
    fastcgi_send_timeout 180;
    fastcgi_read_timeout 180;
    fastcgi_buffer_size 512k;
    fastcgi_buffers 512 16k;
    fastcgi_busy_buffers_size 512k;
    fastcgi_temp_file_write_size 512k;
    fastcgi_intercept_errors on;
}
EOF
cat > block.conf<<"EOF"
location = /robots.txt  { access_log off; log_not_found off; }
location = /favicon.ico { access_log off; log_not_found off; expires 30d; }
location ~ /\.          { access_log off; log_not_found off; deny all; }
location ~ ~$           { access_log off; log_not_found off; deny all; }
location ~ /\.git { access_log off; log_not_found off; deny all; }
location = /nginx.conf { access_log off; log_not_found off; deny all; }
EOF
cat > staticfiles.conf<<"EOF"
location ~* \.(3gp|gif|jpg|jpeg|png|ico|wmv|avi|asf|asx|mpg|mpeg|mp4|pls|mp3|mid|wav|swf|flv|exe|zip|tar|rar|gz|tgz|bz2|uha|7z|doc|docx|xls|xlsx|pdf|iso|eot|svg|ttf|woff|woff2|js)$ {
    gzip_static off;
    add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    access_log off;
    expires max;
    break;
}
location ~* \.(css|js)$ {
    #add_header Pragma public;
    add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    access_log off;
    expires 30d;
    break;
}
EOF
cat > gzip.conf<<"EOF"
gzip on;
gzip_comp_level 2;
gzip_http_version 1.0;
gzip_proxied any;
gzip_min_length 1100;
gzip_buffers 16 8k;
gzip_types text/plain text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript;
# Disable for IE < 6 because there are some known problems
gzip_disable "MSIE [1-6].(?!.*SV1)";
# Add a vary header for downstream proxies to avoid sending cached gzipped files to IE6
gzip_vary on;
EOF
cat > upload.conf<<"EOF"
#set file upload to 15M
client_max_body_size 15M;
EOF
cat > pagespeed.conf<<"EOF"
# enable ngx_pagespeed
pagespeed on;
pagespeed FileCachePath /var/ngx_pagespeed_cache;

# let's speed up PageSpeed by storing it in the super duper fast memcached
pagespeed MemcachedThreads 1;
pagespeed MemcachedServers "localhost:11211";
# disable CoreFilters
pagespeed RewriteLevel PassThrough;
# enable collapse whitespace filter
pagespeed EnableFilters collapse_whitespace;
# enable JavaScript library offload
pagespeed EnableFilters canonicalize_javascript_libraries;
# combine multiple CSS files into one
pagespeed EnableFilters combine_css;
# combine multiple JavaScript files into one
pagespeed EnableFilters combine_javascript;
# remove tags with default attributes
pagespeed EnableFilters elide_attributes;
# improve resource cacheability
pagespeed EnableFilters extend_cache;
# flatten CSS files by replacing @import with the imported file
pagespeed EnableFilters flatten_css_imports;
pagespeed CssFlattenMaxBytes 5120;
# defer the loading of images which are not visible to the client
pagespeed EnableFilters lazyload_images;
# enable JavaScript minification
pagespeed EnableFilters rewrite_javascript;
# enable image optimization
pagespeed EnableFilters rewrite_images;
# pre-solve DNS lookup
pagespeed EnableFilters insert_dns_prefetch;
# rewrite CSS to load page-rendering CSS rules first.
pagespeed EnableFilters prioritize_critical_css;
EOF
# Remove Default
rm -f /etc/nginx/conf.d/default.conf
cat > /etc/nginx/conf.d/default.conf<<"EOF"
server {
    listen       80 default;
    server_name  localhost;
    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index index.php index.html index.htm;
        try_files $uri $uri/ /index.php?q=$uri&$args;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
   location ~ \.php$ {
        root           /usr/share/nginx/html;
        fastcgi_pass   unix:/run/php-fpm/php-fpm.sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME   $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
EOF






# MEMCACHED INSTALL
printf "Installing Memcached\n"
yum --enablerepo=remi install memcached -y
sed -i 's/CACHESIZE="64"/CACHESIZE="1024"/g' /etc/sysconfig/memcached
systemctl start memcached
systemctl enable memcached
systemctl restart memcached
sed -i "s/session.save_handler = files/session.save_handler = memcached/g" /etc/php.ini
systemctl restart nginx
systemctl restart php-fpm
systemctl restart mariadb


# MYSQL PASSWORD CONFIRM
cat > /root/.my.cnf<<"EOF"
[client]
user=root
password=SKTpWI5IexxF4oPenOYlOhJ
EOF
source /root/.my.cnf
printf "\nY\n${password}\n${password}\nY\nY\nY\nY\n" | mysql_secure_installation 
clear
# W-CLI INSTALL
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

mkdir -p /etc/skt.d/tool/mariadb
cat > /etc/skt.d/tool/mariadb/automysql<<"EOF"
if [ ! "$(/bin/systemctl status  mariadb.service | awk 'NR==3 {print $2}')" == "active" ]; then
systemctl start mariadb.service
exit
fi
EOF
chmod +x /etc/skt.d/tool/mariadb/automysql
(crontab -u root -l ; echo "*/5 * * * * /etc/skt.d/tool/mariadb/automysql") | crontab -u root -

# INSTALL MOD_PAGESPEED
systemctl stop mariadb
systemctl stop php-fpm
source /etc/skt.d/tool/system/mod_pagespeed.bash

# CERTBOT INSTALL
yum install -y certbot-nginx
yum install -y bind-utils
mkdir -p /etc/letsencrypt/renewal/
systemctl restart nginx
systemctl restart mariadb
systemctl restart php-fpm
}
elif [ ${YN} = 'N' -o ${YN} = 'n' ]; then
	printf "YOU HAVE CHOOSE NO\n"
	sh /etc/skt.d/tool/system/system.bash
else
	printf "CODE: INVALID ENTER\n"
	sh /etc/skt.d/tool/system/system.bash
fi




