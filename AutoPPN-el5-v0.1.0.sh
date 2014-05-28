#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoPPN (Percaona[mysql]+PHP+NGINX)"
echo ""
echo ""
echo "AutoPPN v0.1.0 by badb0y "
echo "Default Install PATH:/usr/local/{percona.php.nginx}"
echo "Default percona(mysql) password:google123"
echo "Defautl web path:/home/webadm [http://localhost/info.php]"
echo "RUN:	/root/nginx.sh start"
echo "STOP:	/root/nginx.sh stop"
echo "RELOAD:	/root/nginx.sh reload"
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo ""

read -p "If the OK! Press any key to start..."

base() {

	echo "EVN Initialization..."
	if [ "`uname -m`" == "x86_64" ]; then
	rpm -Uhv http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.3.6-1.el5.rf.x86_64.rpm
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
	elif [ "`uname -m`" == "i686" ]; then
	rpm -Uhv http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/rpmforge-release-0.3.6-1.el5.rf.i386.rpm
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
	fi
	yum -y install cmake bison bison-devel patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
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

	if [ -d /usr/local/php5314 ]; then
	mv /usr/local/php5314 /usr/local/php5314.autoppn
	fi
}

download() {

	echo "Download soft..."
	if [ ! -s nginx-1.2.2.tar.gz ]; then
	wget http://www.nginx.org/download/nginx-1.2.2.tar.gz
	fi
	if [ ! -s php-5.3.14.tar.gz ]; then
	wget http://cn2.php.net/get/php-5.3.14.tar.gz/from/this/mirror
	fi
	if [ ! -s libiconv-1.13.tar.gz ]; then
	wget http://autosetup1.googlecode.com/files/libiconv-1.13.tar.gz
	fi
	if [ ! -s libmcrypt-2.5.8.tar.gz ]; then
	wget http://autosetup1.googlecode.com/files/libmcrypt-2.5.8.tar.gz
	fi
	if [ ! -s mcrypt-2.6.8.tar.gz ]; then
	wget http://autosetup1.googlecode.com/files/mcrypt-2.6.8.tar.gz
	fi
	if [ ! -s mhash-0.9.9.9.tar.gz ]; then
	wget http://autosetup1.googlecode.com/files/mhash-0.9.9.9.tar.gz
	fi
	if [ ! -s pcre-8.01.tar.gz ]; then
	wget http://autosetup1.googlecode.com/files/pcre-8.01.tar.gz
	fi
	if [ ! -s Percona-Server-5.5.24-rel26.0.tar.gz ]; then
	wget http://www.percona.com/redir/downloads/Percona-Server-5.5/Percona-Server-5.5.24-26.0/source/Percona-Server-5.5.24-rel26.0.tar.gz
	fi
	if [ ! -s nginx.conf ]; then
	wget http://autosetup1.googlecode.com/files/nginx-1.2.conf -O nginx.conf
	fi
	if [ ! -s fcgi.conf ]; then
	wget http://autosetup1.googlecode.com/files/www-1.2.conf -O www.conf
	fi
	if [ ! -s fcgi.conf ]; then
	wget http://autosetup1.googlecode.com/files/fcgi.conf
	fi
	if [ ! -s nginx.sh ]; then
	wget http://autosetup1.googlecode.com/files/nginx-init.sh -O nginx.sh
	fi
	if [ ! -s openssl-1.0.0d.tar.gz ];then
	wget http://www.openssl.org/source/openssl-1.0.0d.tar.gz
	fi

	echo "Download soft END..."
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
	
	#ldap lib copy /usr/lib for php
	cp -frp /usr/lib64/libldap* /usr/lib/
	cp -rfp /usr/lib64/* /usr/lib

	#if [ -d /usr/lib64 ]; then
	#\cp -frp /usr/lib64/libjpeg.* /usr/lib/
	#\cp -frp /usr/lib64/libpng.* /usr/lib/
	#fi
}

mysql() {

	echo "Installation MYSQL..."
	groupadd mysql
	useradd -g mysql mysql
	tar -zxvf Percona-Server-5.5.24-rel26.0.tar.gz
	cd Percona-Server-5.5.24-rel26.0
	cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/percona -DWITH_INNOBASE_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci  -DMYSQL_USER=mysql  -DWITH_DEBUG=0 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1
	#cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/percona -DDEFAULT_CHARSET=utf8  -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all -DWITH_SSL=system -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1
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
	groupadd webadm
	useradd -g webadm webadm
	tar -zxvf php-5.3.14.tar.gz
	cd php-5.3.14
	./configure --prefix=/usr/local/php5314 --with-config-file-path=/usr/local/php5314/etc --with-mysql=/usr/local/percona --with-mysqli=/usr/local/percona/bin/mysql_config --with-pdo-mysql=/usr/local/percona/ --with-fpm-user=webadm --with-fpm-group=webadm --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap	
	make ZEND_EXTRA_LIBS='-liconv' &&make install
	cp php.ini-production /usr/local/php5314/etc/php.ini 
	cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm 
	cp sapi/fpm/php-fpm.conf /usr/local/php5314/etc/php-fpm.conf
	cd ..

	sed -i 's#short_open_tag = Off#short_open_tag = On#g' /usr/local/php5314/etc/php.ini

	sed -i 's#;pid = run/php-fpm.pid#pid = run/php-fpm.pid#g' /usr/local/php5314/etc/php-fpm.conf
	sed -i 's#pm.max_children = 5#pm.max_children = 32#g' /usr/local/php5314/etc/php-fpm.conf
	sed -i 's#pm.start_servers = 2#pm.start_servers = 16#g' /usr/local/php5314/etc/php-fpm.conf
	sed -i 's#pm.min_spare_servers = 1#pm.min_spare_servers = 8#g' /usr/local/php5314/etc/php-fpm.conf
	sed -i 's#pm.max_spare_servers = 3#pm.max_spare_servers = 32#g' /usr/local/php5314/etc/php-fpm.conf
	sed -i 's#;pm.max_requests = 500#pm.max_requests = 120#g' /usr/local/php5314/etc/php-fpm.conf

	chmod 755 /etc/init.d/php-fpm
	chkconfig --add php-fpm
	chkconfig --level 345 php-fpm on
	#/etc/init.d/php-fpm start

}

nginx() {

	echo "Installtion NGINX..."

	tar zxvf pcre-8.01.tar.gz
	cd pcre-8.01/
	./configure
	make ;make install
	cd ../
	
	tar zxvf openssl-1.0.0d.tar.gz
	tar zxvf nginx-1.2.2.tar.gz
	cd nginx-1.2.2
	./configure --user=webadm --group=webadm --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-openssl=../openssl-1.0.0d/
	make; make install
	cd ../
}

config() {

	echo "Configuration..."

	echo "nginx config"
	rm -rf /usr/local/nginx/conf/fcgi.conf
	rm -rf /usr/local/nginx/conf/nginx.conf
	mkdir /usr/local/nginx/conf/conf
	cp -a fcgi.conf /usr/local/nginx/conf/
	cp -a nginx.conf /usr/local/nginx/conf/
	cp -a www.conf /usr/local/nginx/conf/conf/
	echo '<?phpinfo()?>' >/home/webadm/index.php
	
	cp -a nginx.sh /root/
	chmod 755 /root/*.sh
}
run() {
	echo ""
	echo ""
	echo "open_basedir set:"
	echo "[PATH=/home/webadm]"
	echo "open_basedir = /home/webadm:/tmp"
	echo ""
	echo ""
	echo "Run Script:	/root/nginx.sh"
	echo "Add script to /etc/rc.local, content:/root/nginx.sh start"

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
	run
}

main

