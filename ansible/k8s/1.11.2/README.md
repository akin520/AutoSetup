
# k8s 1.11.2安装脚本 #


1. 下载二进制文件，分别在roles下面etcd,master,node下files里面down.sh（测试中可以使用1.12）      

2. 按顺序执行    
`ansible-playbook -i hosts 01.cert.yml       `    
`ansible-playbook -i hosts 02.etcd.yml         `    
`ansible-playbook -i hosts 03.docker.yml        `    
`ansible-playbook -i hosts 04.master.yml        `    
`ansible-playbook -i hosts 05.node.yml        `       
   
3. 添加节点    
hosts中添加    
192.168.20.214 hostname=ym214    
再执行:    
`
ansible-playbook -i hosts 05.node.yml --limit 192.168.20.214
`
  
4.升级K8S 1.11.5    
`cd roles/master/files/&& bash -x 1.11.5.sh    `
`ansible-playbook -i hosts 04.master.yml --tags update    `
`ansible-playbook -i hosts 05.node.yml --tags update`
