#!/bin/bash

#K3s belirtilmediği sürece kendini ilk ağ arayüzüne bağlıyor (Örneğin 10.0.2.15-> NAT IP'si). Bunun için aşağıdakileri yaptım.
#"--bind-adress=192.168.56.110": Sunucunun gelen bağlantıları dinlediği IP adresini belirler.
#"--node-ip=192.168.56.110": Sunucunun kümedeki diğer üyelere kendini tanıttığı IP adresini belirler. 
export INSTALL_K3S_EXEC="--bind-adress=192.168.56.110 --node-ip=192.168.56.110"

curl -sfL https://get.k3s.io | sh -

mkdir -p /vagrant/shared

cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/node-token
