#!/bin/bash

curl -sfL https://get.k3s.io | sh -

mkdir -p /home/vagrant/.kube

cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config

chown -R vagrant:vagrant /home/vagrant/.kube
