# Wazuh SIEM Kurulumu

## Wazuh Manager (All-in-One) Kurulumu

Wazuh Manager, Indexer ve Dashboard tek bir sunucuya kurulmuştur.

### Kurulum Adımları

1. Sistemi güncelle:
```bash
   sudo apt update && sudo apt upgrade -y
```

2. Wazuh kurulum script'ini indir ve çalıştır:
```bash
   curl -sO https://packages.wazuh.com/4.11/wazuh-install.sh
   sudo bash wazuh-install.sh -a
```

3. Kurulum tamamlandığında admin şifresi ekranda görüntülenir.

4. Dashboard erişimi: `https://10.0.2.12`

### Kurulum Sonucu
- Wazuh Manager: aktif
- Wazuh Indexer: aktif
- Wazuh Dashboard: aktif (port 443)

## Windows Agent Kurulumu

### Kurulum Adımları

1. PowerShell'i Administrator olarak aç

2. Agent'ı indir ve kur:
```powershell
   Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.11.2-1.msi -OutFile $env:tmp\wazuh-agent; msiexec.exe /i $env:tmp\wazuh-agent /q WAZUH_MANAGER='10.0.2.12' WAZUH_AGENT_NAME='windows-victim'
```

3. Agent servisini başlat:
```powershell
   NET START WazuhSvc
```

### Doğrulama
- Agent adı: windows-victim
- Agent ID: 001
- Durum: Active
- OS: Microsoft Windows 10 Pro 10.0.19045.3803

## İlk Tespit Testi

Başarısız login denemeleri ile Wazuh'un olay tespiti doğrulandı:
- 6 Authentication Failure tespit edildi
- 16 Authentication Success loglandı
- Toplam 448 event toplandı
```
