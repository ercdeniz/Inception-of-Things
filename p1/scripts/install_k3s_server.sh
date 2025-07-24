#!/bin/bash


export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --bind-address=192.168.56.110 --node-ip=192.168.56.110"

apt-get update
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -

mkdir -p /vagrant/shared

SECONDS=0
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
    if [ "$SECONDS" -ge 60 ]; then
        echo "Node token not found after 60 seconds of waiting, exiting."
        exit 1
    fi
    echo "Waiting for node-token... ($SECONDS/60s)"
    sleep 1
done

cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/node-token
