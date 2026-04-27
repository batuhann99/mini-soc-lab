# TheHive 5 Kurulumu

## Bağımlılıklar
- Java 11 (OpenJDK)
- Apache Cassandra 4.1.x
- Elasticsearch 7.17.x (port 9201, Wazuh Indexer ile çakışmayı önlemek için)

## Kurulum Adımları

### Cassandra
Cassandra varsayılan ayarlarla kuruldu. Heap size RAM kısıtı nedeniyle 512MB olarak ayarlandı.

### Elasticsearch
Elasticsearch 7.17.29 kuruldu. Wazuh Indexer port 9200 kullandığı için Elasticsearch port 9201'e alındı. Heap size 256MB, xpack.security devre dışı, discovery.type single-node olarak ayarlandı.

### TheHive 5.7.0
DEB paketi doğrudan StrangeBee download sayfasından indirildi (apt repo artık mevcut değil).

Konfigürasyon: `/etc/thehive/application.conf`
- Cassandra bağlantısı: 127.0.0.1:9042, cluster: thp, keyspace: thehive
- Elasticsearch bağlantısı: 127.0.0.1:9201
- Storage: /opt/thp/thehive/files
- Web arayüzü: http://10.0.2.12:9000

### RAM Optimizasyonu
8GB host RAM ile tüm servislerin çalışması için swap ve heap ayarları yapıldı:
- 2GB swap dosyası eklendi
- Cassandra heap: 512MB
- Elasticsearch heap: 256MB
- Wazuh Indexer heap: 512MB

## Erişim Bilgileri
- URL: http://10.0.2.12:9000
- Varsayılan kullanıcı: admin@thehive.local / secret
- Organization: MiniSOC-Lab
- Analyst kullanıcı: analyst@thehive.local

## Karşılaşılan Sorunlar ve Çözümler
1. StrangeBee apt repo erişilemez → DEB paketi doğrudan indirildi
2. Elasticsearch OOM → Heap 256MB'a düşürüldü
3. Port çakışması (Wazuh Indexer 9200) → Elasticsearch 9201'e alındı
4. TheHive secret key hatası → 256-bit üzeri key belirlendi
5. Config syntax hatası → Parantez düzeltildi
6. hostname formatında port belirtme → hostname = ["127.0.0.1:9201"]

## Önemli: Wazuh OpenSearch Entegrasyonu

Standalone Elasticsearch yerine Wazuh'un dahili OpenSearch motoru kullanılmaktadır.
Bu sayede bir JVM process'i ortadan kalkmış ve ~500MB RAM tasarrufu sağlanmıştır.

TheHive config'inde index.search bölümü:
- Backend: elasticsearch
- Hostname: 127.0.0.1
- Port: 9200 (Wazuh OpenSearch)
- SSL: enabled, trust-all
- Auth: basic (admin / Wazuh dashboard şifresi)

Manuel index oluşturma gerekli:
- thehive_global
- thehive_vertex  
- thehive_edge
