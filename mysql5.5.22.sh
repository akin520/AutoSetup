#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoSetup for Mysql Scripts"
echo ""
echo "Default Install PATH:/usr/local/percona"
echo "Default percona(mysql) password:google123"
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo "                            weibo http://weibo.com/badb0y"
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
}
download() {
	if [ ! -s Percona-Server-5.5.22-rel25.2.tar.gz ]; then
	wget http://www.percona.com/redir/downloads/Percona-Server-5.5/Percona-Server-5.5.22-25.2/source/Percona-Server-5.5.22-rel25.2.tar.gz
	fi
	if [ ! -s percona-xtrabackup-2.0.0-417.rhel5.x86_64.rpm ]; then
	wget http://www.percona.com/redir/downloads/XtraBackup/XtraBackup-2.0.0/RPM/rhel5/x86_64/percona-xtrabackup-2.0.0-417.rhel5.x86_64.rpm
	fi
}
mysql() {

	echo "Installation MYSQL..."
	/usr/sbin/groupadd -g 888 qygame
	/usr/sbin/useradd -g 888 -u 888 qygame
	/usr/sbin/groupadd -g 999 mysql
	/usr/sbin/useradd -g 999 -u 999 mysql
	tar -zxvf Percona-Server-5.5.22-rel25.2.tar.gz
	cd Percona-Server-5.5.22-rel25.2
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

main() {
	base
	download
	mysql
}
main
