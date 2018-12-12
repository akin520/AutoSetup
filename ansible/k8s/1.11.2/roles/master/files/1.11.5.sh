export https_proxy="http://192.168.20.198:7777"
if [[ ! -f "kubernetes-server-linux-amd64.tar.gz" ]];then
wget https://dl.k8s.io/v1.11.5/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz
fi
mkdir -p 1.11.5
cp kubernetes/server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,kube-proxy,kubelet,kubeadm} 1.11.5/
mkdir -p ../../node/files/1.11.5
cp kubernetes/server/bin/{kubectl,kube-proxy,kubelet} ../../node/files/1.11.5
