#!/bin/bash

showmsg() {
clear
cat << "EOF"

This script is ExtMail server v0.0.4:

* Install Postfix/courier-imap CentOS7.x x86_64:
* Install WebMail(extmail&extman)

Press Ctrl-C now if you want to exit

EOF
read -p "Press any key to continue..."
}
 
baseamp() {
  yum install epel-* nss-devel -y
  #mysql
  mv /etc/my.cnf /etc/my.cnf`date +%Y%m%d%H`
  yum install -y https://repo.percona.com/yum/percona-release-latest.noarch.rpm
  yum install -y Percona-Server-server-56
  sed -i 's/^sql_mode/#sql_mode/g' /etc/my.cnf
  systemctl start mysqld
  systemctl enable mysqld
  yum -y install lsof wget httpd php php-mysql httpd-manual mod_ssl mod_perl mod_auth_mysql php-mcrypt php-gd php-adodb php-xml php-mbstring php-ldap php-pear php-xmlrpc libtool-ltdl libtool-ltdl-devel mysql-connector-odbc mysql-devel libdbi-dbd-mysql
  yum install -y m4 gcc gcc-c++ openssl openssl-devel db4-devel ntpdate bzip2 php-mysql cyrus-sasl-md5 perl-GD perl-DBD-MySQL perl-GD perl-CPAN perl-CGI perl-CGI-Session cyrus-sasl-lib cyrus-sasl-plain cyrus-sasl cyrus-sasl-devel libtool-ltdl-devel telnet mail libicu-devel
  systemctl start httpd
  systemctl enable httpd
  systemctl stop firewalld
  systemctl disable firewalld
}

postfixinstall(){
  yum remove postfix -y
  userdel postfix
  groupdel postdrop
  groupadd -g 5000 postfix
  useradd -g postfix -u 5000 -s /sbin/nologin -M postfix
  groupadd -g 5001 postdrop
  useradd -g postdrop -u 5001 -s /sbin/nologin -M postdrop
  groupadd -g 1000 vgroup
  useradd -g vgroup -u 1000 -s /sbin/nologin -M vuser
  mkdir -p /home/domains
  chown -R vuser:vgroup /home/domains
  cd /tmp
  wget ftp://ftp.cuhk.edu.hk/pub/packages/mail-server/postfix/official/postfix-3.3.2.tar.gz
  tar xf postfix-3.3.2.tar.gz
  cd postfix-3.3.2
  make makefiles 'CCARGS=-DHAS_MYSQL -I/usr/include/mysql -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl -DUSE_TLS ' \
'AUXLIBS=-L/usr/lib64/mysql -lmysqlclient -lz -lrt -lm -L/usr/lib64/sasl2 -lsasl2   -lssl -lcrypto'
  make && make install
  chown -R postfix:postdrop /var/spool/postfix
  chown -R postfix:postdrop /var/lib/postfix/
  chown root /var/spool/postfix
  chown -R root /var/spool/postfix/pid

  #configure postfix
  postconf -n > /etc/postfix/main2.cf
  mv /etc/postfix/main.cf /etc/postfix/main.cf.old
  mv /etc/postfix/main2.cf /etc/postfix/main.cf

  postfix start
  #configure main.cf
  echo '#hostname' >>/etc/postfix/main.cf
  postconf -e 'mynetworks = 127.0.0.1'
  postconf -e "myhostname = `hostname`"
  postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain, mail.$mydomain'
  echo '# banner' >>/etc/postfix/main.cf
  postconf -e 'mail_name = Postfix - by AutoMail'
  postconf -e 'smtpd_banner = $myhostname ESMTP $mail_name'
  echo '# response immediately' >>/etc/postfix/main.cf
  postconf -e 'smtpd_error_sleep_time = 0s'
  echo '# Message and return code control' >>/etc/postfix/main.cf
  postconf -e 'message_size_limit = 5242880'
  postconf -e 'mailbox_size_limit = 5242880'
  postconf -e 'show_user_unknown_table_name = no'
  echo '# Queue lifetime control' >>/etc/postfix/main.cf
  postconf -e 'bounce_queue_lifetime = 1d'
  postconf -e 'maximal_queue_lifetime = 1d'
  postconf -e "alias_maps = hash:/etc/aliases"
}

