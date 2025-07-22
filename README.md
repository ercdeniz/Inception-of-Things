# Inception of Things – P1 + P2 Notları

## 📉 Proje Yapısı

```
inception-of-things/
├── p1/
│   ├── Vagrantfile
│   └── scripts/
│       ├── install_k3s_server.sh
│       └── install_k3s_agent.sh
├── p2/
│   ├── Vagrantfile
│   ├── scripts/
│   │   └── install_k3s_server.sh
│   └── conf/
│       ├── app1.yaml
│       ├── app2.yaml
│       ├── app3.yaml
│       └── ingress.yaml
```

---

## ✅ Part 1 – K3s Server + Agent

### Amaç

İki ayrı VM’de:

* `ercdenizS`: K3s server
* `ercdenizSW`: K3s agent

### Vagrantfile (p1/Vagrantfile)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.define "ercdenizS" do |server|
    server.vm.hostname = "ercdenizS"
    server.vm.network "private_network", ip: "192.168.56.110"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
    server.vm.provision "shell", path: "scripts/install_k3s_server.sh"
  end

  config.vm.define "ercdenizSW" do |worker|
    worker.vm.hostname = "ercdenizSW"
    worker.vm.network "private_network", ip: "192.168.56.111"
    worker.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
    worker.vm.provision "shell", path: "scripts/install_k3s_agent.sh"
  end
end
```

### install\_k3s\_server.sh

```bash
#!/bin/bash

curl -sfL https://get.k3s.io | sh -

mkdir -p /vagrant/shared
cp /var/lib/rancher/k3s/server/node-token /vagrant/shared/node-token
```

### install\_k3s\_agent.sh

```bash
#!/bin/bash

for i in {1..12}; do
  if [ -f /vagrant/shared/node-token ]; then
    break
  fi
  echo "Token bekleniyor..."
  sleep 5
done

TOKEN=$(cat /vagrant/shared/node-token)
MASTER_IP="192.168.56.110"

curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="$TOKEN" sh -
```

---

## ✅ Part 2 – Tek VM + Ingress + 3 App

### Amaç

Tek bir VM içinde 3 uygulama, Ingress ile host tabanlı yönlendirme:

* `app1.com` → nginx
* `app2.com` → httpd (3 replica)
* diğer domain → app3 (fallback)

### Vagrantfile (p2/Vagrantfile)

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.define "ercdenizS" do |server|
    server.vm.hostname = "ercdenizS"
    server.vm.network "private_network", ip: "192.168.56.110"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
    server.vm.provision "shell", path: "scripts/install_k3s_server.sh"
  end
end
```

### install\_k3s\_server.sh (p2/scripts)

```bash
#!/bin/bash

curl -sfL https://get.k3s.io | sh -

mkdir -p /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube
```

---

## 📦 Uygulama YAML Dosyaları (p2/conf)

### app1.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-one
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: app-one
spec:
  selector:
    app: app1
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### app2.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-two
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: httpd
        image: httpd
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: app-two
spec:
  selector:
    app: app2
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### app3.yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-three-html
data:
  index.html: |
    <html><body><h1>This is the fallback app (app3)</h1></body></html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-three
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app3
  template:
    metadata:
      labels:
        app: app3
    spec:
      containers:
      - name: app3
        image: nginx
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
      - name: html
        configMap:
          name: app-three-html
---
apiVersion: v1
kind: Service
metadata:
  name: app-three
spec:
  selector:
    app: app3
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

### ingress.yaml

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: traefik
  rules:
  - host: app1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-one
            port:
              number: 80
  - host: app2.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-two
            port:
              number: 80
  defaultBackend:
    service:
      name: app-three
      port:
        number: 80
```

---

## 🔍 Test Adımları

### 1. VM Başlat

```bash
cd p2
vagrant up
```

### 2. Uygulamaları deploy et

```bash
vagrant ssh ercdenizS
kubectl apply -f /vagrant/conf/
```

### 3. Test (VM içinde veya host'ta)

* `/etc/hosts` dosyasına ekle:

```
192.168.56.110 app1.com app2.com fallback.com
```

* Tarayıcıdan veya terminalden test:

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: fallback.com" http://192.168.56.110
```

---

## ℹ️ Traefik Nedir?

* K3s ile birlikte gelen varsayılan **Ingress Controller**.
* Gelen trafiği HTTP header'larına, path'lere veya domain'e göre servis'lere yönlendirir.
* Alternatifleri:

  * NGINX Ingress Controller
  * HAProxy Ingress
  * Istio / Linkerd (Service Mesh)

---

## 🎯 Trafik Akış Diyagramı

```
Kullanıcı (curl veya tarayıcı)
        │
        ▼
  http://app1.com
        │
        ▼
  [Traefik Ingress]
        │
 └─────────────────────────────────┘
 ▼                                         ▼
app-one                                app-two (3 replica)
                                               ▼
                                           app-three (fallback)
```


makine silindiği halde bu makine zaten var gibi bir hata alırsak VirtualBox'ın yoluna gidip makineyi silip tekrar deneyebiliriz.



```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DEVELOPER     │    │   GITHUB REPO   │    │   ARGO CD       │
│                 │───▶│                 │───▶│                 │
│ - Code değişir  │    │ - YAML files    │    │ - Değişiklikleri│
│ - Git push      │    │ - deploy.yaml   │    │   algılıyor     │
│                 │    │ - service.yaml  │    │ - Sync yapıyor  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   END USER      │    │   APPLICATION   │    │   KUBERNETES    │
│                 │◀───│                 │◀───│                 │
│ - Browser'dan   │    │ - Pod çalışıyor │    │ - Cluster       │
│   erişiyor      │    │ - Port 8888     │    │ - Namespaces    │
│ - API response  │    │ - v1 veya v2    │    │ - Services      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

```
+-------------------------------+
|         Kubernetes Cluster    |
|                               |
|  [Namespace: argocd]          |
|    - argocd-server            |
|    - argocd-repo-server       |
|    - ...                      |
|                               |
|  [Namespace: dev]             |
|    - wil-playground-pod       |
|    - wil-playground-service   |
|    - wil-playground-deployment|
+-------------------------------+
```
