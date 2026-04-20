# Sysmon Kurulumu & Wazuh Entegrasyonu

## Sysmon Nedir?
Sysmon (System Monitor), Windows'un varsayılan loglarından çok daha detaylı bilgi toplayan bir Microsoft Sysinternals aracıdır. Process oluşturma, network bağlantıları, dosya değişiklikleri gibi olayları detaylı şekilde loglar.

## Kurulum Adımları

### 1. Sysmon İndir
- Sysmon: https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon
- Config: https://github.com/SwiftOnSecurity/sysmon-config

### 2. Sysmon Kur
```powershell
cd C:\Sysmon
.\Sysmon64.exe -accepteula -i sysmonconfig-export.xml
```

### 3. Kurulum Doğrulama
```powershell
Get-Service Sysmon64
# Status: Running
```

## Wazuh Agent Konfigürasyonu

Wazuh agent'ın Sysmon loglarını toplaması için `ossec.conf` dosyasına şu eklendi:

```xml
<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

Agent restart:
```powershell
Restart-Service WazuhSvc
```

## Sonuç
Sysmon event'leri Wazuh Dashboard'da başarıyla görüntülenmektedir (rule.id: 92066).