dovecotinstall(){
  yum install -y dovecot dovecot-mysql
  sed -i 's/#protocols = imap pop3 lmtp/protocols = imap pop3 lmtp/g' /etc/dovecot/dovecot.conf
cat >> /etc/dovecot/dovecot.conf <<DEOF
listen = *
base_dir = /var/run/dovecot/
DEOF
sed -i 's/#   mail_location = maildir\:\~\/Maildir/mail_location = maildir\:\~\/Maildir/g' /etc/dovecot/conf.d/10-mail.conf
sed -i 's@#mail_location =@mail_location = maildir:/home/domains/%d/%n/Maildir@g' /etc/dovecot/conf.d/10-mail.conf
sed -i 's@#mail_privileged_group =@mail_privileged_group = mail@g' /etc/dovecot/conf.d/10-mail.conf
#disabled ssl
sed -i 's/#disable_plaintext_auth = yes/disable_plaintext_auth = no/g' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/auth_mechanisms = plain/auth_mechanisms = plain login/g' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/ssl = required/ssl = no/g' /etc/dovecot/conf.d/10-ssl.conf 
cat >>/etc/dovecot/conf.d/10-logging.conf<<LEOF
log_path = /var/log/dovecot.log
info_log_path = /var/log/dovecot.info
log_timestamp = "%Y-%m-%d %H:%M:%S"
LEOF
cat >/etc/dovecot/conf.d/auth-sql.conf <<AEOF
passdb {  
  driver = sql  
  # Path for SQL configuration file, see example-config/dovecot-sql.conf.ext  
  args = /etc/dovecot/dovecot-mysql.conf
}
userdb {  
  driver = sql  
  args = /etc/dovecot/dovecot-mysql.conf
}
AEOF
cat >/etc/dovecot/dovecot-mysql.conf<<DEOF
driver = mysql
connect = host=localhost dbname=extmail user=extmail password=extmail
default_pass_scheme = CRYPT
password_query = SELECT username AS user,password AS password FROM mailbox WHERE username = '%u'
user_query = SELECT maildir, uidnumber AS uid, gidnumber AS gid FROM mailbox WHERE username = '%u'
DEOF
}



courier(){
  cd /tmp
  wget --no-check-certificate https://sourceforge.net/projects/courier/files/courier-unicode/1.2/courier-unicode-1.2.tar.bz2
  tar xf courier-unicode-1.2.tar.bz2 
  cd courier-unicode-1.2
  ./configure
  make && make install
  cd ..
  wget --no-check-certificate https://sourceforge.net/projects/courier/files/authlib/0.66.2/courier-authlib-0.66.2.tar.bz2 
  tar xf courier-authlib-0.66.2.tar.bz2 && cd courier-authlib-0.66.2
./configure \
--prefix=/usr/local/courier-authlib \
    --sysconfdir=/etc \
  --without-authpam \
  --without-authshadow \
  --without-authvchkpw \
  --without-authpgsql \
  --with-authmysql \
  --with-mysql-libs=/usr/lib64/mysql \
  --with-mysql-includes=/usr/include/mysql \
  --with-redhat \
  --with-authmysqlrc=/etc/authmysqlrc \
  --with-authdaemonrc=/etc/authdaemonrc \
  --with-mailuser=postfix
  make && make install  
  wget --no-check-certificate https://raw.githubusercontent.com/akin520/autosetup1/master/authmysqlrc -O /etc/authmysqlrc
  wget --no-check-certificate https://raw.githubusercontent.com/akin520/autosetup1/master/authdaemonrc -O /etc/authdaemonrc
  mkdir -p /var/spool/authdaemon
  chmod 755 /var/spool/authdaemon/
  cp courier-authlib.sysvinit /etc/init.d/courier-authlib
  chmod +x /etc/init.d/courier-authlib
  echo "/usr/local/courier-authlib/lib/courier-authlib" >> /etc/ld.so.conf.d/courier-authlib.conf
  /etc/init.d/courier-authlib start
  chkconfig courier-authlib on
}



