#!/bin/bash

# Initialize Kubernetes
echo "[TASK 1] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.42.42.100 --pod-network-cidr=10.244.0.0/16 >> /root/kubeinit.log 2>/dev/null

# Copy Kube admin config
echo "[TASK 2] Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Deploy flannel network
echo "[TASK 3] Deploy flannel network"
su - vagrant -c "kubectl create -f /vagrant/kube-flannel.yml"

# Generate Cluster join command
echo "[TASK 4] Generate and save cluster join command to joincluster.sh"
kubeadm token create --print-join-command > $HOME/joincluster.sh

# Create NFS Server (as example for persistent volumes)
echo "[TASK 5] Setup NFS Server"
yum install -y -q nfs-utils > /dev/null 2>&1
mkdir -p /var/nfsshare
chmod -R 755 /var/nfsshare
chown nfsnobody:nfsnobody /var/nfsshare

echo "/var/nfsshare    *(rw,sync)" >> /etc/exports

systemctl enable rpcbind >/dev/null 2>&1
systemctl enable nfs-server >/dev/null 2>&1
systemctl enable nfs-lock >/dev/null 2>&1
systemctl enable nfs-idmap >/dev/null 2>&1
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

# firewall is disabled in bootstrap.sh so the following aren't needed
# firewall-cmd --permanent --zone=public --add-service=nfs
# firewall-cmd --permanent --zone=public --add-service=mountd
# firewall-cmd --permanent --zone=public --add-service=rpc-bind
# firewall-cmd --reload
