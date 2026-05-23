# 🛡️ Mini SOC Lab — Home Lab Security Operations Center Simulation

A fully functional Security Operations Center (SOC) simulation built on a home lab environment using VirtualBox. This project demonstrates real-world SOC capabilities including threat detection, log management, security automation, and incident response workflows.

## 📋 Project Overview

This lab simulates a production SOC environment with three core platforms working in an integrated pipeline:

- **Wazuh SIEM** — Collects, analyzes, and correlates security events from endpoints
- **TheHive** — Case management and incident response platform
- **Shuffle SOAR** — Security orchestration and automated response workflows

### Architecture
+------------------+     +------------------+     +------------------+
|   Windows 10     |     |   SOC-Server     |     |   Kali Linux     |
|   (Endpoint)     |     |   (Ubuntu 22.04) |     |   (Attacker)     |
|                  |     |                  |     |                  |
|  Wazuh Agent     +---->+  Wazuh Manager   |     |  nmap            |
|  Sysmon v15      |     |  Wazuh Indexer   |     |  hydra           |
|                  |     |  Wazuh Dashboard |     |  metasploit      |
+------------------+     |                  |     +------------------+
|  TheHive 5.7     |
|  Shuffle SOAR    |
|  OpenSearch      |
|  Cassandra       |
+--------+---------+
|
+--------v---------+
|   Alert Pipeline  |
|                  |
|  Wazuh Alert     |
|      ↓           |
|  Shuffle Webhook |
|      ↓           |
|  TheHive Case    |
+------------------+

## 🖥️ Lab Environment

| Component | Specs |
|-----------|-------|
| Host OS | Windows 10 |
| Host RAM | 8GB |
| Hypervisor | Oracle VirtualBox |
| Network | NAT Network (10.0.2.0/24) |

| VM | OS | RAM | IP | Role |
|----|-----|-----|-----|------|
| SOC-Server | Ubuntu Server 22.04 | 5GB | 10.0.2.12 | SIEM + SOAR + Case Management |
| mywindows | Windows 10 Pro | 2GB | 10.0.2.8 | Monitored Endpoint |
| Kali Linux | Kali 2024 | 2GB | 10.0.2.7 | Attacker Simulation |

## 🔧 Installed Components

### SOC-Server
- **Wazuh 4.x** (All-in-One: Manager + Indexer + Dashboard)
- **TheHive 5.7.0** (Incident Response Platform)
- **Apache Cassandra 4.1.x** (TheHive database backend)
- **Shuffle SOAR** (Docker Compose deployment)
- **OpenSearch 3.2** (Shuffle database backend)
- **2GB Swap** (RAM optimization)

### Windows Endpoint
- **Wazuh Agent** (Active, reporting to SOC-Server)
- **Sysmon v15.15** (SwiftOnSecurity config)

## ✅ Completed Features

### 1. Wazuh SIEM
- Full Wazuh stack deployed and operational
- Windows 10 endpoint monitored with active agent
- Real-time event collection and correlation
- Custom dashboard configuration

### 2. Sysmon Integration
- Sysmon v15.15 installed with SwiftOnSecurity ruleset
- Sysmon events forwarded to Wazuh (Event ID mapping)
- Process creation, network connections, file changes monitored

### 3. Custom Detection Rules (MITRE ATT&CK Mapped)
6 custom Wazuh detection rules implemented in `configs/wazuh/local_rules.xml`:

| Rule ID | Name | MITRE Technique | Status |
|---------|------|-----------------|--------|
| 100001 | Brute Force Detection | T1110 | ✅ Active |
| 100002 | Mimikatz Detection | T1003 | ✅ Active |
| 100003 | Suspicious PowerShell | T1059.001 | ✅ Active |
| 100004 | Port Scan Detection | T1046 | ✅ Tested |
| 100005 | New Service Installation | T1543.003 | ✅ Active |
| 100006 | Scheduled Task Creation | T1053.005 | ✅ Tested |

### 4. File Integrity Monitoring (FIM)
- FIM configured on critical Windows directories
- Real-time file creation, modification, deletion alerts
- Rules 550 and 554 triggering correctly

### 5. Wazuh → Shuffle SOAR Pipeline
- Shuffle SOAR deployed via Docker Compose
- Wazuh integration configured in ossec.conf
- Webhook trigger receiving Wazuh alerts in real-time
- Alert data (rule ID, severity, timestamp, description) successfully parsed in Shuffle workflow
- Verified via integrations.log and Shuffle execution history