saslinstall(){
cat >>/etc/postfix/main.cf<<PEOF

# smtpd related config
smtpd_recipient_restrictions =
        permit_mynetworks,
        permit_sasl_authenticated,
        reject_non_fqdn_hostname,
        reject_non_fqdn_sender,
        reject_non_fqdn_recipient,
        reject_unauth_destination,
        reject_unauth_pipelining,
        reject_invalid_hostname,

# SMTP sender login matching config
smtpd_sender_restrictions =
        permit_mynetworks,
        reject_sender_login_mismatch,
        reject_authenticated_sender_login_mismatch,
        reject_unauthenticated_sender_login_mismatch

smtpd_sender_login_maps =
        mysql:/etc/postfix/mysql_virtual_sender_maps.cf,
        mysql:/etc/postfix/mysql_virtual_alias_maps.cf
  
# SMTP AUTH config here
broken_sasl_auth_clients = yes
smtpd_sasl_auth_enable = yes
smtpd_sasl_local_domain = $myhostname
smtpd_sasl_security_options = noanonymous
PEOF

cat >/usr/lib64/sasl2/smtpd.conf<<SEOF
pwcheck_method: authdaemond
log_level: 3
mech_list: PLAIN LOGIN
authdaemond_path: /usr/local/courier-authlib/var/spool/authdaemon/socket 
SEOF
  #
  postfix restart
}



