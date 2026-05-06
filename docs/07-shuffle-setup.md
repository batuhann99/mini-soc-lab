# Shuffle SOAR Kurulumu

## Genel Bilgi
Shuffle, açık kaynaklı bir SOAR (Security Orchestration, Automation and Response) platformudur. SOC Lab'da Wazuh SIEM'den gelen alert'leri webhook aracılığıyla alıp otomatik olarak TheHive'da case oluşturmak için kullanılmaktadır. Docker Compose ile SOC-Server (Ubuntu 22.04) üzerine kuruldu.

## Bağımlılıklar
- Docker
- Docker Compose
- En az 4GB RAM (Shuffle'ın kendi önerisi, lab ortamında RAM kısıtı nedeniyle heap ayarları düşürüldü)

## Kurulum Adımları

### 1. Docker Kurulumu
Docker ve docker-compose apt paket yöneticisi ile kuruldu. Docker servisi enable edilerek sistem başlangıcında otomatik başlaması sağlandı.

### 2. Shuffle Reposu
Shuffle resmi GitHub reposundan clone'landı. Konum: /home/soc-server/Shuffle

### 3. docker-compose.yml Değişiklikleri

#### OpenSearch Heap Artırımı
Varsayılan 128MB heap, circuit_breaking_exception hatasına yol açıyordu. 256MB'a yükseltildi:
`OPENSEARCH_JAVA_OPTS=-Xms256m -Xmx256m`

#### OpenSearch Security Plugin Devre Dışı
OpenSearch 3.2.0, SSL ve kimlik doğrulamayı varsayılan olarak zorunlu kılıyor. Lab ortamı için devre dışı bırakıldı:
`DISABLE_SECURITY_PLUGIN=true`

#### Orborus BASE_URL Düzeltmesi
Orborus, workflow'ları execute eden container'dır. Varsayılan konfigürasyonda backend'e http://${OUTER_HOSTNAME}:5001 ile bağlanmaya çalışıyordu. Container içinden host IP'ye erişilemediği için container adı kullanılacak şekilde değiştirildi:
`BASE_URL=http://shuffle-backend:5001`

### 4. .env Dosyası Konfigürasyonu

#### SHUFFLE_OPENSEARCH_URL
Varsayılan değer Wazuh'un OpenSearch portunu (9200) gösteriyordu. Shuffle'ın kendi OpenSearch container'ını kullanması için container adıyla değiştirildi:
`SHUFFLE_OPENSEARCH_URL=http://shuffle-opensearch:9200`

#### OUTER_HOSTNAME
Host makineden 127.0.0.1 ile erişildiği için bu değer 127.0.0.1 olarak ayarlandı. 10.0.2.12 olarak kalması login sonrası redirect loop sorununa yol açıyordu.

#### SHUFFLE_OPENSEARCH_PASSWORD
OpenSearch 3.2.0 sürümünden itibaren başlangıç admin şifresi zorunlu hale geldi. docker-compose.yml içinde bu değişken OPENSEARCH_INITIAL_ADMIN_PASSWORD ile map edildiği için .env'e eklenmesi gerekti. Güçlü bir şifre belirlenmeli ve .env dosyası versiyon kontrolüne eklenmemelidir.

#### SHUFFLE_ENCRYPTION_MODIFIER
Bu değişken tanımlı olmadığında workflow'lar kaydedilemiyor, webhook node'ları sayfa yenilemede kayboluyor. Rastgele bir string olarak ayarlandı ve bir kez belirlendikten sonra değiştirilmemesi gerekiyor. Şifre niteliğinde olduğu için .env dosyasına eklenmeli, asla versiyon kontrolüne gönderilmemelidir.

## .env Dosyası Yapısı
.env dosyası /home/soc-server/Shuffle/.env konumundadır ve versiyon kontrolüne eklenmemiştir (.gitignore). Aşağıdaki değişkenleri içermektedir:

- SHUFFLE_OPENSEARCH_URL
- OUTER_HOSTNAME
- FRONTEND_PORT
- FRONTEND_PORT_HTTPS
- BACKEND_PORT
- BACKEND_HOSTNAME
- SHUFFLE_APP_HOTLOAD_LOCATION
- SHUFFLE_FILE_LOCATION
- DB_LOCATION
- OPENSEARCH_INITIAL_ADMIN_PASSWORD
- SHUFFLE_OPENSEARCH_PASSWORD
- SHUFFLE_ENCRYPTION_MODIFIER

## Erişim Bilgileri
- URL: http://127.0.0.1:3001 (host makineden VirtualBox port forwarding ile)
- Admin kullanıcı: admin@soclab.local
- Port forwarding ayarı: Host 3001 → Guest 10.0.2.12:3001

## Wazuh Entegrasyonu
Wazuh'un Shuffle'a alert göndermesi için /var/ossec/etc/ossec.conf dosyasına integration bloğu eklendi. Level 3 ve üzeri tüm alert'ler JSON formatında webhook'a iletiliyor.

Webhook URL'si Shuffle arayüzünden oluşturulan Webhook trigger'dan alınmaktadır. Entegrasyon doğrulaması /var/ossec/logs/integrations.log dosyasından yapıldı. Alert dosyalarının webhook URL'sine gönderildiği logda görüldü.

## Karşılaşılan Sorunlar ve Çözümler
1. OpenSearch 3.2.0 şifre zorunluluğu → SHUFFLE_OPENSEARCH_PASSWORD .env'e eklendi, docker-compose.yml'de OPENSEARCH_INITIAL_ADMIN_PASSWORD ile map ediliyor
2. OpenSearch SSL zorunluluğu → DISABLE_SECURITY_PLUGIN=true ile devre dışı bırakıldı, aksi halde backend HTTP ile bağlanmaya çalışırken EOF hatası alıyordu
3. Login sonrası redirect loop → OUTER_HOSTNAME=127.0.0.1 yapıldı, 10.0.2.12 değeri host makineden erişimde yönlendirme sorununa yol açıyordu
4. Orborus backend'e bağlanamıyor → BASE_URL=http://shuffle-backend:5001 yapıldı, container içinden 127.0.0.1 erişilemiyor
5. OpenSearch heap yetersizliği → 128MB'dan 256MB'a yükseltildi, circuit_breaking_exception: Data too large hatası alınıyordu
6. Workflow kaydedilemiyor, webhook node kayboluyor → SHUFFLE_ENCRYPTION_MODIFIER .env'e eklendi

## Önemli Notlar
- Shuffle container'ları sistem başlangıcında diğer servisler ayağa kalktıktan sonra manuel olarak başlatılmalıdır: `cd /home/soc-server/Shuffle && sudo docker-compose up -d`
- OpenSearch 256MB heap ile bile RAM kısıtlı ortamda GC overhead uyarıları görülebilir, bu normaldir
- SHUFFLE_ENCRYPTION_MODIFIER değeri bir kez belirlendikten sonra kesinlikle değiştirilmemelidir, aksi halde mevcut veriler şifresi çözülemez hale gelir
- .env dosyası .gitignore'a eklenmelidir
