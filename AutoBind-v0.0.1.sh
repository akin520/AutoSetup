#!/bin/bash

showmsg(){
clear
cat << "EOF"

This script is BIND DNS v0.0.1:

* Install BIND9.8.1 CentOSx

Press Ctrl-C now if you want to exit

EOF

read -p "Domain(test.com):" domain
if [[ $domain == "" ]];then
    domain=test.com
fi

echo ""
echo "Domain is $domain"
echo ""
read -p "Press any key to continue..."
}

install() {
yum update openssl* -y

wget ftp://ftp.isc.org/isc/bind9/9.8.1/bind-9.8.1.tar.gz
tar -zxvf bind-9.8.1.tar.gz
cd bind-9.8.1
./configure --prefix=/usr/local/named --disable-openssl-version-check  --enable-threads
make &&make install
cd ..

#configure
/usr/local/named/sbin/rndc-confgen >/usr/local/named/etc/rndc.conf
cd /usr/local/named/etc
tail -n 10 rndc.conf|head -n9|sed -e s/#\//g >named.conf
dig >named.ca

cat >localhost.zone <<EOF
\$TTL    86400
\$ORIGIN localhost.
@           1D IN SOA   @ root (
                                42      ; serial (d. adams)
                                3H      ; refresh
                                15M     ; retry
                                1W      ; expiry
                                1D )    ; minimum

        1D      IN      NS      @
        1D      IN      A       127.0.0.1
EOF

cat >named.local <<EOF
\$TTL    86400
@       IN      SOA     localhost. root.localhost.  (
                                2011050522 ; Serial
                                3H         ; Refresh
                                15M        ; Retry
                                1W         ; Expire
                                1D )       ; Minimum
        IN      NS      localhost.
1       IN      PTR     localhost.
EOF

cat >$domain<<EOF
\$TTL    86400
@ IN SOA ns.$domain.       root.$domain. (
                                42              ; serial (d. adams)
                                3H              ; refresh
                                15M             ; retry
                                1W              ; expiry
                                1D )            ; minimum
                IN NS           ns.$domain.
                IN A            192.168.14.101
ns              IN A            192.168.14.101
cloud101        IN A            192.168.14.101
cloud102        IN A            192.168.14.102
cloud103        IN A            192.168.14.103
cloud104        IN A            192.168.14.104
EOF

cat >>named.conf<<EOF
#=========logging==================
logging {
    channel query_log {
    file "/var/log/query.log" versions 5 size 20m;
    severity info;
    print-time yes;
    print-category yes;
    };
  category queries {
    query_log;
    };
};

#=======options================
options
{
    // Those options should be used carefully because they disable port
    // randomization
    // query-source    port 53;
    // query-source-v6 port 53;

    // Put files that named is allowed to write in the data/ directory:
    directory "/usr/local/named/etc"; // the default
    dump-file           "data/cache_dump.db";
    statistics-file     "data/named_stats.txt";
    memstatistics-file  "data/named_mem_stats.txt";
    pid-file "/var/run/named/named.pid";
        #¿ªÆôµÝ¹é²éÑ¯
        recursion yes;
        allow-query-cache{ any; };
        forwarders {202.106.0.20;};
        allow-query { any; };
        allow-recursion { any; };
    version "easy-dns v0.0.1";
};

#=========configure===================
zone "." IN {
    type hint;
    file "named.ca";
};
zone "localhost" IN {
    type master;
    file "localhost.zone";
    allow-update { none; };
};
zone "0.0.127.in-addr.arpa" IN {
    type master;
    file "named.local";
    allow-update { none; };
};
zone "$domain" IN {
        type master;
        file "$domain";
        notify yes;
};
EOF

wget http://autosetup1.googlecode.com/files/dns.sh -O /root/dns.sh
chmod +x /root/dns.sh

}

showend(){
clear
cat << "EOF"

This script is BIND DNS v0.0.1:

Installend BIND9.8.1     OK
Configure BIND9.8.1      OK

If you want to modify, modify /usr/local/named/etc/"$domain" file

script:
/root/dns.sh start
/root/dns.sh stop

EOF
}

showmsg
install
showend