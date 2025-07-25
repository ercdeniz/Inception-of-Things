# 📦 Vagrant ve ☸️ Kubernetes Komut Referansı

## 📦 Vagrant Komutları

### Vagrant'ı çalıştırmak için
```bash
vagrant up
```

### Çalışan sanal makineleri listelemek için
```bash
vagrant global-status | grep running
```

### Sanal makineyi durdurmak için
```bash
vagrant halt <makine_adi/id>
```

### Sanal makineleri silmek için
```bash
vagrant destroy -f <makine_adi/id>
```

### Vagrant durumunu kontrol etme
```bash
vagrant status
```

## ☸️ Kubernetes (kubectl) Komutları

### 🔹 Pod İşlemleri

#### Pod oluşturur
```bash
kubectl apply -f <pod.yaml>
```

#### Daha detaylı (verbose) loglama
```bash
kubectl apply -f <pod.yaml> -v=8
```

#### Pod silme
```bash
kubectl delete -f <pod.yaml>
```

#### Pod'ları listeleme
```bash
kubectl get pods
kubectl get pods -o wide        # Daha fazla bilgi
kubectl get pods -o yaml        # YAML formatında
kubectl get pods -o json        # JSON formatında
kubectl get pods --watch        # Değişiklikleri izle
kubectl get pods -A             # Tüm namespace'lerde
```

#### Pod'a bağlanma
```bash
kubectl exec -it <pod_name> -- /bin/bash
kubectl exec -it <pod_name> -- /bin/sh    # bash yoksa
```

#### Pod loglarını görme
```bash
kubectl logs <pod_name>
kubectl logs -f <pod_name>      # Canlı takip
```

## 🐓 K3s Özel Komutları

### Server token'ini gösterme
```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```

### YAML → JSON dönüşümü
```bash
kubectl get pod <pod_name> -o json | jq '.'
```

### SQLite3 konumu
```bash
sudo ls -la /var/lib/rancher/k3s/server/db/
```

### DB'den veri okuma
```bash
sudo sqlite3 /var/lib/rancher/k3s/server/db/state.db ".tables"
sudo sqlite3 /var/lib/rancher/k3s/server/db/state.db "SELECT name FROM kine WHERE name LIKE '%pods%' LIMIT 5;"
```

## 🖥️ Node İşlemleri

### Node'ların bilgilerini öğrenme
```bash
kubectl get nodes -o wide
kubectl describe node <node_name> | grep -A 10 "Allocatable"
kubectl top nodes               # Kaynak kullanımı
```

## 📄 Loglama

### Scheduler logları
```bash
sudo journalctl -u k3s -f | grep scheduler
```

### Kubelet logları
```bash
sudo journalctl -u k3s-agent -f | grep kubelet
```

## 🚀 Deployment İşlemleri

### Replika sayısını ayarlama
```bash
kubectl scale deployment <deployment_name> --replicas=5
```

### Deployment durumunu kontrol etme
```bash
kubectl rollout status deployment/<deployment_name>
```

## 🛠️ Ek Yararlı Komutlar

### Tüm kaynakları listeleme
```bash
kubectl get all
kubectl get all -A              # Tüm namespace'lerde
```

### Resource kullanımını görme
```bash
kubectl top pods
kubectl top nodes
```

### Namespace işlemleri
```bash
kubectl get namespaces
kubectl create namespace <namespace_name>
```

### Traefik'i kontrol et
```bash
sudo kubectl get pods -n kube-system | grep traefik
sudo kubectl get svc -n kube-system | grep traefik
```
