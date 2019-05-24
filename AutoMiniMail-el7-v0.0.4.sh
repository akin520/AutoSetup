#!/bin/bash

showmsg() {
clear
cat << "EOF"

This script is MiniMail server v0.0.4:

* Install Postfix/Dovecot CentOS7.x

Press Ctrl-C now if you want to exit

EOF
read -p "Press any key to continue..."
}
 
install() {
yum install epel-* -y
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
postconf -e 'broken_sasl_auth_clients = yes'
postconf -e 'smtpd_sasl_type = dovecot'
postconf -e 'smtpd_sasl_path = /var/spool/postfix/private/auth'
postconf -e 'smtpd_sasl_local_domain = $myhostname'
postconf -e 'smtpd_sasl_security_options = noanonymous'
postconf -e 'smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'
postconf -e 'smtpd_client_restrictions = permit_sasl_authenticated, reject'
postconf -e 'message_size_limit = 15728640'
read -p "Domain MX ip(17.17.17.1):" ip
if [[ $ip == "" ]];then
    ip="127.0.0.1"
fi
postconf -e "inet_interfaces = $ip"
postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain, mail.$mydomain'

sed -i 's/#protocols = imap pop3 lmtp/protocols = imap pop3 lmtp/g' /etc/dovecot/dovecot.conf
sed -i 's/#   mail_location = maildir\:\~\/Maildir/mail_location = maildir\:\~\/Maildir/g' /etc/dovecot/conf.d/10-mail.conf
#disabled ssl
sed -i 's/#disable_plaintext_auth = yes/disable_plaintext_auth = no/g' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/auth_mechanisms = plain/auth_mechanisms = plain login/g' /etc/dovecot/conf.d/10-auth.conf
sed -i 's/ssl = required/ssl = no/g' /etc/dovecot/conf.d/10-ssl.conf 
#postfix auth
sed -i '/Postfix smtp-auth/a\  unix_listener /var/spool/postfix/private/auth {\n    mode=06666\n    user = postfix\n    group = postfix\n  }' /etc/dovecot/conf.d/10-master.conf 

#mkdir default user dir
mkdir -p /etc/skel/Maildir
chmod 700 /etc/skel/Maildir

#alternatives --config mta
alternatives --set mta /usr/sbin/sendmail.postfix
systemctl start postfix
systemctl enable postfix

#start saslauthd
systemctl start saslauthd
systemctl enable saslauthd

#start dovecot
systemctl start dovecot
systemctl enable dovecot
}


showmsg
install
config