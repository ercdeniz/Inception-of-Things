### Genel Çerçeve

***Projenin genel isterleri  özeti (tablo şeklinde):***

| Bölüm                              | Amaç                                                                                          | Öne Çıkan Ayrıntılar                                                                                                                                                                     |
| ---------------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **IV.1 Part 1 – K3s & Vagrant**    | İki VM (Server ve ServerWorker) kurup K3s’i sırasıyla controller ve agent modunda çalıştırmak | _Vagrantfile_ içinde **1 CPU / 512–1024 MB RAM**, sabit IP’ler (192.168.56.110 & 192.168.56.111), parolasız SSH, hostname sonuna **S** ve **SW** ekleri, modern provisioning             |
| **IV.2 Part 2 – K3s & 3 Uygulama** | Tek VM’de K3s + Ingress ile 3 web uygulamasını HOST başlığına göre servis etmek               | 192.168.56.110 IP’si; _app2_ en az **3 replica**; `HOST`=app1.com → app1, app2.com → app2, aksi takdirde app3 (default)                                                                  |
| **IV.3 Part 3 – K3d & Argo CD**    | Vagrant olmadan K3d kümesi + Argo CD ile **CI/CD** akışı                                      | İki namespace (**argocd**, **dev**); dev’deki uygulama iki etiketli (v1, v2) Docker imajından otomatik deploy; sürüm değişimi GitHub repo’sundan tetiklenip Argo CD’de senkronize olmalı |
| **Bonus**                          | Küme içine yerel **GitLab** kurup Part 3 akışını GitLab üzerinden yönetmek                    | Ayrı **gitlab** namespace’i, en güncel GitLab sürümü, gerekirse Helm; bonus yalnızca tüm zorunlu kısımlar kusursuzsa değerlendirilecek                                                   |
### Teslimat Yapısı

```
inception-of-things/
├── p1/                    # Part 1: K3s & Vagrant
│   ├── Vagrantfile
│   └── scripts/
├── p2/                    # Part 2: K3s & 3 Uygulama  
│   ├── Vagrantfile
│   └── conf/
├── p3/                    # Part 3: K3d & Argo CD
│   └── conf/
└── bonus/                 # Bonus: GitLab (opsiyonel)
    └── conf/
```



## Part 1: K3s and Vagrant



## 1 — Part 1’de Tam Olarak Ne İsteniyor?

| Gereksinim                | Detay                                                                  |
| ------------------------- | ---------------------------------------------------------------------- |
| **İki adet sanal makine** | Vagrant ile, en güncel dağıtım kutusunu (box) kullanarak.              |
| **Kaynak sınırı**         | Her makine: **1 CPU, 512 (isteğe bağlı 1024) MB RAM**.                 |
| **İsimlendirme**          | Team login + **S** (controller) ve **SW** (worker) ekleri.             |
| **Statik IP**             | `192.168.56.110` (Server), `192.168.56.111` (ServerWorker).            |
| **Parolasız SSH**         | Vagrant’ın varsayılan anahtar yönetimiyle sağlanacak.                  |
| **K3s kurulumu**          | • Server’da **controller** modunda  <br>• Worker’da **agent** modunda. |
| **kubectl**               | En az Server’da, tercihen ikisinde de kurulu olacak.                   |
| **Modern Vagrantfile**    | Uzun komutları dış script’e ayırmak, senkron klasörü kapatmak vb.      |

---

## 2 — Görev Başarı Kriterleri

1. **`vagrant up` tek komutuyla** iki VM eksiksiz ayağa kalkar.
    
2. `vagrant ssh idelemenS` → `kubectl get nodes` çıktısında **iki düğüm de `Ready`** görülür.
    
3. Her iki VM’e parolasız SSH ile bağlanılabilir.
    
4. Host makineden iki IP’ye de ping atılabilir.
    
5. `kubectl version` komutu K3s’in <u>son kararlı sürümünü</u> gösterir.
    

Bu beş maddeyi görsel veya canlı gösterimde sorgusuz geçiyorsanız, Part 1 %100 tamamlanmış demektir.

---

## 3 — Part 1 Tamamlandığında Elimizde Ne Var?

🎯 **Tek komutla kurulup silinebilen iki düğümlü, gerçek bir Kubernetes (>1.28) test kümesi.**

```
┌─────────────────────┐                    ┌─────────────────────┐
│    idelemenS        │                    │    idelemenSW       │
│   (K3s server)      │←─────token────────▶│   (K3s agent)       │
│  192.168.56.110     │                    │  192.168.56.111     │
└─────────────────────┘                    └─────────────────────┘
```

- **Yeniden üretilebilir:** Kaynak kodu yalnızca `Vagrantfile` + 2 script.
    
- **Hafif:** Toplam 1 vCPU + 1 GB RAM dahi dizüstünde rahatça çalışır.
    
