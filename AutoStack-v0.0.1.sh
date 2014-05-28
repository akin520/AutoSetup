#!/bin/bash
clear
echo "========================================================================="
echo "Welcome to AutoStack (OpenStack Essex All in one)"
echo ""
echo ""
echo "AutoStack v0.0.1 by badb0y"
echo ""
echo "Default dashboard web [http://localhost/]"
echo "Default user:admin password:chenshake"
echo ""
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo ""

read -p "If the OK! Press any key to start..."

######################################
export LOCAL_IP=192.168.14.114
export PUBLIC_IF='eth0'
export PRIVATE_IF='eth1'
export BRIDGE_IF='br100'
export FIXED_RANGE='192.168.17.0/24'
export FIXED_RANGE_PRE='$(echo ${FIXED_RANGE}|cut -d. -f1-3)'
export FLOATING_IP='192.168.14.20/27'

######################################

check(){
    if [[ $1 -ne 0 ]]; then
        echo -e "\033[40;31mFail: $2\033[0m"
        #echo -e "\033[40;31m$3\033[0m"
        exit
    else
        echo -e "\033[40;32mPASS $2\033[0m"
        fi
    sleep 2
}

quickcheck(){
    if [[ $1 -ne 0 ]]; then
        echo -e "\033[40;31mFail: $1\033[0m"
        exit
    else
        echo -e "\033[40;32mPASS $1\033[0m"
    fi
}

#check use
checkid(){
    cid=`id -u`
    if [[ $cid != "0" ]]; then
        echo -e "\033[40;31m Warning: You must be root to run this script!\033[0m"
        exit
    fi
}

#update system
update(){
    sudo sed -i.bak 's#http://us.archive.ubuntu.com/#http://mirrors.163.com/#g' /etc/apt/sources.list
    apt-get update && apt-get -y dist-upgrade
    RETVAL=$?
    check $RETVAL "Update system!"
}

#NTP service
ntp(){
    apt-get install -y ntp
    RETVAL=$?
    check $RETVAL "Install NTP!"
    cp /etc/ntp.conf /root/

cat >/etc/ntp.conf<<EOF
restrict default ignore
restrict 127.0.0.1
restrict 192.168.14.0 mask 255.255.255.0 nomodify notrap
server ntp.api.bz
server 127.127.1.0
fudge 127.127.1.0 stratum 10
keys /etc/ntp/keys
EOF

    RETVAL=$?
    check $RETVAL "CONFIG NTP!"
    /etc/init.d/ntp restart
    ntpq -p
}

#ISCSI nova-volume & bridge
iscsi(){
    #apt-get -y install tgt
    apt-get install -y tgt open-iscsi open-iscsi-utils bridge-utils
    RETVAL=$?
    check $RETVAL "Install ISCSI!!"

#setting eth1
cat >>/etc/network/interfaces<<IEOF

auto eth1
iface eth1 inet manual
up ifconfig eth1 up
IEOF

    /etc/init.d/networking restart
    RETVAL=$?
    check $RETVAL "Netork Restart!!"
}

#install mq & memcache & kvm
mq(){
    apt-get install -y rabbitmq-server memcached python-memcache kvm libvirt-bin
    RETVAL=$?
    check $RETVAL "Install Rabbitmq Memcached and KVM!!!"
}

mysqlinstall(){
cat << MYSQL_PASSWORD | debconf-set-selections
mysql-server-5.5 mysql-server/root_password password root
mysql-server-5.5 mysql-server/root_password_again password root
MYSQL_PASSWORD
    apt-get install -y mysql-server python-mysqldb
    RETVAL=$?
    check $RETVAL "Install MYSQL!!"

    #config mysql
    if [ ! -f /etc/mysql/I.lock ]; then
        sed -i.bak 's#127.0.0.1#0.0.0.0#g' /etc/mysql/my.cnf
        /etc/init.d/mysql restart
        RETVAL=$?
        check $RETVAL "Restart MYSQL!!"
        mysql -uroot -proot -e "grant all on *.* to root@'%' identified by 'root';"
        mysql -uroot -proot -e 'flush privileges;'
        RETVAL=$?
        check $RETVAL "MYSQL Password Change!!"
        touch /etc/mysql/I.lock
    fi
}

