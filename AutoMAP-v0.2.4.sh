#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoMAP (Apache+Mysql+PHP)"
echo ""
echo ""
echo "AutoMAP v0.2.4 by badb0y "
echo "Default Install PATH:/usr/local/{mysql.php.apache2}"
echo "Default mysql password:google123"
echo "Defautl web path:/usr/local/apache2/htdocs [http://localhost/info.php]"
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo ""
export LANC=C

read -p "If the OK! Press any key to start..."

if [ "`uname -m`" == "x86_64" ]; then
rpm -Uhv http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.3.6-1.el5.rf.x86_64.rpm
rpm -Uhv http://mirrors.ustc.edu.cn/epel/5/x86_64/epel-release-5-4.noarch.rpm
elif [ "`uname -m`" == "i686" ]; then
rpm -Uhv http://apt.sw.be/redhat/el5/en/i386/rpmforge/RPMS/rpmforge-release-0.3.6-1.el5.rf.i386.rpm
rpm -Uvh http://mirrors.ustc.edu.cn/epel/5/i386/epel-release-5-4.noarch.rpm
fi
yum -y install bison bison-devel cmake patch make gcc gd gd-devel libxml* gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers



wget http://autosetup1.googlecode.com/files/libiconv-1.13.tar.gz
wget http://autosetup1.googlecode.com/files/libmcrypt-2.5.8.tar.gz
wget http://autosetup1.googlecode.com/files/mcrypt-2.6.8.tar.gz
wget http://autosetup1.googlecode.com/files/mhash-0.9.9.9.tar.gz
wget http://autosetup1.googlecode.com/files/mysql-5.5.19.tar.gz
#wget http://www.percona.com/redir/downloads/Percona-Server-5.5/Percona-Server-5.5.16-22.0/source/Percona-Server-5.5.16-rel22.0.tar.gz
wget http://autosetup1.googlecode.com/files/httpd-2.2.21.tar.gz
wget http://autosetup1.googlecode.com/files/php-5.3.8.tar.gz


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


echo "Installation MYSQL..."
groupadd mysql
useradd -g mysql mysql
tar -zxvf mysql-5.5.19.tar.gz
cd mysql-5.5.19
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DWITH_INNOBASE_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci  -DMYSQL_USER=mysql  -DWITH_DEBUG=0
#cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/percona -DDEFAULT_CHARSET=utf8  -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all -DWITH_SSL=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 
make && make install
cp support-files/my-medium.cnf /etc/my.cnf
cp support-files/mysql.server /etc/init.d/mysql
cd /usr/local/mysql
./scripts/mysql_install_db --user=mysql
chown -R mysql /usr/local/mysql/data
chgrp -R mysql /usr/local/mysql/.
chmod 755 /etc/init.d/mysql
chkconfig --level 345 mysql on
echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
ldconfig
service mysql start
cd -
cd ..
/usr/local/mysql/bin/mysqladmin -u root password google123
echo 'export PATH="/usr/local/mysql/bin:$PATH"' >>/etc/profile
source /etc/profile


tar -zxvf httpd-2.2.21.tar.gz
cd httpd-2.2.21
./configure --prefix=/usr/local/apache2 --enable-so --enable-track-vars --enable-mods-shared=all --enable-cache --enable-disk-cache --enable-mem-cache --enable-rewrite
make&&make install
cd ..


tar -zxvf php-5.3.8.tar.gz
cd php-5.3.8
./configure --prefix=/usr/local/php53 --with-apxs2=/usr/local/apache2/bin/apxs --with-mysql=/usr/local/mysql --with-config-file-path=/usr/local/php53/etc --with-gd --enable-gd-native-ttf --enable-gd-jis-conv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --enable-xml --enable-mbstring  --enable-sockets
make ZEND_EXTRA_LIBS='-liconv'
make install
cp php.ini-production /usr/local/php53/etc/php.ini
sed -i 's#short_open_tag = Off#short_open_tag = On#g' /usr/local/php53/etc/php.ini
cd ..


sed -i 's/index.html/index.php index.html/g' /usr/local/apache2/conf/httpd.conf
echo "AddType application/x-httpd-php .php" >>/usr/local/apache2/conf/httpd.conf
echo "AddType application/x-httpd-php-source .phps" >>/usr/local/apache2/conf/httpd.conf

cat >/usr/local/apache2/htdocs/info.php<<EOF
<?
phpinfo();
?>
EOF

chkconfig httpd off
service httpd stop
/usr/local/apache2/bin/apachectl start

clear
echo "========================================================================="
echo "Welcome to AutoMAP (Apache+Mysql+PHP)"
echo ""
echo ""
echo "AutoMAP v0.2.4 by badb0y "
echo "Default Install PATH:/usr/local/{mysql.php.apache2}"
echo "Default mysql password:google123"
echo "Defautl web path:/usr/local/apache2/htdocs [http://localhost/info.php]"
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo ""