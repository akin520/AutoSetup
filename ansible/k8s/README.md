
# k8s 1.5.2安装脚本 #


1. init_env.yml 环境初使化     
`[root@server198 k8s]# ansible-playbook -i init_env.yml`
2. 安装docker，首先安装docker主节点docker_master.yml，再安装其它节点docker_node.yml
`[root@server198 k8s]# ansible-playbook -i docker_master.yml`
`[root@server198 k8s]# ansible-playbook -i docker_node.yml`
3. 安装k8s，首先安装k8s master点k8s_master.yml,再安装node节点k8s_node.yml;master上可以安装node节点
`[root@server198 k8s]# ansible-playbook -i k8s_master.yml`
`[root@server198 k8s]# ansible-playbook -i k8s_node.yml`