keystoneinstall(){
    apt-get install -y keystone python-keystone python-mysqldb python-keystoneclient
    check $RETVAL "Install Keysone!!"

    #config keystone
    if [ ! -f /etc/keystone/I.lock ]; then
        sed -i 's#admin_token = ADMIN#admin_token = chenshake#g' /etc/keystone/keystone.conf
        sed -i "s#connection = sqlite:////var/lib/keystone/keystone.db#connection = mysql://root:root@$LOCAL_IP/keystone#g" /etc/keystone/keystone.conf 
        #sed -i '/\[catalog\]/{n;d}' /etc/keystone/keystone.conf
        #sed -i '/\[catalog\]/a driver = keystone.catalog.backends.templated.TemplatedCatalog\ntemplate_file = /etc/keystone/default_catalog.templates'  /etc/keystone/keystone.conf

        mysql -uroot -proot -e "CREATE DATABASE keystone;"
        RETVAL=$?
        check $RETVAL "keystone Database Create!!"
        service keystone restart && service keystone restart
        RETVAL=$?
        check $RETVAL "Keystone Service Resatrt!!"
        keystone-manage db_sync && keystone-manage db_sync
        RETVAL=$?
        check $RETVAL "Keystone DB_SYSNC!!"

        wget http://autosetup1.googlecode.com/files/keystone_data.sh
        chmod +x keystone_data.sh
        source keystone_data.sh
        RETVAL=$?
        check $RETVAL "Keystone_data Add!!"

        wget http://autosetup1.googlecode.com/files/endpoints.sh
        chmod +x endpoints.sh
        ./endpoints.sh -m $LOCAL_IP -u root -D keystone -p root -T chenshake -K $LOCAL_IP -R RegionOne -E "http://localhost:35357/v2.0" -S $LOCAL_IP
        RETVAL=$?
        check $RETVAL "Endpoints Add!!"
        touch /etc/keystone/I.lock
    fi
}

glanceinstall(){
    apt-get install -y glance glance-api glance-client glance-common glance-registry python-glance
    check $RETVAL "Install Glance!!"

#config glance
    if [ ! -f /etc/glance/I.lock ]; then

n=3;sed -i '1{:a;N;'$n'!b a};$d;N;P;D' /etc/glance/glance-api-paste.ini
n=3;sed -i '1{:a;N;'$n'!b a};$d;N;P;D' /etc/glance/glance-registry-paste.ini

cat >>/etc/glance/glance-api-paste.ini<<GEOF
admin_tenant_name = service
admin_user = glance
admin_password = chenshake
GEOF

cat >>/etc/glance/glance-registry-paste.ini<<GEOF
admin_tenant_name = service
admin_user = glance
admin_password = chenshake
GEOF

cat >>/etc/glance/glance-registry.conf<<GEOF
[paste_deploy]
flavor = keystone
GEOF

cat >>/etc/glance/glance-api.conf<<GEOF
[paste_deploy]
flavor = keystone
GEOF
        mysql -uroot -proot -e "CREATE DATABASE glance;"
        RETVAL=$?
        check $RETVAL "glance Database Create!!"
        sed -i "s#sql_connection = sqlite:////var/lib/glance/glance.sqlite#sql_connection = mysql://root:root@$LOCAL_IP/glance#g"  /etc/glance/glance-registry.conf

        glance-manage version_control 0 && glance-manage db_sync
        RETVAL=$?
        check $RETVAL "Glance DB_SYSNC!!"
        service glance-api restart && service glance-registry restart
        RETVAL=$?
        check $RETVAL "Glane Service Restart!!"
        echo 'export OS_TENANT_NAME=admin' >>/etc/profile
        echo 'export OS_USERNAME=admin' >>/etc/profile
        echo 'export OS_PASSWORD=chenshake' >>/etc/profile
        echo 'export OS_AUTH_URL=http://localhost:5000/v2.0/' >>/etc/profile
        source /etc/profile
        glance index
        RETVAL=$?
        check $RETVAL "Glane Index!!"
        touch /etc/glance/I.lock
        fi
}