- **Gerçekçi:** `kubectl`, `helm`, Ingress gibi araçlar tamamen aynı şekilde davranır; prod ortamındaki K8s konseptlerini bozmadan öğrenirsiniz.
    

---

## 4 — Bu Küme Ne İşe Yarar?

|Kullanım|Pratik Katkı|
|---|---|
|**Öğrenme/Deneme**|K8s objelerini (Deployment, Service, Ingress) güvenle denersiniz—yanlış bir `kubectl apply` prod’u etkilemez.|
|**CI öncesi entegrasyon**|İlerde Part 3’te Argo CD ile otomatik deployment’a geçeceksiniz; Part 1 kümesi, o zincirin en küçük ama kritik halkasıdır.|
|**Uygulama testi**|Mikroservisleri “tek düğüm Docker” yerine **iki düğümlü K8s** altında görebilir, node-affinity, rolling update vb. senaryoları yaşarsınız.|
|**Takım standardı**|Her ekip üyesi aynı komutla aynı ortamı kurar; “bende çalışıyor–sende bozuk” sorunu ortadan kalkar.|
|**Güvenli at-sil döngüsü**|`vagrant destroy` → tüm izler silinir; yeni bir `vagrant up` → tertemiz cluster 2-3 dk’da yeniden hazır.|

---

### Özet

> **Part 1, “tek tuşla” çalışan minimalist bir K3s laboratuvarı kurdurur.**  
> Bunu sorunsuz bitirdiğinizde:  
> _kodu paylaşılan, makinesi hızlı kurulan, gerçek Kubernetes davranışı sergileyen_ bir altyapınız olur. Bu altyapı, hem sonraki ödev kısımlarının (Ingress + 3 app, K3d + Argo CD) temelidir hem de profesyonel K8s pratiği edinmenizi sağlar.



### Gerekenler

