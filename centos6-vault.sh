#!/bin/bash
version=`cat /etc/redhat-release |awk '{printf $3}'`
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
cat >/etc/yum.repos.d/CentOS-Base.repo<<EOF
[centos-vault]
name=centos-vault
failovermethod=priority
baseurl=https://vault.centos.org/$version/os/x86_64/
gpgcheck=1
gpgkey=https://vault.centos.org/$version/os/x86_64/RPM-GPG-KEY-CentOS-6
EOF