novainstall(){
    apt-get install -y nova-api nova-cert nova-common nova-compute nova-compute-kvm nova-doc nova-network nova-objectstore nova-scheduler nova-volume nova-consoleauth novnc python-nova python-novaclient
    RETVAL=$?
    check $RETVAL "Install Nova!!"

#config test images nova-volume
if [ ! -f /srv/nova-volumes.img ]; then
dd if=/dev/zero of=/srv/nova-volumes.img bs=1M seek=1000 count=0
losetup -f /srv/nova-volumes.img
losetup -a
vgcreate nova-volumes /dev/loop0
RETVAL=$?
check $RETVAL "Nova-volume Images Files!!"
fi


#config nova.conf
if [ ! -f /etc/nova/I.lock ]; then
n=3;sed -i '1{:a;N;'$n'!b a};$d;N;P;D' /etc/nova/api-paste.ini

cat >>/etc/nova/api-paste.ini<<NEOF
admin_tenant_name = service
admin_user = nova
admin_password = chenshake
NEOF

cp /etc/nova/nova.conf ./

mysql -uroot -proot -e "CREATE DATABASE nova;"
RETVAL=$?
check $RETVAL "nova Database Create!!"

cat >/etc/nova/nova.conf<<NEOF
[DEFAULT]
###### LOGS/STATE
#verbose=True
verbose=False

###### AUTHENTICATION
auth_strategy=keystone

###### SCHEDULER
#--compute_scheduler_driver=nova.scheduler.filter_scheduler.FilterScheduler
scheduler_driver=nova.scheduler.simple.SimpleScheduler

###### VOLUMES
volume_group=nova-volumes
volume_name_template=volume-%08x
iscsi_helper=tgtadm
iscsi_ip_prefix=$FIXED_RANGE_RPE

###### DATABASE
sql_connection=mysql://root:root@$LOCAL_IP/nova

###### COMPUTE
libvirt_type=kvm
#libvirt_type=qemu
connection_type=libvirt
instance_name_template=instance-%08x
api_paste_config=/etc/nova/api-paste.ini
allow_resize_to_same_host=True
libvirt_use_virtio_for_bridges=true
start_guests_on_host_boot=true
resume_guests_state_on_host_boot=true

###### APIS
osapi_compute_extension=nova.api.openstack.compute.contrib.standard_extensions
allow_admin_api=true
s3_host=$LOCAL_IP
cc_host=$LOCAL_IP

###### RABBITMQ
rabbit_host=$LOCAL_IP

###### GLANCE
image_service=nova.image.glance.GlanceImageService
glance_api_servers=$LOCAL_IP:9292

###### NETWORK
network_manager=nova.network.manager.FlatDHCPManager
force_dhcp_release=True
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
public_interface=$PUBLIC_IF
flat_interface=$PRIVATE_IF
flat_network_bridge=$BRIDGE_IF
fixed_range=$FIXED_RANGE
my_ip=$LOCAL_IP
routing_source_ip=$LOCAL_IP
multi_host=true

###### NOVNC CONSOLE
novnc_enabled=true
novncproxy_base_url= http://$LOCAL_IP:6080/vnc_auto.html
vncserver_proxyclient_address=$LOCAL_IP
vncserver_listen=$LOCAL_IP

########Nova
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova

#####MISC
use_deprecated_auth=false
root_helper=sudo nova-rootwrap
NEOF

echo '#!/bin/bash' >/bin/allr.sh
echo 'for a in libvirt-bin nova-network nova-cert nova-compute nova-api nova-objectstore nova-scheduler nova-volume novnc nova-consoleauth; do service "$a" stop; done' >>/bin/allr.sh
echo 'for a in libvirt-bin nova-network nova-cert nova-compute nova-api nova-objectstore nova-scheduler nova-volume novnc  nova-consoleauth; do service "$a" start; done' >>/bin/allr.sh
chmod +x /bin/allr.sh
/bin/allr.sh

nova-manage db sync
RETVAL=$?
check $RETVAL "Nova DB Sync!!"
chown -R nova:nova /etc/nova

nova-manage network create private --fixed_range_v4=$FIXED_RANGE --num_networks=1 --bridge=$BRIDGE_IF --bridge_interface=$PRIVATE_IF --network_size=256 --multi_host=T
RETVAL=$?
check $RETVAL "Create Fix IP!!"

nova-manage floating create --ip_range=$FLOATING_IP
RETVAL=$?
check $RETVAL "Create Floating IP!!"
touch /etc/nova/I.lock
fi
}

dashboard(){
    apt-get install -y apache2 libapache2-mod-wsgi openstack-dashboard
    RETVAL=$?
    check $RETVAL "Openstack-dashboard Install!!"

mysql -uroot -proot -e "CREATE DATABASE horizon;"
RETVAL=$?
check $RETVAL "horizon Database Create!!"

#config dashboard
if [ ! -f /etc/openstack-dashboard/I.lock ]; then
cat >>/etc/openstack-dashboard/local_settings.py<<DEOF
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'horizon',
        'USER': 'root',
        'PASSWORD': 'root',
        'HOST': '127.0.0.1',
        'default-character-set': 'utf8'
    },
}
DEOF

/usr/share/openstack-dashboard/manage.py syncdb
RETVAL=$?
check $RETVAL "Openstack-dashboard DB Sync!!"
/bin/allr.sh
touch /etc/openstack-dashboard/I.lock
fi
}

img(){
    wget https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img
    glance add name=cirros-0.3.0-x86_64 is_public=true  container_format=bare disk_format=qcow2 < /root/cirros-0.3.0-x86_64-disk.img
    RETVAL=$?
    check $RETVAL "Glance Add cirros System!!"
}


main(){
    checkid
    update
    ntp
    iscsi
    mq
    mysqlinstall
    keystoneinstall
    glanceinstall
    novainstall
    dashboard
    img
}

main

clear
echo "========================================================================="
echo "Welcome to AutoStack (OpenStack Essex All in one)"
echo ""
echo ""
echo "AutoStack v0.0.1 by badb0y"
echo ""
echo "Default dashboard web [http://$LOCAL_IP]"
echo "Default user:admin password:chenshake"
echo ""
echo "========================================================================="
echo ""
echo "For more information please visit http://code.google.com/p/autosetup/"
echo ""
