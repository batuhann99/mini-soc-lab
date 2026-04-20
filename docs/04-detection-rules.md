# Custom Detection Kuralları

## Kurallar Dosyası
Konum: `/var/ossec/etc/rules/local_rules.xml`

## Kural Listesi

### Kural 100001 — Brute Force Detection
- **Level:** 10
- **MITRE ATT&CK:** T1110 (Brute Force)
- **Açıklama:** 60 saniye içinde 5+ başarısız login denemesi tespit eder
- **Tetikleyici:** Windows logon failure event'leri

### Kural 100002 — Mimikatz Detection
- **Level:** 14 (Critical)
- **MITRE ATT&CK:** T1003 (OS Credential Dumping)
- **Açıklama:** Mimikatz process çalıştırmasını Sysmon üzerinden tespit eder
- **Tetikleyici:** Sysmon Event 1 — originalFileName alanında "mimikatz"

### Kural 100003 — Suspicious PowerShell
- **Level:** 12 (High)
- **MITRE ATT&CK:** T1059.001 (PowerShell)
- **Açıklama:** Şüpheli PowerShell komutlarını tespit eder
- **Tetikleyici:** EncodedCommand, Invoke-Expression, DownloadString, bypass gibi anahtar kelimeler

### Kural 100004 — Port Scan Detection
- **Level:** 10
- **MITRE ATT&CK:** T1046 (Network Service Scanning)
- **Açıklama:** Yaygın servis portlarına (445, 3389, 22, 80 vb.) bağlantı denemelerini tespit eder
- **Test Sonucu:** ✅ Başarıyla tetiklendi

### Kural 100005 — New Service Installation
- **Level:** 12 (High)
- **MITRE ATT&CK:** T1543.003 (Windows Service)
- **Açıklama:** Yeni Windows servisi kurulumunu tespit eder — persistence tekniği olabilir

### Kural 100006 — Scheduled Task Creation
- **Level:** 10
- **MITRE ATT&CK:** T1053.005 (Scheduled Task)
- **Açıklama:** schtasks.exe ile yeni görev oluşturulmasını tespit eder
- **Test Sonucu:** ✅ Başarıyla tetiklendi

## Kuralların Deploy Edilmesi
```bash
# Kuralları indir
sudo curl -o /var/ossec/etc/rules/local_rules.xml https://raw.githubusercontent.com/batuhann99/mini-soc-lab/main/configs/wazuh/local_rules.xml

# Wazuh Manager restart
sudo systemctl restart wazuh-manager
```
