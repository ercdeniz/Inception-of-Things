#!/bin/bash

export INSTALL_K3S_EXEC="server --disable traefik --write-kubeconfig-mode 644 --node-ip 192.168.56.110"

apt update && apt install -y curl

curl -sfL https://get.k3s.io | sh -

mkdir -p /home/vagrant/.kube

cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config

chown -R vagrant:vagrant /home/vagrant/.kube
