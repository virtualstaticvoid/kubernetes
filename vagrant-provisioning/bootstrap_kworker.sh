#!/bin/bash

echo "[TASK 1] Add SSH private key and configure SSH"
mkdir -p $HOME/.ssh
cp /vagrant/id_rsa* $HOME/.ssh/

cat >$HOME/.ssh/config<<EOF
Host kmaster
  HostName kmaster.example.com
  User root
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
EOF

chmod 600 $HOME/.ssh/*

# Join worker nodes to the Kubernetes cluster
echo "[TASK 2] Join node to Kubernetes Cluster"
scp kmaster:joincluster.sh joincluster.sh 2> /dev/null
bash joincluster.sh >/dev/null 2>&1
