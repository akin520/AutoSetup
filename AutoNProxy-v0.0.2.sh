#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoNProxy (Nginx-proxy)"
echo ""
echo ""
echo "AutoNProxy v0.0.2 by badb0y "
echo "Default Install PATH:/usr/local/{nginx}"
echo ""
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo ""

read -p "If the OK! Press any key to start..."

base() {

	echo "EVN Initialization..."
	if [ "`uname -m`" == "x86_64" ]; then
	rpm -Uhv http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.3.6-1.el5.rf.x86_64.rpm
	elif [ "`uname -m`" == "i686" ]; then
	rpm -Uhv http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/rpmforge-release-0.3.6-1.el5.rf.i386.rpm
	fi
	yum -y install patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
}

download() {

	echo "Download soft..."
	wget  http://sysoev.ru/nginx/nginx-1.0.0.tar.gz
	wget  http://autosetup1.googlecode.com/files/pcre-8.01.tar.gz
	wget  http://autosetup1.googlecode.com/files/proxy.conf
	wget  http://autosetup1.googlecode.com/files/run.sh
	wget  http://autosetup1.googlecode.com/files/stop.sh
	wget  http://autosetup1.googlecode.com/files/nginx1.conf
}

nginx() {

	echo "Installtion NGINX..."
	groupadd webadm
	useradd -g webadm webadm

	tar zxvf pcre-8.01.tar.gz
	cd pcre-8.01/
	./configure
	make ;make install
	cd ../

	tar zxvf nginx-1.0.0.tar.gz
	cd nginx-1.0.0
	./configure --user=webadm --group=webadm --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
	make; make install
	cd ../
}

config() {

	echo "Configuration..."

	echo "nginx config"
	rm -rf /usr/local/nginx/conf/nginx.conf
	cp -a proxy.conf /usr/local/nginx/conf/
	cp -a nginx1.conf /usr/local/nginx/conf/nginx.conf


	cp -a run.sh /root/
	cp -a stop.sh /root/
	sed -i '3d' /root/run.sh
	sed -i '2d' /root/stop.sh 
	chmod 755 /root/*.sh
}

msg() {
echo "========================================================================="
echo "Welcome to AutoNProxy (Nginx-proxy)"
echo ""
echo ""
echo "AutoNProxy v0.0.2 by badb0y "
echo "Default Install PATH:/usr/local/{nginx}"
echo ""
echo "========================================================================="
echo ""
}

main() {

	echo "Installtion AutoNProxy..."
	base
	download
	nginx
	config
	msg
}

main