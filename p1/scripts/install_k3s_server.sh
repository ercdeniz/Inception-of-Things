#!/bin/bash

#K3s belirtilmediği sürece kendini ilk ağ arayüzüne bağlıyor (Örneğin 10.0.2.15-> NAT IP'si). Bunun için aşağıdakileri yaptım.
#"--bind-adress=192.168.56.110": Sunucunun gelen bağlantıları dinlediği IP adresini belirler.
#"--node-ip=192.168.56.110": Sunucunun kümedeki diğer üyelere kendini tanıttığı IP adresini belirler. 
export INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --bind-address=192.168.56.110 --node-ip=192.168.56.110"

curl -sfL https://get.k3s.io | sh -

mkdir -p /vagrant/shared

#Token oluşturulmadan kopyalama işlemi yapmaması için kontrol ekledim.
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
