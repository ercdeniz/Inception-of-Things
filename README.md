# K3s ve GitOps ile Modern Altyapı Otomasyonu Projesi

Bu proje, modern bir Kubernetes altyapısının sıfırdan nasıl kurulduğunu, manuel olarak nasıl yönetildiğini ve son olarak GitOps prensipleriyle nasıl tamamen otomatize edildiğini adım adım gösteren kapsamlı bir kılavuzdur.

## Proje Felsefesi ve Yapısı

Proje, basitten karmaşığa doğru ilerleyen üç ana bölümden oluşur. Her bölüm, bir önceki üzerine yeni bir yetenek katmanı ekler:

1.  **Temel Kurulum (`p1`):** Vagrant ve sanal makinelerle elle tutulur bir Kubernetes cluster'ı oluşturma.
2.  **Manuel Dağıtım (`p2`):** Cluster üzerine uygulamaları ve ağ kurallarını `kubectl` ile manuel olarak dağıtma.
3.  **Tam Otomasyon (`p3`):** `kubectl` ihtiyacını ortadan kaldırıp, tüm uygulama yaşam döngüsünü **Git** üzerinden yönetme (GitOps).

### Genel Gereksinimler Özeti

| Bölüm | Amaç | Öne Çıkan Ayrıntılar |
| :--- | :--- | :--- |
| **Bölüm 1** | K3s & Vagrant | **2 CPU / 2048 MB RAM** ile 2 VM (Controller/Agent), sabit IP, `ercdenizS`/`ercdenizSW` isimlendirmesi. |
| **Bölüm 2** | K3s & 3 Uygulama | Tek VM'de Ingress ile host tabanlı yönlendirme. `app2` için **en az 3 replica**. `app1.com`, `app2.com` ve varsayılan olarak `app3`. |
| **Bölüm 3** | K3d & Argo CD | Vagrant'sız, K3d + Argo CD ile Git tabanlı CI/CD. `argocd` ve `dev` namespace'leri. Sürüm değişimi Git'ten tetiklenmeli. |
| **Bonus** | GitLab Entegrasyonu | GitOps akışını, cluster içinde çalışan yerel bir GitLab deposu üzerinden yönetmek. |

### Proje Dosya Yapısı

```
├── p1/
│   ├── Vagrantfile
│   └── scripts/
├── p2/
│   ├── Vagrantfile
│   └── conf/
└── p3/
    ├── Makefile
    ├── confs/
    └── scripts/
```

---

## Bölüm 1: K3s & Vagrant ile Temel Cluster Kurulumu (`p1`)

Bu bölümde, Vagrant kullanılarak bir controller (`ercdenizS`) ve bir agent (`ercdenizSW`) düğümünden oluşan 2-nodelu bir K3s cluster'ı kurulur.

**Anahtar Kavram:** Bu adım, `Vagrantfile` ve basit shell betikleri aracılığıyla altyapının kod olarak (Infrastructure as Code) nasıl tanımlanacağını gösterir.

### Kurulum

`p1` dizinindeyken tek bir komut yeterlidir:
```bash
vagrant up
```
Bu komut, `Vagrantfile` dosyasını okuyarak aşağıdaki işlemleri otomatik olarak yapar:
*   **Controller Düğümü (`ercdenizS`):**
    *   IP: `192.168.56.110`, 1 CPU, 1024MB RAM
    *   `scripts/install_k3s_server.sh` betiğini çalıştırarak K3s'i kurar ve agent'ın katılması için bir *join token* oluşturur.
*   **Agent Düğümü (`ercdenizSW`):**
    *   IP: `192.168.56.111`, 1 CPU, 512MB RAM
    *   `scripts/install_k3s_agent.sh` betiğini çalıştırarak, controller tarafından paylaşılan token'ı kullanır ve cluster'a katılır.

**Beklenen Sonuç:** `vagrant up` tamamlandığında, `kubectl get nodes -o wide` komutunu çalıştırabileceğiniz, tam işlevsel bir K3s cluster'ınız olur.

---

## Bölüm 2: K3s & 3 Uygulama ile Ingress Kurulumu (`p2`)

Bu bölümde, K3s'in dahili Traefik Ingress denetleyicisi kullanılarak, gelen isteğin `Host` başlığına göre farklı uygulamalara yönlendirilmesi sağlanır.