### 6. TheHive Case Management
- TheHive 5.7.0 deployed with Cassandra backend
- Integrated with Wazuh's internal OpenSearch (port 9200)
- Accessible at http://10.0.2.12:9000
- Organization and analyst user configured

## ⚠️ Known Limitations

### TheHive Community License
TheHive 5.x community edition restricts operational features to non-admin organizations. Due to license quota limitations (0 additional organizations allowed), alert creation via API is blocked in the admin organization. 

**Workaround options:**
- Upgrade to TheHive 5 community with valid license registration
- Migrate to TheHive 4.x (different license model, fully functional in community edition)
- Use direct Wazuh → Shuffle pipeline without TheHive integration

### RAM Constraints
With only 8GB host RAM, running all VMs simultaneously causes performance issues. The following optimizations were applied:
- Cassandra heap limited to 512MB
- Wazuh Indexer heap limited to 512MB  
- Shuffle OpenSearch heap limited to 256MB
- 2GB swap added to SOC-Server
- Kali Linux only started when needed for attack simulations
- Windows VM accessed via host port forwarding instead of direct VM GUI

## 📁 Repository Structure
mini-soc-lab/
├── configs/
│   └── wazuh/
│       └── local_rules.xml       # Custom MITRE ATT&CK detection rules
├── docs/
│   ├── 01-lab-setup.md           # VirtualBox and VM configuration
│   ├── 02-wazuh-setup.md         # Wazuh SIEM installation guide
│   ├── 03-sysmon-setup.md        # Sysmon installation and Wazuh integration
│   ├── 04-detection-rules.md     # Custom detection rules documentation
│   ├── 05-fim-setup.md           # File Integrity Monitoring setup
│   ├── 06-thehive-setup.md       # TheHive installation and configuration
│   └── 07-shuffle-setup.md       # Shuffle SOAR installation and integration
├── scripts/
│   └── start-all.sh              # Service startup script with correct ordering
└── README.md

## 🚀 Quick Start

### Service Startup Order
Due to service dependencies, the following startup order must be followed:

```bash
# Run the automated startup script
./start-all.sh
```

Manual order if needed:
1. Cassandra (wait 40s)
2. Wazuh Indexer (wait 60s)
3. Wazuh Manager (wait 15s)
4. Wazuh Dashboard (wait 15s)
5. TheHive (wait ~8 minutes for full initialization)
6. Shuffle Docker containers

### Access URLs (from host machine via port forwarding)
| Service | URL | Credentials |
|---------|-----|-------------|
| Wazuh Dashboard | https://127.0.0.1:8443 | admin / [see docs] |
| TheHive | http://127.0.0.1:9000 | admin@thehive.local / secret |
| Shuffle | http://127.0.0.1:3001 | admin@soclab.local / [set during setup] |

## 🔗 Alert Pipeline Flow
Wazuh Agent (Windows)
│
│ Sysmon Events + Windows Logs
▼
Wazuh Manager (SOC-Server)
│
│ Matched against custom rules (level ≥ 3)
▼
Shuffle SOAR (Webhook)
│
│ Alert enrichment + workflow execution
▼
TheHive (Case Creation) ⚠️ Limited by community license

## 🛠️ Technologies Used

| Technology | Version | Purpose |
|-----------|---------|---------|
| Wazuh | 4.x | SIEM / EDR |
| TheHive | 5.7.0 | Case Management |
| Shuffle | Latest | SOAR |
| Apache Cassandra | 4.1.x | TheHive Database |
| OpenSearch | 3.2 | Shuffle Database |
| Sysmon | 15.15 | Windows Telemetry |
| Docker | Latest | Shuffle Deployment |
| Ubuntu Server | 22.04 LTS | SOC Server OS |

## 📚 Documentation

Detailed setup guides for each component are available in the `docs/` directory. Each document covers installation steps, configuration, encountered issues, and solutions.

## 🎯 Skills Demonstrated

- SIEM deployment and configuration
- Security event correlation and custom rule writing
- MITRE ATT&CK framework mapping
- SOAR workflow automation
- Incident response platform integration
- Linux server administration
- Docker container management
- Network security monitoring
- File Integrity Monitoring
- Windows endpoint security (Sysmon)
