#!/bin/bash

curl -sfL https://get.k3s.io | sh -

mkdir -p /vagrant/shared

cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/node-token
