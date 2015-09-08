#!/bin/bash

MONGODB_HOME=/opt/mongodb/bin

host(){
grep -E "(mongohost1|mongohost2|mongohost3)" /etc/hosts
if [[ $? == 1 ]];then
echo '192.168.100.61    mongohost1' >>/etc/hosts
echo '192.168.100.62    mongohost2' >>/etc/hosts
echo '192.168.100.63    mongohost3' >>/etc/hosts
echo "host add!"
else
echo "host have!"
fi
}

node1() {
#data
mkdir -p /work/mongodb/{shard11,shard21}
cat > /work/mongodb/shard11.conf <<EOF
shardsvr=true
replSet=shard1
port=28017
dbpath=/work/mongodb/shard11
oplogSize=2048
logpath=/work/mongodb/shard11.log
logappend=true
fork=true
bind_ip=192.168.100.61
nojournal=true
EOF

cat > /work/mongodb/shard21.conf <<EOF
shardsvr=true
replSet=shard2
port=28018
dbpath=/work/mongodb/shard21
oplogSize=2048
logpath=/work/mongodb/shard21.log
logappend=true
fork=true
bind_ip=192.168.100.61
nojournal=true
EOF

#config
mkdir -p /work/mongodb/config/
cat > /work/mongodb/config1.conf <<EOF
configsvr=true
dbpath=/work/mongodb/config/
port=20000
logpath=/work/mongodb/config1.log
logappend=true
fork=true
bind_ip=192.168.100.61
nojournal=true
EOF

#arbiter
mkdir -p /work/mongodb/{arbiter1,arbiter2}
cat > /work/mongodb/arbiter1.conf <<EOF
shardsvr=true
replSet=shard1
port=28031
dbpath=/work/mongodb/arbiter1
oplogSize=100
logpath=/work/mongodb/arbiter1.log
logappend=true
fork=true
bind_ip=192.168.100.61
nojournal=true
EOF

cat > /work/mongodb/arbiter2.conf <<EOF
shardsvr=true
replSet=shard2
port=28032
dbpath=/work/mongodb/arbiter2
oplogSize=100
logpath=/work/mongodb/arbiter2.log
logappend=true
fork=true
bind_ip=192.168.100.61
nojournal=true
EOF

#mongos
mkdir -p /work/mongodb/mongos1
cat > /work/mongodb/mongos1.conf <<EOF
configdb=mongohost1:20000,mongohost2:20000,mongohost3:20000
port=28885
chunkSize=100
logpath=/work/mongodb/mongos1.log
logappend=true
fork=true
pidfilepath=/work/mongodb/mongos1/mongod.lock
bind_ip=192.168.100.61
EOF

#run
cat > /root/mongo.sh <<EOF
#!/bin/bash
case "\$1" in
start)
  $MONGODB_HOME/mongod --config /work/mongodb/shard11.conf
  $MONGODB_HOME/mongod --config /work/mongodb/shard21.conf
  $MONGODB_HOME/mongod --config /work/mongodb/arbiter1.conf
  $MONGODB_HOME/mongod --config /work/mongodb/arbiter2.conf
  $MONGODB_HOME/mongod --config /work/mongodb/config1.conf
  ;;
stop)
  kill \$(cat /work/mongodb/shard11/mongod.lock)
  kill \$(cat /work/mongodb/shard21/mongod.lock)
  kill \$(cat /work/mongodb/arbiter1/mongod.lock)
  kill \$(cat /work/mongodb/arbiter2/mongod.lock)
  kill \$(cat /work/mongodb/config/mongod.lock)
  ;;
 *)
  echo $"Usage:"\$0" {start|stop}"
  ;;
esac
EOF
cat > /root/mongos.sh <<EOF
#!/bin/bash
case "\$1" in
start)
  $MONGODB_HOME/mongos --config /work/mongodb/mongos1.conf
  ;;
stop)
  kill \$(cat /work/mongodb/mongos1/mongod.lock)
  ;;
 *)
  echo $"Usage:"\$0" {start|stop}"
  ;;
esac
EOF
chmod +x /root/mongo.sh /root/mongos.sh
}

node2() {
mkdir -p /work/mongodb/{shard12,shard22}
cat > /work/mongodb/shard12.conf <<EOF
shardsvr=true
replSet=shard1
port=28017
dbpath=/work/mongodb/shard12
oplogSize=2048
logpath=/work/mongodb/shard12.log
logappend=true
fork=true
bind_ip=192.168.100.62
nojournal=true
EOF

cat > /work/mongodb/shard22.conf <<EOF
shardsvr=true
replSet=shard2
port=28018
dbpath=/work/mongodb/shard22
oplogSize=2048
logpath=/work/mongodb/shard22.log
logappend=true
fork=true
bind_ip=192.168.100.62
nojournal=true
EOF

mkdir -p /work/mongodb/config/
cat > /work/mongodb/config2.conf <<EOF
configsvr=true
dbpath=/work/mongodb/config/
port=20000
logpath=/work/mongodb/config2.log
logappend=true
fork=true
bind_ip=192.168.100.62
nojournal = true
EOF

mkdir -p /work/mongodb/{arbiter1,arbiter2}
cat > /work/mongodb/arbiter1.conf <<EOF
shardsvr=true
replSet=shard1
port=28031
dbpath=/work/mongodb/arbiter1
oplogSize=100
logpath=/work/mongodb/arbiter1.log
logappend=true
fork=true
bind_ip=192.168.100.62
nojournal=true
EOF

cat > /work/mongodb/arbiter2.conf <<EOF
shardsvr=true
replSet=shard2
port=28032
dbpath=/work/mongodb/arbiter2
oplogSize=100
logpath=/work/mongodb/arbiter2.log
logappend=true
fork=true
bind_ip=192.168.100.62
nojournal=true
EOF

mkdir -p /work/mongodb/mongos2
cat > /work/mongodb/mongos2.conf <<EOF
configdb=mongohost1:20000,mongohost2:20000,mongohost3:20000
port=28885
chunkSize=100
logpath=/work/mongodb/mongos2.log
logappend=true
fork=true
bind_ip=192.168.100.62
pidfilepath=/work/mongodb/mongos2/mongod.lock
EOF

#run2
cat > /root/mongo.sh <<EOF
#!/bin/bash
case "\$1" in
start)
  $MONGODB_HOME/mongod --config /work/mongodb/shard12.conf
  $MONGODB_HOME/mongod --config /work/mongodb/shard22.conf
  $MONGODB_HOME/mongod --config /work/mongodb/arbiter1.conf
  $MONGODB_HOME/mongod --config /work/mongodb/arbiter2.conf
  $MONGODB_HOME/mongod --config /work/mongodb/config2.conf
  ;;
