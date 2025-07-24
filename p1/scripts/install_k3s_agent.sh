#!/bin/bash
apt-get update
apt-get install -y curl

for i in {1..20}; do
  if [ -f /vagrant/shared/node-token ]; then
    break
  fi
  echo "Waiting for node-token to be created..."
  sleep 3
done

TOKEN=$(cat /vagrant/shared/node-token)
MASTER_IP="192.168.56.110"
curl -sfL https://get.k3s.io | K3S_URL="https://$MASTER_IP:6443" K3S_TOKEN="$TOKEN" sh -
