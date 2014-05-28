#!/bin/bash

showmsg() {
clear
cat << "EOF"

This script is ExtMail server v0.0.1:

* Install Postfix/courier-imap CentOS5.x
* Install WebMail(extmail&extman)

Press Ctrl-C now if you want to exit

EOF
read -p "Press any key to continue..."
}
 
baseamp() {
  if [ "`uname -m`" == "x86_64" ]; then
     rpm -Uhv http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
  elif [ "`uname -m`" == "i686" ]; then
      rpm -Uhv http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm    
  fi
  #add EMOS repo
  wget http://autosetup1.googlecode.com/files/EMOS-Base.repo -O /etc/yum.repos.d/EMOS-Base.repo
  yum -y install httpd php mysql mysql-server php-mysql httpd-manual mod_ssl mod_perl mod_auth_mysql php-mcrypt php-gd php-adodb php-xml php-mbstring php-ldap php-pear php-xmlrpc libtool-ltdl libtool-ltdl-devel mysql-connector-odbc mysql-devel libdbi-dbd-mysql
  chkconfig httpd on
  chkcofnig mysqld on
  /etc/init.d/mysqld restart
  /etc/init.d/httpd restart
}

postfixinstall(){
  yum --disablerepo=*  --enablerepo=EMOS-base install postfix -y
  #configure postfix
  postconf -n > /etc/postfix/main2.cf
  mv /etc/postfix/main.cf /etc/postfix/main.cf.old
  mv /etc/postfix/main2.cf /etc/postfix/main.cf
  #stop sendmail
  /etc/init.d/sendmail stop
  chkconfig sendmail off
  #change mta
  alternatives --set mta /usr/sbin/sendmail.postfix
  chkconfig postfix on
  /etc/init.d/postfix restart
  #configure main.cf
  echo '#hostname' >>/etc/postfix/main.cf
  postconf -e 'mynetworks = 127.0.0.1'
  postconf -e "myhostname = `hostname`"
  postconf -e 'mydestination = $mynetworks $myhostname'
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
}

maildropinstall(){
  yum -y --disablerepo=*  --enablerepo=EMOS-base install maildrop
  echo 'maildrop   unix        -       n        n        -        -        pipe' >>/etc/postfix/master.cf
  echo '  flags=DRhu user=vuser argv=maildrop -w 90 -d ${user}@${nexthop} ${recipient} ${user} ${extension} {nexthop}' >>/etc/postfix/master.cf
  echo '#maildrop only one' >>/etc/postfix/main.cf
  postconf -e 'maildrop_destination_recipient_limit = 1'
}


courier(){
  if [ "`uname -m`" == "x86_64" ]; then
     #wget http://www.hajo.net/pub/Linux/MyRepos/CentOS5.2/x86_64/courier-authlib-0.62.2-1.x86_64.rpm
     #wget http://www.hajo.net/pub/Linux/MyRepos/CentOS5.2/x86_64/courier-authlib-mysql-0.62.2-1.x86_64.rpm
     #wget http://www.hajo.net/pub/Linux/MyRepos/CentOS5.2/x86_64/courier-authlib-devel-0.62.2-1.x86_64.rpm
     yum remove -y courier-authlib-0.57-2hzq
     wget http://autosetup1.googlecode.com/files/courier-authlib-0.62.2-1.x86_64.rpm
     wget http://autosetup1.googlecode.com/files/courier-authlib-devel-0.62.2-1.x86_64.rpm
     wget http://autosetup1.googlecode.com/files/courier-authlib-mysql-0.62.2-1.x86_64.rpm
     rpm -Uvh courier*
     yum -y --disablerepo=*  --enablerepo=EMOS-base install maildrop
  elif [ "`uname -m`" == "i686" ]; then
     yum -y --disablerepo=*  --enablerepo=EMOS-base install courier-authlib courier-authlib-mysql courier-authlib-devel
  fi
  wget http://autosetup1.googlecode.com/files/authmysqlrc -O /etc/authlib/authmysqlrc
  wget http://autosetup1.googlecode.com/files/authdaemonrc -O /etc/authlib/authdaemonrc
  chmod 755 /var/spool/authdaemon/
}



saslinstall(){
  rpm -e cyrus-sasl --nodeps
  yum -y --disablerepo=* --enablerepo=EMOS-base install cyrus-sasl

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

if [ "`uname -m`" == "x86_64" ]; then
cat >/usr/lib64/sasl2/smtpd.conf<<SEOF
pwcheck_method: authdaemond
log_level: 3
mech_list: PLAIN LOGIN
authdaemond_path:/var/spool/authdaemon/socket
SEOF
elif [ "`uname -m`" == "i686" ]; then
cat >/usr/lib/sasl2/smtpd.conf<<SEOF
pwcheck_method: authdaemond
log_level: 3
mech_list: PLAIN LOGIN
authdaemond_path:/var/spool/authdaemon/socket
SEOF
fi

  #
  service postfix restart
}