extinstall(){
#confgiure httpd
cat >>/etc/httpd/conf/httpd.conf<<HEOF
NameVirtualHost *:80
Include conf/vhost_*.conf
HEOF

cat >/etc/httpd/conf/vhost_automail.conf<<HEOF
# VirtualHost for ExtMail Solution
<VirtualHost *:80>
ServerName mail.extmail.org
DocumentRoot /var/www/extsuite/extmail/html/

ScriptAlias /extmail/cgi/ /var/www/extsuite/extmail/cgi/
Alias /extmail /var/www/extsuite/extmail/html/

ScriptAlias /extman/cgi/ /var/www/extsuite/extman/cgi/
Alias /extman /var/www/extsuite/extman/html/

# Suexec config
SuexecUserGroup vuser vgroup
</VirtualHost>
HEOF

#install extmail
cd /tmp
wget --no-check-certificate https://raw.githubusercontent.com/akin520/autosetup1/master/extmail-1.2.tar.gz
yum -y install perl-DBD-mysql perl-ExtUtils-MakeMaker perl-Unix-Syslog rrdtool-perl perl-File-Tail perl-Time-HiRes
mkdir -p /var/www/extsuite
tar xf extmail-1.2.tar.gz -C /var/www/extsuite/
mv /var/www/extsuite/extmail-1.2/ /var/www/extsuite/extmail
cd cd /var/www/extsuite/extmail/cgi/
sed -i 's/wT/w/g' *.cgi
cd /var/www/extsuite/extmail
cp webmail.cf.default webmail.cf
#configure webmail.cf
sed -i 's#SYS_MYSQL_USER = db_user#SYS_MYSQL_USER = extmail#g' webmail.cf
sed -i 's#SYS_MYSQL_PASS = db_pass#SYS_MYSQL_PASS = extmail#g' webmail.cf
sed -i 's#SYS_AUTHLIB_SOCKET = /var/spool/authdaemon/socket#SYS_AUTHLIB_SOCKET = /usr/local/courier-authlib/var/spool/authdaemon/socket#g' webmail.cf
chown -R vuser:vgroup /var/www/extsuite/extmail/cgi/



#install extman
cd /tmp
wget --no-check-certificate https://raw.githubusercontent.com/akin520/autosetup1/master/extman-1.1.tar.gz
tar xf extman-1.1.tar.gz -C /var/www/extsuite/
cd /var/www/extsuite/
mv extman-1.1/ extman
chown -R vuser:vgroup /var/www/extsuite/extman/cgi/
mkdir -p /var/www/extsuite/extman/tmp
chown -R vuser:vgroup /var/www/extsuite/extman/tmp
cd /var/www/extsuite/extman
cp webman.cf.default webman.cf
sed -i 's#SYS_SESS_DIR = /tmp/extman/#SYS_SESS_DIR = /var/www/extsuite/extman/tmp/#g' /var/www/extsuite/extman/webman.cf
#close Verification code
sed -i 's/SYS_CAPTCHA_ON = 1/SYS_CAPTCHA_ON = 0/g' /var/www/extsuite/extman/webman.cf
sed -i 's#SYS_CMDSERVER_SOCK = /tmp/cmdserver.sock#SYS_CMDSERVER_SOCK = /var/run/extmail/cmdserver.sock#g' /var/www/extsuite/extman/webman.cf
#add mysql user
mysql -uroot -e 'GRANT ALL ON extmail.* TO extmail@'localhost' IDENTIFIED BY "extmail";'
mysql -uroot -e 'GRANT ALL ON extmail.* TO webman@'localhost' IDENTIFIED BY "webman";'

mysql -uroot -e 'flush privileges;'

#configure postfix mysql
sed  -i  's/TYPE=MyISAM/ENGINE=MyISAM/' /var/www/extsuite/extman/docs/extmail.sql
sed -i '25,45d' /var/www/extsuite/extman/docs/extmail.sql
mysql -u root < /var/www/extsuite/extman/docs/extmail.sql
mysql -u root < /var/www/extsuite/extman/docs/init.sql
cd /var/www/extsuite/extman/docs
cp mysql_virtual_alias_maps.cf /etc/postfix/
cp mysql_virtual_domains_maps.cf /etc/postfix/
cp mysql_virtual_mailbox_maps.cf /etc/postfix/
cp mysql_virtual_sender_maps.cf /etc/postfix/
#configure postfix main.cf
echo '# extmail config here' >>/etc/postfix/main.cf
postconf -e "virtual_mailbox_base = /home/domains"
postconf -e 'virtual_alias_maps = mysql:/etc/postfix/mysql_virtual_alias_maps.cf'
postconf -e 'virtual_mailbox_domains = mysql:/etc/postfix/mysql_virtual_domains_maps.cf'
postconf -e 'virtual_mailbox_maps = mysql:/etc/postfix/mysql_virtual_mailbox_maps.cf'
postconf -e 'virtual_uid_maps = static:1000'
postconf -e 'virtual_gid_maps = static:1000'
postconf -e 'virtual_transport = virtual'

postfix reload
#create mail domain
cd /var/www/extsuite/extman/tools 
./maildirmake.pl /home/domains/extmail.org/postmaster/Maildir 
chown -R vuser:vgroup /home/domains/extmail.org
mkdir -p /var/run/extmail
/var/www/extsuite/extman/daemon/cmdserver --daemon
cd /var/www/extsuite/extman/addon
cp -a mailgraph_ext /usr/local/
/usr/local/mailgraph_ext/mailgraph-init start
#add rc.local
echo "/usr/local/mailgraph_ext/mailgraph-init start" >> /etc/rc.local
echo "/var/www/extsuite/extman/daemon/cmdserver --daemon" >>/etc/rc.local
chmod +x /etc/rc.d/rc.local
chown -R vuser:vgroup /var/www/extsuite
}

showend(){
/etc/init.d/httpd restart
postfix reload
/etc/init.d/courier-authlib restart
clear
cat << "EOF"


This script is ExtMail server v0.0.3:

* Install Postfix/courier-imap CentOS6.x
* Mysql:[root:null] [extmail:extmail]
* Authtest:/usr/sbin/authtest -s login postmaster@extmail.org extmail
* Test doc:http://github.com/akin520/AutoSetup
* Extmail:http://0.0.0.0/extmail/ [u:postmaster p:extmail d:extmail.org]
* Extman:http://0.0.0.0/extman/  [u:root@extmail.org p:extmail*123* d:extmail.org]


EOF
}

main(){
if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi
showmsg
baseamp
postfixinstall
dovecotinstall
courier
saslinstall
extinstall
showend
}

main