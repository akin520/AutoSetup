#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoCProxy (Nginx+cache+proxy)"
echo ""
echo ""
echo "AutoCProxy v0.0.1 by badb0y "
echo "Default Install PATH:/usr/local/{nginx}"
echo ""
echo "========================================================================="
echo ""
echo "For more information please visit https://github.com/akin520/AutoSetup"
echo ""

read -p "If the OK! Press any key to start..."

base() {
	echo "EVN Initialization..."
	if [ "`uname -m`" == "x86_64" ]; then
	rpm -Uhv http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
	rpm -Uhv http://mirrors.ustc.edu.cn/epel/6/x86_64/epel-release-6-8.noarch.rpm
	elif [ "`uname -m`" == "i686" ]; then
	rpm -Uhv http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm
	rpm -Uvh http://mirrors.ustc.edu.cn/epel/6/i386/epel-release-6-7.noarch.rpm
	fi
	yum -y install cmake bison bison-devel patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
	yum -y install cmake libmcrypt libmcrypt-devel libmhash libmhash-devel patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
	yum install pcre pcre-devel -y
}

download() {

	echo "Download soft..."
	wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz
	wget http://nginx.org/download/nginx-1.7.9.tar.gz
	wget --no-check-certificate https://sourceforge.net/projects/autosetup/files/soft/run.sh
	wget --no-check-certificate https://sourceforge.net/projects/autosetup/files/soft/stop.sh
	wget --no-check-certificate https://sourceforge.net/projects/autosetup/files/soft/openssl-1.0.0d.tar.gz
	wget --no-check-certificate https://raw.githubusercontent.com/akin520/AutoSetup/master/nginx_cache.conf -O nginx.conf
	wget --no-check-certificate https://raw.githubusercontent.com/akin520/AutoSetup/master/proxy_cache.conf -O proxy.conf

}

nginx() {

	echo "Installtion NGINX..."
	groupadd webadm
	useradd -g webadm webadm

	
	tar -zxvf ngx_cache_purge-2.3.tar.gz	
	tar zxvf openssl-1.0.0d.tar.gz
	tar -zxvf nginx-1.7.9.tar.gz
	cd nginx-1.7.9
	./configure --user=webadm --group=webadm --prefix=/usr/local/nginx --add-module=../ngx_cache_purge-2.3 --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-file-aio --with-openssl=../openssl-1.0.0d/
	make;make install
	cd ..

}

config() {

	echo "Configuration..."

	echo "nginx config"
	rm -rf /usr/local/nginx/conf/nginx.conf
	cp -a *.conf /usr/local/nginx/conf

	cp -a *.sh /root/
	sed -i '3d' /root/run.sh
	sed -i '2d' /root/stop.sh 
	chmod 755 /root/*.sh
}

msg() {
echo "========================================================================="
echo "Welcome to AutoNProxy (Nginx+cache+proxy)"
echo ""
echo ""
echo "AutoCProxy v0.0.1 by badb0y "
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