|Adım|Komut / Açıklama|
|---|---|
|**VirtualBox** (veya desteklenen başka bir provider)|[https://www.virtualbox.org](https://www.virtualbox.org/)|
|**Vagrant ≥ 2.4**|[https://developer.hashicorp.com/vagrant/downloads](https://developer.hashicorp.com/vagrant/downloads)|
|**SSH anahtarı**|`ssh-keygen -t ed25519 -C "vagrant@local"`~/.ssh/id_ed25519.pub dosyası VM’lere parolasız giriş için kullanılacak.|
> ⚠️ Vagrant, oluşturduğu sanal makinede kendi kullanıcı hesabına **ilk açılışta** bu public anahtarı ekler ve böylece parolasız SSH bağlantısı sağlar.

### Dosya Yapısı

```
p1/
 ├── Vagrantfile
 └── scripts/
  ├── install_k3s_server.sh
  └── install_k3s_agent.sh
```

**`scripts/`** klasörü, “modern practice” olarak uzun shell kodunu Vagrantfile’dan ayırır; değişiklik/test döngüsünü hızlandırır.

### Örnek Vagrantfile

```ruby
Vagrant.configure("2") do |config|
  config.ssh.insert_key = true           # Her 'vagrant up'ta taze SSH anahtarı
  config.vm.box        = "ubuntu/24.04"  # Güncel, hafif bir LTS

  # Paylaşımlı klasörü kapat – Kube cluster’da genelde gereksiz
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # ========== SERVER ==========
  config.vm.define "idelemenS" do |srv|
    srv.vm.hostname = "idelemenS"
    srv.vm.network "private_network", ip: "192.168.56.110"

    srv.vm.provider :virtualbox do |vb|
      vb.memory = 512
      vb.cpus   = 1
    end

    srv.vm.provision "shell", path: "scripts/install_k3s_server.sh", privileged: true
  end

  # ========== WORKER ==========
  config.vm.define "idelemenSW" do |wrk|
    wrk.vm.hostname = "idelemenSW"
    wrk.vm.network "private_network", ip: "192.168.56.111"

    wrk.vm.provider :virtualbox do |vb|
      vb.memory = 512
      vb.cpus   = 1
    end

    wrk.vm.provision "shell",
      path: "scripts/install_k3s_agent.sh",
      privileged: true,
      env: {
        "K3S_URL"   => "https://192.168.56.110:6443",
        # Token, server kurulunca /var/lib/rancher/k3s/server/node-token altında oluşur.
        "K3S_TOKEN" => `cat .server_token`.strip
      }
  end
end
```

**Nokta atışı modernlik:**

- _Static private_network_ blokları en temiz IP atama yoludur. 
    
- Synced-folder’ı kapatmak, I/O overhead’ini düşürür.
    
- Shell provisioner dış dosyaya ayrıldı; Vagrantfile okunabilir kaldı.
    
- Token’ı basitçe host’a kaydedip ikinci VM’e ENV olarak ilettik.


### Kurulum Script’leri

#### install_k3s_server.sh

```bash
#!/usr/bin/env bash
set -e
curl -sfL https://get.k3s.io | sh -           # k3s + kubectl kurulur
# token’ı host paylaşımına at ki worker erişsin
cat /var/lib/rancher/k3s/server/node-token >/vagrant/.server_token
```

#### install_k3s_agent.sh

```bash
#!/usr/bin/env bash
set -e
curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -
```


## Çalıştırma ve Doğrulama

1. **Başlat:** `cd p1 && vagrant up`  
    Multi-machine özelliği iki VM’i ardışık yaratır. 
    
2. **Sunucuya gir:** `vagrant ssh idelemenS`
    
3. **Cluster durumu:**
    
    `sudo kubectl get nodes -o wide`
    
    İki düğüm de `Ready` ise Part 1 başarıyla bitti.
    
4. (**İpucu**) Host makinenizde `~/.kube/config` yaratmak için:
    
    ```bash
    # K3s kubeconfig dosyasını host makinenize alın:
    vagrant ssh idelemenS -c "sudo cat /etc/rancher/k3s/k3s.yaml" \
      | sed 's/127.0.0.1/192.168.56.110/' > k3s-config

    # KUBECONFIG ortam değişkenini ayarlayın:
    export KUBECONFIG=$PWD/k3s-config
    ```
    Bu şekilde, kendi makinenizden doğrudan küme yönetimi yapabilirsiniz.
    

---

## Sık Karşılaşılan Sorular

|Problem| Çözüm                                                                                                                |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------- |
|**“SSH timed out”**| VirtualBox host-only ağında 192.168.56.0/24 çakışıyorsa _File → Host-Network Manager_’dan aralığı değiştirin.        |
|**Worker bağlanmıyor**| `.server_token` henüz oluşmamıştır → `vagrant reload idelemenSW` komutu, token hazırken script’i yeniden çalıştırır. |
|**RAM yetmedi**| `vb.memory = 1024` yapın; CPU’yu yine 1 bırakın (gereği yoksa fazlası notlandırılabilir).                            |

---

### Özet

- **Vagrantfile** iki makine + statik IP + minimal kaynak + parolasız SSH.
    
- **Server**: k3s controller; **Worker**: k3s agent (token + URL ile).
    
- `vagrant up` → 5 dk içinde “kubectl get nodes” çıktısı **2 düğüm Ready**.



# Ana Özet

```
Vagrantfile ──> `vagrant up`
          ├─ aliceS   (k3s server = kontrol düzlemi + node)
          └─ aliceSW  (k3s agent  = ek node)
                 ↑
           token + K3S_URL ile küme kaydı
```

- **Vagrant** = VM’leri script’le kuran orkestratör.
    
- **K3 s** = O VM’lere **Kubernetes kümesini** kuran betik.
    
- Sonuç = İki düğümlü, hafif ama tam uyumlu bir Kubernetes laboratuvarı.

---

## Bir Takım Açıklamalar:

### A. Vagrant Hakkında

| Aşama                           | Vagrant’ın rolü                                                                                                     | Altında çalışan teknoloji                                       |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| 1. **Tanımlama**                | `Vagrantfile` içinde CPU, RAM, ağ, hangi ISO/box kullanılacağı, hangi paketlerin kurulacağı vb. kodla tarif edilir. | Ruby sentezi ama bilmek gerekmez; içi yorum satırı gibi okunur. |
| 2. **Başlatma (`vagrant up`)**  | Seçili “provider”a emir gönderir, disk imajını indirir/klonlar, VM’i açar.                                          | _Varsayılan_: **VirtualBox**.                                   |
| 3. **Hazırlık (Provision)**     | VM açılır açılmaz shell/Ansible/Cloud-Init vb. script’leri çalıştırır; ortam “kullanıma hazır” hâle gelir.          | Böylece her ekip üyesi aynı komutla birebir aynı makineyi alır. |
| 4. **Kullanım (`vagrant ssh`)** | Parolasız SSH anahtarı otomatik eklenir; VM’e tek komutla girersiniz.                                               |                                                                 |
| 5. **Duraklatma / Silme**       | `vagrant halt` (kapama) – `vagrant destroy` (temiz silme). Tekrar `up` dendiğinde sıfırdan, tertemiz kurulur.       |                                                                 |

### Neden “kendi sanallaştırmasını” yapmıyor?

Vagrant **kendisi bir hiper-vizör değildir**; VirtualBox, libvirt, VMware gibi mevcut sanallaştırmaları “uzaktan kumanda” eder. Böylece:

- _Tüm konfigürasyon dosyada_ → “Bir kere tanımla, herkes aynı ortamı alsın.”
    
- _Tek tuşla at, boz, yeniden kur_ → “Bende çalışıyor” sorununu ortadan kaldır.
    
- _Provider değiştirmek kolay_ → Masaüstünde VirtualBox, CI sunucusunda libvirt kullanabilirsiniz; `Vagrantfile` çoğu zaman değişmez.

