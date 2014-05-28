#!/bin/bash

showmsg() {
clear
cat << "EOF"

This script is MiniMail server v0.0.3:

* Install Postfix/Dovecot CentOS6.x

Press Ctrl-C now if you want to exit

EOF
read -p "Press any key to continue..."
}
 
install() {
  if [ "`uname -m`" == "x86_64" ]; then
     rpm -Uhv http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
  elif [ "`uname -m`" == "i686" ]; then
      rpm -Uhv http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm    
  fi
yum install postfix dovecot cyrus-sasl* -y
}

config() {
postconf -e "myhostname = `hostname`"
read -p "MX domain(install.cn):" domain
if [[ $domain == "" ]];then
    domain=install.cn
fi
postconf -e "mydomain = $domain"
postconf -e 'myorigin = $mydomain'
postconf -e 'relay_domains = $mydestination'
postconf -e 'home_mailbox = Maildir/'
postconf -e 'smtpd_banner = $myhostname ESMTP unknow'
postconf -e 'smtpd_sasl_auth_enable = yes'
postconf -e 'smtpd_sasl_local_domain = $myhostname'
postconf -e 'smtpd_sasl_security_options = noanonymous'
postconf -e 'smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'
postconf -e 'message_size_limit = 15728640'
read -p "Domain MX ip(17.17.17.1):" ip
if [[ $ip == "" ]];then
    ip="127.0.0.1"
fi
postconf -e "inet_interfaces = $ip"
postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain, mail.$mydomain'

sed -i 's/#protocols = imap imaps pop3 pop3s/protocols = imap imaps pop3 pop3s/g' /etc/dovecot/dovecot.conf
sed -i 's/#   mail_location = maildir\:\~\/Maildir/mail_location = maildir\:\~\/Maildir/g' /etc/dovecot/dovecot.conf

#mkdir default user dir
mkdir -p /etc/skel/Maildir
chmod 700 /etc/skel/Maildir

#stop/start service
/etc/rc.d/init.d/sendmail stop
chkconfig sendmail off

#alternatives --config mta
alternatives --set mta /usr/sbin/sendmail.postfix
chkconfig postfix on
/etc/rc.d/init.d/postfix start

chkconfig saslauthd on
/etc/rc.d/init.d/saslauthd stop
/etc/rc.d/init.d/saslauthd start

chkconfig dovecot on
/etc/rc.d/init.d/dovecot start
}


showmsg
install
config