imapinstall(){
  yum -y --disablerepo=* --enablerepo=EMOS-base install courier-imap
  #configure imap
  sed -i 's/IMAPDSTART=YES/IMAPDSTART=NO/g' /usr/lib/courier-imap/etc/imapd
  sed -i 's/IMAPDSSLSTART=YES/IMAPDSSLSTART=NO/g' /usr/lib/courier-imap/etc/imapd-ssl

  /etc/init.d/courier-imap restart
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
  yum -y --disablerepo=*  --enablerepo=EMOS-base install extsuite-webmail

cd /var/www/extsuite/extmail
cp webmail.cf.default webmail.cf
#configure webmail.cf
sed -i 's#SYS_MYSQL_USER = db_user#SYS_MYSQL_USER = extmail#g' webmail.cf
sed -i 's#SYS_MYSQL_PASS = db_pass#SYS_MYSQL_PASS = extmail#g' webmail.cf
chown -R vuser:vgroup /var/www/extsuite/extmail/cgi/

#install extman
  yum -y --disablerepo=* --enablerepo=EMOS-base install extsuite-webman

chown -R vuser:vgroup /var/www/extsuite/extman/cgi/
mkdir -p /var/www/extsuite/extman/tmp
chown -R vuser:vgroup /var/www/extsuite/extman/tmp
sed -i 's#SYS_SESS_DIR = /tmp/extman/#SYS_SESS_DIR = /var/www/extsuite/extman/tmp/#g' /var/www/extsuite/extman/webman.cf
#close Verification code
sed -i 's/SYS_CAPTCHA_ON = 1/SYS_CAPTCHA_ON = 0/g' /var/www/extsuite/extman/webman.cf
#add mysql user
mysql -uroot -e 'GRANT ALL ON *.* TO extmail@'localhost' IDENTIFIED BY "extmail";'
mysql -uroot -e 'flush privileges;'

#configure postfix mysql
mysql -u root < /var/www/extsuite/extman/docs/extmail.sql
mysql -u root < /var/www/extsuite/extman/docs/init.sql
cd /var/www/extsuite/extman/docs
cp mysql_virtual_alias_maps.cf /etc/postfix/
cp mysql_virtual_domains_maps.cf /etc/postfix/
cp mysql_virtual_mailbox_maps.cf /etc/postfix/
cp mysql_virtual_sender_maps.cf /etc/postfix/
#configure postfix main.cf
echo '# extmail config here' >>/etc/postfix/main.cf
postconf -e 'virtual_alias_maps = mysql:/etc/postfix/mysql_virtual_alias_maps.cf'
postconf -e 'virtual_mailbox_domains = mysql:/etc/postfix/mysql_virtual_domains_maps.cf'
postconf -e 'virtual_mailbox_maps = mysql:/etc/postfix/mysql_virtual_mailbox_maps.cf'
postconf -e 'virtual_transport = maildrop:'

service postfix restart
#create mail domain
cd /var/www/extsuite/extman/tools 
./maildirmake.pl /home/domains/extmail.org/postmaster/Maildir 
chown -R vuser:vgroup /home/domains/extmail.org
/usr/local/mailgraph_ext/mailgraph-init start
/var/www/extsuite/extman/daemon/cmdserver --daemon

#add rc.local
echo "/usr/local/mailgraph_ext/mailgraph-init start" >> /etc/rc.local
echo "/usr/local/mailgraph_ext/qmonitor-init start" >> /etc/rc.local
echo "/var/www/extsuite/extman/daemon/cmdserver --daemon" >>/etc/rc.local



}

showend(){
/etc/init.d/httpd restart
/etc/init.d/postfix restart
/etc/init.d/courier-authlib restart
/etc/init.d/courier-imap restart
clear
cat << "EOF"


This script is ExtMail server v0.0.1:

* Install Postfix/courier-imap CentOS5.x
* Mysql:[root:null] [extmail:extmail]
* Authtest:/usr/sbin/authtest -s login postmaster@extmail.org extmail
* Test doc:http://autosetup1.googlecode.com/files/test%20mail.txt
* Extmail:http://0.0.0.0/extmail/ [u:postmaster p:extmail d:extmail.org]
* Extman:http://0.0.0.0/extman/  [u:root@extmail.org p:extmail*123* d:extmail.org]


EOF
}

main(){
showmsg
baseamp
postfixinstall
maildropinstall
courier
saslinstall
imapinstall
extinstall
showend
}

main