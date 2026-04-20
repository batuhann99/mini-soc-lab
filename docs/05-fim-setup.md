# File Integrity Monitoring (FIM)

## FIM Nedir?
File Integrity Monitoring, belirlenen dizinlerdeki dosya değişikliklerini (oluşturma, silme, değiştirme) gerçek zamanlı izler ve alarm üretir.

## Konfigürasyon

Windows agent `ossec.conf` dosyasındaki `<syscheck>` bölümüne eklenen dizinler:

```xml
<directories realtime="yes" check_sha256="yes">C:\Users\batu\Desktop</directories>
<directories realtime="yes" check_sha256="yes">C:\Users\batu\Documents</directories>
<directories realtime="yes" check_sha256="yes">C:\Windows\System32\drivers\etc</directories>
```

## İzlenen Dizinler ve Amaçları

| Dizin | Amaç |
|---|---|
| C:\Users\batu\Desktop | Kullanıcı masaüstündeki değişiklikleri izle |
| C:\Users\batu\Documents | Kullanıcı belgelerindeki değişiklikleri izle |
| C:\Windows\System32\drivers\etc | hosts dosyası gibi kritik sistem dosyalarını izle |

## Test Sonuçları

Masaüstüne test dosyası oluşturulduğunda:
- **Rule 554** (Level 5): File added to the system ✅
- **Rule 550** (Level 7): Integrity checksum changed ✅

FIM, dosya oluşturma ve değişiklikleri başarıyla tespit etmektedir.
