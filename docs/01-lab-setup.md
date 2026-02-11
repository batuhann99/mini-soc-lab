# Lab Ortamı Kurulumu

## Mimari

Tüm sanal makineler VirtualBox üzerinde çalışmaktadır ve NAT Network (10.0.2.0/24) ile birbirine bağlıdır.

| VM | OS | RAM | CPU | IP | Rol |
|---|---|---|---|---|---|
| SOC-Server | Ubuntu Server 22.04 | 4 GB | 2 | 10.0.2.12 | Wazuh Manager + Dashboard |
| mywindows | Windows 10 Pro | 2 GB | 2 | 10.0.2.8 | Victim Endpoint |
| Kali Linux | Kali 2025.2 | 2 GB | 2 | 10.0.2.7 | Attacker |

## Ağ Yapılandırması

- Network tipi: NAT Network (NatNetwork)
- Subnet: 10.0.2.0/24
- Gateway: 10.0.2.1
- Tüm VM'ler birbirine erişebilir durumda
- Windows Firewall'da ICMPv4 kuralı eklendi

## Kurulum Notları

- Ubuntu Server minimal kurulum ile kuruldu
- OpenSSH server kurulum sonrası manuel eklendi: `sudo apt install openssh-server -y`
- Windows Firewall ping kuralı: `netsh advfirewall firewall add rule name="Allow ICMPv4" protocol=icmpv4:8,any dir=in action=allow`
