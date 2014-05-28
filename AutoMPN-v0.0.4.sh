#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoMPN (MYSQL+PHP+NGINX)"
echo ""
echo ""
echo "AutoMPN v0.0.4 by badb0y "
echo "Default Install PATH:/usr/local/{mysql.php.nginx}"
echo "Default mysql password:google123"
echo "Defautl web path:/home/webadm [http://localhost/info.php]"
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
	wget -c http://sysoev.ru/nginx/nginx-0.8.53.tar.gz
	wget -c http://autosetup1.googlecode.com/files/php-5.2.13.tar.gz
	wget -c http://autosetup1.googlecode.com/files/php-5.2.13-fpm-0.5.13.diff.gz
	wget -c http://autosetup1.googlecode.com/files/libiconv-1.13.tar.gz
	wget -c http://autosetup1.googlecode.com/files/libmcrypt-2.5.8.tar.gz
	wget -c http://autosetup1.googlecode.com/files/mcrypt-2.6.8.tar.gz
	wget -c http://autosetup1.googlecode.com/files/mhash-0.9.9.9.tar.gz
	wget -c http://autosetup1.googlecode.com/files/pcre-8.01.tar.gz
	wget -c http://autosetup1.googlecode.com/files/mysql-5.5.2-m2.tar.gz
	wget -c http://autosetup1.googlecode.com/files/php-fpm.conf
	wget -c http://autosetup1.googlecode.com/files/nginx.conf
	wget -c http://autosetup1.googlecode.com/files/fcgi.conf
	wget -c http://autosetup1.googlecode.com/files/run.sh
	wget -c http://autosetup1.googlecode.com/files/stop.sh
}

installlib() {

	echo "Installation support library..."
	tar zxvf libiconv-1.13.tar.gz
	cd libiconv-1.13/
	./configure --prefix=/usr/local
	make
	make install
	cd ../

	tar zxvf libmcrypt-2.5.8.tar.gz 
	cd libmcrypt-2.5.8/
	./configure
	make
	make install
	/sbin/ldconfig
	cd libltdl/
	./configure --enable-ltdl-install
	make
	make install
	cd ../../

	tar zxvf mhash-0.9.9.9.tar.gz
	cd mhash-0.9.9.9/
	./configure
	make
	make install
	cd ../

	echo "/usr/local/lib" >> /etc/ld.so.conf
	ldconfig

	ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
	
	tar zxvf mcrypt-2.6.8.tar.gz
	cd mcrypt-2.6.8/
	/sbin/ldconfig
	./configure
	make
	make install
	cd ../
}

mysql() {

	echo "Installation MYSQL..."
	tar -zxvf mysql-5.5.2-m2.tar.gz
	cd mysql-5.5.2-m2/
	./configure --prefix=/usr/local/mysql/ --enable-assembler --with-extra-charsets=complex --enable-thread-safe-client --with-big-tables --with-readline --with-ssl --with-embedded-server --enable-local-infile --with-plugins=partition,innobase,myisammrg
	make;make install
	cd ..

	groupadd mysql
	useradd -g mysql mysql
	cp /usr/local/mysql/share/mysql/my-medium.cnf /etc/my.cnf
	/usr/local/mysql/bin/mysql_install_db --user=mysql
	chown -R mysql /usr/local/mysql/var
	chgrp -R mysql /usr/local/mysql/.
	cp /usr/local/mysql/share/mysql/mysql.server /etc/init.d/mysql
	chmod 755 /etc/init.d/mysql
	chkconfig --level 345 mysql on
	echo "/usr/local/mysql/lib/mysql" >> /etc/ld.so.conf
	ldconfig
	ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
	ln -s /usr/local/mysql/include/mysql /usr/include/mysql
	service mysql start
	/usr/local/mysql/bin/mysqladmin -u root password google123
	service mysql stop
}

php() {

	echo "Installtion PHP..."
	tar zxvf php-5.2.13.tar.gz
	gzip -cd php-5.2.13-fpm-0.5.13.diff.gz | patch -d php-5.2.13 -p1
	cd php-5.2.13/
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap
	make ZEND_EXTRA_LIBS='-liconv'
	make install
	cp php.ini-dist /usr/local/php/etc/php.ini
	cd ..
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

	tar zxvf nginx-0.8.53.tar.gz
	cd nginx-0.8.53
	./configure --user=webadm --group=webadm --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module
	make; make install
	cd ../
}

config() {

	echo "Configuration..."
	echo "php config"
	rm -rf /usr/local/php/etc/php-fpm.conf
	cp php-fpm.conf /usr/local/php/etc/

	echo "nginx config"
	rm -rf /usr/local/nginx/conf/fcgi.conf
	rm -rf /usr/local/nginx/conf/nginx.conf
	cp -a fcgi.conf /usr/local/nginx/conf/
	cp -a nginx.conf /usr/local/nginx/conf/

	echo '<?phpinfo()?>' >/home/webadm/info.php
	
	#echo "ulimit -SHn 51200" >>/root/run.sh
	#echo "/usr/local/php/sbin/php-fpm start" >>/root/run.sh
	#echo "/usr/local/nginx/sbin/nginx -t" >>/root/run.sh
	#echo "/usr/local/nginx/sbin/nginx" >>/root/run.sh
	#sed -i '1 i#!/bin/bash' /root/run.sh
	
	#echo "kill akintxt" >>/root/stop.sh
	#echo "/usr/local/php/sbin/php-fpm stop" >>/root/stop.sh
	#sed -i 's!akintxt!`cat /usr/local/nginx/logs/nginx.pid`!g' /root/stop.sh
	#sed -i '1 i#!/bin/bash' /root/stop.sh
	cp -a run.sh /root/
	cp -a stop.sh /root/
	chmod 755 /root/*.sh
}

main() {

	echo "Installtion AutoMPN..."
	base
	download
	installlib
	mysql
	php
	nginx
	config
}

main