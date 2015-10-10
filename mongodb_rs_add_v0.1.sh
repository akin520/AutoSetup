#!/bin/bash

MONGODB_HOME=/opt/mongodb/bin

rs() {
#data
mkdir -p /work/mongodb/shard$1
cat > /work/mongodb/shard$1.conf <<EOF
shardsvr=true
replSet=$2
port=$1
dbpath=/work/mongodb/shard$1
oplogSize=2048
logpath=/work/mongodb/shard$1.log
logappend=true
fork=true
nojournal=true
EOF

#run
cat > /root/mongo$1.sh <<EOF
#!/bin/bash
case "\$1" in
start)
  $MONGODB_HOME/mongod --config /work/mongodb/shard$1.conf
  ;;
stop)
  kill \$(cat /work/mongodb/shard$1/mongod.lock)
  ;;
 *)
  echo $"Usage:"\$0" {start|stop}"
  ;;
esac
EOF
chmod +x /root/mongo$1.sh
}

if [[ $# -eq 2 ]];then
  rs $1 $2
  echo "rs service add"
else
  echo $"Usage:"$0" port replSet"
fi
