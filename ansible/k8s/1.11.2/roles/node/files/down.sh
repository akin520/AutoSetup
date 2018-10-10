wget https://dl.k8s.io/v1.11.2/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
cp server/bin/{kubectl,kube-proxy,kubelet} ../
