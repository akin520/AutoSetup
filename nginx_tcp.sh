#!/bin/bash

useradd www
wget --no-check-certificate https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
tar -zxvf pcre-8.43.tar.gz
cd pcre-8.43
./configure
make&&make install
cd ..

wget http://nginx.org/download/nginx-1.17.4.tar.gz
wget --no-check-certificate -O openssl-1.1.1c.tar.gz https://www.openssl.org/source/openssl-1.1.1c.tar.gz
wget http://prdownloads.sourceforge.net/libpng/zlib-1.2.11.tar.gz

tar xf nginx-1.17.4.tar.gz
tar xf openssl-1.1.1c.tar.gz
tar xf zlib-1.2.11.tar.gz

cd  nginx-1.17.4
./configure --prefix=/usr/local/nginx-tcp --user=www --group=www --with-stream --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-pcre=../pcre-8.43 --with-pcre-jit --with-zlib=../zlib-1.2.11 --with-openssl=../openssl-1.1.1c
make
make install
cd ..

rm -rf /usr/local/nginx-tcp/conf/nginx.conf
wget -O /usr/local/nginx-tcp/conf/nginx.conf https://raw.githubusercontent.com/akin520/AutoSetup/master/nginx-tcp.conf
/usr/local/nginx-tcp/sbin/nginx -t
