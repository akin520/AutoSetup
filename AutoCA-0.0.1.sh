#!/bin/sh

# create self-signed server certificate:

read -p "Enter your domain [www.example.com]: " DOMAIN

if [[ ! -f ca.crt ]]; then
    mkdir -p /etc/pki/CA/
    rm -rf /etc/pki/CA/index.txt
    rm -rf /etc/pki/CA/serial
    touch /etc/pki/CA/{index.txt,serial}
    echo "01" > /etc/pki/CA/serial
    echo "Create CA key..."
    SUBJECT="/C=BJ/ST=BJ/L=OMP/O=OMP/OU=OMP/CN=OMPSSL"
    openssl genrsa -des3 -out ca.key 2048
    openssl req -new -subj $SUBJECT -x509 -days 3650 -key ca.key -out ca.crt
fi

echo "Create server key..."
SUBJECT="/C=BJ/ST=BJ/L=OMP/O=OMP/OU=OMP/CN=$DOMAIN"
openssl genrsa -des3 -out $DOMAIN.key 1024

echo "Create server certificate signing request..."
openssl req -new -subj $SUBJECT -key $DOMAIN.key -out $DOMAIN.csr

echo "Remove password..."

mv $DOMAIN.key $DOMAIN.origin.key
openssl rsa -in $DOMAIN.origin.key -out $DOMAIN.key

echo "Sign SSL certificate..."
#openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key -out $DOMAIN.crt
openssl ca -policy policy_anything -days 3650 -cert ca.crt -keyfile ca.key -in $DOMAIN.csr -out $DOMAIN.crt
cat ca.crt >> $DOMAIN.crt

#openssl s_client -connect wap.com.cn:443
#yum install ca-certificates
#update-ca-trust force-enable
#cp ca.crt /etc/pki/ca-trust/source/anchors/
#update-ca-trust extract

echo ""
echo ""
echo "TODO:"
echo "Copy $DOMAIN.crt to /etc/nginx/ssl/$DOMAIN.crt"
echo "Copy $DOMAIN.key to /etc/nginx/ssl/$DOMAIN.key"
echo "Add configuration in nginx:"
echo "server {"
echo "    ..."
echo "    listen 443 ssl;"
echo "    ssl_certificate     /etc/nginx/ssl/$DOMAIN.crt;"
echo "    ssl_certificate_key /etc/nginx/ssl/$DOMAIN.key;"
echo "    ssl_client_certificate /etc/nginx/ssl/ca.crt;"
echo "}"