stop)
  kill \$(cat /work/mongodb/shard12/mongod.lock)
  kill \$(cat /work/mongodb/shard22/mongod.lock)
  kill \$(cat /work/mongodb/arbiter1/mongod.lock)
  kill \$(cat /work/mongodb/arbiter2/mongod.lock)
  kill \$(cat /work/mongodb/config/mongod.lock)
  ;;
 *)
  echo $"Usage:"\$0" {start|stop}"
  ;;
esac
EOF
cat > /root/mongos.sh <<EOF
#!/bin/bash
case "\$1" in
start)
  $MONGODB_HOME/mongos --config /work/mongodb/mongos2.conf
  ;;
stop)
  kill \$(cat /work/mongodb/mongos2/mongod.lock)
  ;;
 *)
  echo $"Usage:"\$0" {start|stop}"
  ;;
esac
EOF
chmod +x /root/mongo.sh /root/mongos.sh
}

node3() {
mkdir -p /work/mongodb/{shard13,shard23}
cat > /work/mongodb/shard13.conf <<EOF
shardsvr=true
replSet=shard1
port=28017
dbpath=/work/mongodb/shard13
oplogSize=2048
logpath=/work/mongodb/shard13.log
logappend=true
fork=true
bind_ip=192.168.100.63
journal=true
EOF

cat > /work/mongodb/shard23.conf <<EOF
shardsvr=true
replSet=shard2
port=28018
dbpath=/work/mongodb/shard23
oplogSize=2048
logpath=/work/mongodb/shard23.log
logappend=true
fork=true
bind_ip=192.168.100.63
journal=true
EOF

mkdir -p /work/mongodb/config/
cat > /work/mongodb/config3.conf <<EOF
configsvr=true
dbpath=/work/mongodb/config/
port=20000
logpath=/work/mongodb/config3.log
logappend=true
fork=true
bind_ip=192.168.100.63
nojournal=true
EOF

mkdir -p /work/mongodb/{arbiter1,arbiter2}
cat > /work/mongodb/arbiter1.conf <<EOF
shardsvr=true
replSet=shard1
port=28031
dbpath=/work/mongodb/arbiter1
oplogSize=100
logpath=/work/mongodb/arbiter1.log
logappend=true
fork=true
bind_ip=192.168.100.63
nojournal=true
EOF

cat > /work/mongodb/arbiter2.conf <<EOF
shardsvr=true
replSet=shard2
port=28032
dbpath=/work/mongodb/arbiter2
oplogSize=100
logpath=/work/mongodb/arbiter2.log
logappend=true
fork=true
bind_ip=192.168.100.63
nojournal=true
EOF

mkdir -p /work/mongodb/mongos3
cat > /work/mongodb/mongos3.conf <<EOF
configdb=mongohost1:20000,mongohost2:20000,mongohost3:20000
port=28885
chunkSize=100
logpath=/work/mongodb/mongos3.log
logappend=true
fork=true
bind_ip=192.168.100.63
pidfilepath=/work/mongodb/mongos3/mongod.lock
EOF

#run3
cat > /root/mongo.sh <<EOF
#!/bin/bash
case "\$1" in
start)
  $MONGODB_HOME/mongod --config /work/mongodb/shard13.conf
  $MONGODB_HOME/mongod --config /work/mongodb/shard23.conf
  $MONGODB_HOME/mongod --config /work/mongodb/arbiter1.conf
  $MONGODB_HOME/mongod --config /work/mongodb/arbiter2.conf
  $MONGODB_HOME/mongod --config /work/mongodb/config3.conf
  ;;
stop)
  kill \$(cat /work/mongodb/shard13/mongod.lock)
  kill \$(cat /work/mongodb/shard23/mongod.lock)
  kill \$(cat /work/mongodb/arbiter1/mongod.lock)
  kill \$(cat /work/mongodb/arbiter2/mongod.lock)
  kill \$(cat /work/mongodb/config/mongod.lock)
  ;;
 *)
  echo $"Usage:"\$0" {start|stop}"
  ;;
esac
EOF
cat > /root/mongos.sh <<EOF
#!/bin/bash
case "\$1" in
start)
  $MONGODB_HOME/mongos --config /work/mongodb/mongos3.conf
  ;;
stop)
  kill \$(cat /work/mongodb/mongos3/mongod.lock)
  ;;
 *)
  echo $"Usage:"\$0" {start|stop}"
  ;;
esac
EOF
chmod +x /root/mongo.sh /root/mongos.sh
}

case "$1" in
    mongo1)
      host
      node1
      ;;
    mongo2)
      host
      node2
      ;;
    mongo3)
      host
      node3
      ;;
    *)
      echo $"Usage:"$0" {mongo1|mongo2|mongo3}"
        ;;
esac
