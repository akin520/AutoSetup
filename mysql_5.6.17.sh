#!/bin/bash
clear
echo "========================================================================="
echo ""
echo "Mysql for Centos6.x Install scripts "
echo "Default Install PATH:/usr/local/mysql"
echo "Default mysql default password:google123"
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/ or https://github.com/akin520"
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
yum -y install unzip wget cmake bison bison-devel patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
yum install axel -y
}

download() {
echo "Download soft..."
if [ ! -s mysql-5.6.17.tar.gz ]; then
axel -n 10 http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.17.tar.gz
fi
if [ -s /etc/my.cnf ]; then
mv /etc/my.cnf /etc/my.cnf.auto
fi
if [ -s /etc/init.d/mysql ]; then
mv /etc/init.d/mysql /etc/init.d/mysql.auto
fi
}

install(){
useradd mysql
tar -zxvf mysql-5.6.17.tar.gz
cd mysql-5.6.17
mkdir -p source_downloads
cd source_downloads
axel -n 5 http://sourceforge.net/projects/autosetup/files/soft/gmock-1.6.0.zip
unzip gmock-1.6.0.zip
cd gmock-1.6.0
./configure
make
cd ../..

cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DSYSCONFDIR=/etc -DMYSQL_UNIX_ADDR=/tmp/mysqld.sock -DDEFAULT_CHARSET=utf8  -DDEFAULT_COLLATION=utf8_general_ci -DEXTRA_CHARSETS=all -DWITH_SSL=bundled -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DENABLE_DOWNLOADS=1
make && make install
cp support-files/my-default.cnf /etc/my.cnf
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
}

end() {
clear
echo ""
echo ""
echo "Run Script: /etc/init.d/mysql {start|stop|restart}"
echo "datadir /usr/local/mysql/data"
echo ""
echo ""
}

main() {

	echo "Installtion MYSQL..."
	base
	download
	install
	end
}

main

