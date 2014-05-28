#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoPPN (Percaona[mysql]+PHP+NGINX)"
echo ""
echo ""
echo "AutoPPN v0.0.1 by badb0y "
echo "Default Install PATH:/usr/local/{percona.php.nginx}"
echo "Default percona(mysql) password:google123"
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
	rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
	elif [ "`uname -m`" == "i686" ]; then
	rpm -Uhv http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/rpmforge-release-0.3.6-1.el5.rf.i386.rpm
	rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-4.noarch.rpm
	fi
	yum -y install cmake bsion patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
	yum -y install cmake libmcrypt libmcrypt-devel libmhash libmhash-devel patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
	
	if [ -f /etc/my.cnf ]; then
	mv -f /etc/my.cnf /etc/my.cnf.autoppn
	fi

	if [ -f /etc/init.d/mysql ]; then
	mv -f /etc/init.d/mysql /etc/init.d/mysql.autoppn
	fi

	if [ -d /usr/local/percona ]; then
	mv /usr/local/percona /usr/local/percona.autoppn
	fi

	if [ -d /usr/local/nginx ]; then
	mv /usr/local/nginx /usr/local/nginx.autoppn
	fi

	if [ -d /usr/local/php ]; then
	mv /usr/local/php /usr/local/php.autoppn
	fi
}

download() {

	echo "Download soft..."
	wget http://www.nginx.org/download/nginx-1.1.6.tar.gz
	wget http://autosetup1.googlecode.com/files/php-5.2.13.tar.gz
	wget http://autosetup1.googlecode.com/files/php-5.2.13-fpm-0.5.13.diff.gz
	wget http://autosetup1.googlecode.com/files/libiconv-1.13.tar.gz
	wget http://autosetup1.googlecode.com/files/libmcrypt-2.5.8.tar.gz
	wget http://autosetup1.googlecode.com/files/mcrypt-2.6.8.tar.gz
	wget http://autosetup1.googlecode.com/files/mhash-0.9.9.9.tar.gz
	wget http://autosetup1.googlecode.com/files/pcre-8.01.tar.gz
	wget http://www.percona.com/redir/downloads/Percona-Server-5.5/Percona-Server-5.5.16-22.0/source/Percona-Server-5.5.16-rel22.0.tar.gz
	wget http://autosetup1.googlecode.com/files/php-fpm.conf
	wget http://autosetup1.googlecode.com/files/nginx.conf
	wget http://autosetup1.googlecode.com/files/fcgi.conf
	wget http://autosetup1.googlecode.com/files/run.sh
	wget http://autosetup1.googlecode.com/files/stop.sh
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
	
	#if [ -d /usr/lib64 ]; then
	#\cp -frp /usr/lib64/libjpeg.* /usr/lib/
	#\cp -frp /usr/lib64/libpng.* /usr/lib/
	#fi
}

mysql() {

	echo "Installation MYSQL..."
	groupadd mysql
	useradd -g mysql mysql
	tar -zxvf Percona-Server-5.5.16-rel22.0.tar.gz
	cd Percona-Server-5.5.16-rel22.0
	cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/percona -DWITH_INNOBASE_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci  -DMYSQL_USER=mysql  -DWITH_DEBUG=0
	#cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/percona -DDEFAULT_CHARSET=utf8  -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all -DWITH_SSL=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 
	make && make install
	cp support-files/my-medium.cnf /etc/my.cnf
	cp support-files/mysql.server /etc/init.d/mysql
	cd /usr/local/percona
	./scripts/mysql_install_db --user=mysql
	chown -R mysql /usr/local/percona/data
	chgrp -R mysql /usr/local/percona/.
	chmod 755 /etc/init.d/mysql
	chkconfig --level 345 mysql on
	echo "/usr/local/percona/lib" >> /etc/ld.so.conf
	ldconfig
	service mysql start
	cd -
	cd ..
	/usr/local/percona/bin/mysqladmin -u root password google123
	echo 'export PATH="/usr/local/percona/bin:$PATH"' >>/etc/profile
	source /etc/profile
}

php() {

	echo "Installtion PHP..."
	tar zxvf php-5.2.13.tar.gz
	gzip -cd php-5.2.13-fpm-0.5.13.diff.gz | patch -d php-5.2.13 -p1
	cd php-5.2.13/
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/percona --with-mysqli=/usr/local/percona/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap
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

	tar zxvf nginx-1.1.6.tar.gz
	cd nginx-1.1.6
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

	echo '<?phpinfo()?>' >/home/webadm/index.php
	
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

	echo "Installtion AutoPPN..."
	base
	download
	installlib
	mysql
	php
	nginx
	config
}

main