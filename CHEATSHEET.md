#  DevOps Komutları Hızlı Başvuru Rehberi 🚀

Bu kılavuz, proje geliştirme sürecinde en sık ihtiyaç duyacağınız Vagrant, Kubernetes (kubectl) ve K3s'e özel komutları içerir.

## 📦 Vagrant: Sanal Makine Yönetimi

| Komut | Açıklama |
| :--- | :--- |
| `vagrant up` | `Vagrantfile`'daki tüm sanal makineleri başlatır. |
| `vagrant status` | Makinelerin mevcut durumunu (çalışıyor, kapalı vb.) gösterir. |
| `vagrant global-status` | Tüm Vagrant ortamlarındaki makineleri listeler. |
| `vagrant halt <makine_adi>` | Belirtilen sanal makineyi kapatır. |
| `vagrant destroy -f <makine_adi>` | Belirtilen sanal makineyi diskten tamamen siler. |
| `vagrant ssh <makine_adi>` | Belirtilen sanal makineye SSH bağlantısı kurar. |

---

## ☸️ Kubernetes (kubectl): Temel Cluster Etkileşimi

### Cluster ve Node Bilgileri
```bash
# Cluster'ın genel durumunu ve servis adreslerini gösterir
kubectl cluster-info

# Cluster'daki tüm node'ları listeler
kubectl get nodes -o wide

# Belirtilen node'un detaylı bilgilerini ve olaylarını gösterir
kubectl describe node <node_name>
```

### Namespace (İsim Alanı) İşlemleri
```bash
# Tüm namespace'leri listeler
kubectl get namespaces

# Yeni bir namespace oluşturur
kubectl create namespace <namespace_name>
```

### Tüm Kaynakları Listeleme
```bash
# Mevcut namespace'deki tüm kaynakları (pod, service, deployment vb.) listeler
kubectl get all

# Tüm namespace'lerdeki tüm kaynakları listeler
kubectl get all -A
```

---

## ☸️ Kubernetes (kubectl): Uygulama ve Pod Yönetimi

### Kaynak Oluşturma ve Silme
```bash
# Bir YAML manifest dosyasını cluster'a uygular (oluşturur veya günceller)
kubectl apply -f <dosya_adi.yaml>

# Bir YAML manifest dosyası ile tanımlanan kaynakları siler
kubectl delete -f <dosya_adi.yaml>
```

### Deployment (Dağıtım) İşlemleri
```bash
# Deployment'ları listeler
kubectl get deployments

# Bir deployment'ın replika sayısını değiştirir
kubectl scale deployment <deployment_name> --replicas=3

# Bir deployment'ın güncellenme durumunu canlı olarak izler
kubectl rollout status deployment/<deployment_name>
```

### Pod İşlemleri
```bash
# Pod'ları daha detaylı bilgilerle listeler
kubectl get pods -o wide

# Bir pod'un detaylı bilgilerini ve olay (events) geçmişini gösterir
kubectl describe pod <pod_name>

# Çalışan bir pod'un içinde komut satırı oturumu başlatır
kubectl exec -it <pod_name> -- /bin/sh
```

---

## ☸️ Kubernetes (kubectl): İnceleme ve Hata Ayıklama (Troubleshooting)

### Logları İzleme
```bash
# Bir pod'un loglarını gösterir
kubectl logs <pod_name>

# Bir pod'un loglarını canlı olarak akıtır
kubectl logs -f <pod_name>
```

### Kaynak Kullanımını Görüntüleme
```bash
# Node'ların CPU ve Bellek kullanımını gösterir
kubectl top nodes

# Pod'ların CPU ve Bellek kullanımını gösterir
kubectl top pods
```

### Gelişmiş Çıktı Formatları
```bash
# Bir kaynağın tüm tanımını YAML formatında gösterir
kubectl get pod <pod_name> -o yaml

# Bir kaynağın çıktısını JSON formatına çevirip `jq` ile güzelleştirme
kubectl get pod <pod_name> -o json | jq '.'
```

---

## 🐓 K3s'e Özel Komutlar ve Sistem Logları

### K3s Servis Yönetimi
```bash
# K3s server (controller) servisinin loglarını canlı izleme
sudo journalctl -u k3s -f

# K3s agent (worker) servisinin loglarını canlı izleme
sudo journalctl -u k3s-agent -f
```

### K3s Dahili Bilgileri
```bash
# Agent'ların cluster'a katılması için gereken token'ı gösterir
sudo cat /var/lib/rancher/k3s/server/node-token

# K3s'in dahili olarak kullandığı SQLite veritabanı dosyalarını listeler
sudo ls -la /var/lib/rancher/k3s/server/db/

# Veritabanından pod bilgilerini sorgulama (örnek)
sudo sqlite3 /var/lib/rancher/k3s/server/db/state.db "SELECT name FROM kine WHERE name LIKE '%pods%' LIMIT 5;"
```

### K3s Dahili Servisleri (Traefik)
```bash
# Traefik Ingress denetleyicisinin pod'larını kontrol etme
sudo kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik

# Traefik servislerini kontrol etme
sudo kubectl get svc -n kube-system -l app.kubernetes.io/name=traefik
```
