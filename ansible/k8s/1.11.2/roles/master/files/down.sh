wget https://dl.k8s.io/v1.11.2/kubernetes-server-linux-amd64.tar.g
tar -xzvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
cp server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,kube-proxy,kubelet,kubeadm} ../
