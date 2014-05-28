#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoSNMP (net-snmp)"
echo ""
echo ""
echo "AutoSNMP v0.0.2 by badb0y "
echo "Default  community name:google"
echo ""
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo ""
export LANC=C

read -p "If the OK! Press any key to start..."

cat /etc/redhat-release |grep CentOS 2>&1 >/dev/null
if [ $? -ne 0 ];then
echo "OS no CentOS!"
exit 1
fi
yum install net-snmp* -y
if [ -f /etc/snmp/snmpd.conf ];then
rm -rf /etc/snmp/snmpd.conf
rm -rf /etc/sysconfig/snmpd.options
wget http://autosetup1.googlecode.com/files/snmpd.options -O /etc/sysconfig/snmpd.options
wget http://autosetup1.googlecode.com/files/snmpd.conf -O /etc/snmp/snmpd.conf
fi
chkconfig snmpd on
service snmpd start

clear
echo "========================================================================="
echo "Welcome to AutoSNMP (net-snmp)"
echo ""
echo ""
echo "AutoSNMP v0.0.2 by badb0y "
echo "Default  community name:google"
echo ""
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo ""