**Anahtar Kavram:** Kubernetes'te `Ingress` kaynaklarının, dış dünyadan gelen L7 (HTTP/S) trafiğini cluster içindeki servislere nasıl akıllıca dağıttığını anlamak.

### Kurulum ve Dağıtım

1.  `p2` dizinine gidin ve tek sunuculu test ortamını kurun:
    ```bash
    cd p2
    vagrant up
    ```
2.  Sanal makineye bağlanın ve uygulama manifestolarını `kubectl` ile cluster'a uygulayın:
    ```bash
    vagrant ssh
    # Cluster'a 3 uygulamayı ve Ingress kurallarını dağıt
    sudo kubectl apply -f /vagrant/conf/my-apps.yaml
    # Traefik dashboard'u için erişim kuralını dağıt
    sudo kubectl apply -f /vagrant/conf/dashboard-ingressroute.yaml
    exit
    ```

### Uygulamalara Erişim

Erişim için yerel makinenizin `hosts` dosyasını (`/etc/hosts` veya `C:\Windows\System32\drivers\etc\hosts`) düzenleyerek aşağıdaki satırı ekleyin:
```
192.168.56.110 app1.com app2.com traefik.local
```
Artık tarayıcınızdan erişebilirsiniz:
*   `http://app1.com` → **Uygulama 1**
*   `http://app2.com` → **Uygulama 2** (Bu uygulama 3 replica ile çalışır)
*   `http://192.168.56.110` → **Varsayılan Uygulama 3**
*   `http://traefik.local/dashboard/` → **Traefik Yönetim Paneli**

---

## Bölüm 3: K3d & Argo CD ile GitOps Otomasyonu (`p3`)

Projenin zirve noktası olan bu bölümde, tüm manuel `kubectl` adımları ortadan kaldırılır. Argo CD, bir Git deposunu "tek doğru kaynak" olarak kabul eder ve cluster'ın durumunu sürekli olarak bu depoyla senkronize halde tutar.

**Anahtar Kavram (GitOps):** Altyapı ve uygulamaların durumunu, versiyon kontrol sisteminde (Git) deklaratif olarak tanımlama ve bu durumu bir otomasyon aracıyla (Argo CD) sürekli olarak canlı sisteme uygulama pratiğidir. **"Cluster'ı `git push` ile yönetmek."**

### Otomasyonu Başlatma

`p3` dizininde, `Makefile` tüm süreci yönetir:
```bash
make setup
```
Bu komut, bir dizi betiği tetikleyerek şunları yapar:
1.  **Gereksinim Kontrolü:** `docker`, `kubectl`, `k3d`'nin varlığını denetler.
2.  **Cluster Oluşturma:** Docker üzerinde `k3d` ile hafif bir K3s cluster'ı kurar.
3.  **Namespace Hazırlığı:** `argocd` ve `dev` namespace'lerini oluşturur.
4.  **Argo CD Kurulumu:** Argo CD'yi kendi namespace'ine kurar.
5.  **GitOps Bağlantısı:** `confs/app.yaml` dosyasını cluster'a uygular. Bu dosya, Argo CD'ye şu talimatı verir:
    > **"Bu GitHub deposundaki (`TufanKurukaya/tkurukay`) `conf` klasörünü izle ve içindeki tüm YAML'leri bu cluster'ın `dev` namespace'ine otomatik olarak uygula. Değişiklikleri anında senkronize et, silinenleri temizle ve manuel müdahaleleri geri al."**
6.  **Erişim Bilgileri:** Argo CD arayüzü için port yönlendirmeyi başlatır ve şifreyi ekrana basar.
### Gerekli Olabilecek Komutlar 
*   📜 **[Komut Referansı](./CHEATSHEET.md):** Projede kullanılan Vagrant, kubectl ve K3s komutları için hızlı başvuru kılavuzu.
### Makefile Komutları

`p3` dizinindeki otomasyonu yönetmek için kullanışlı komutlar:

| Komut | Açıklama |
| :--- | :--- |
| `make setup` | Tüm GitOps ortamını sıfırdan kurar. |
| `make clean` | Kurulan K3d cluster'ını ve tüm kalıntıları temizler. |
| `make status` | Cluster ve pod'ların genel durumunu özetler. |
| `make guide` | Argo CD arayüzü için erişim linkini ve kimlik bilgilerini gösterir. |
| `make pass` | Sadece Argo CD yönetici şifresini yeniden gösterir. |
| `make help` | Bu yardım menüsünü görüntüler. |
