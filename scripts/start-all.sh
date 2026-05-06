#!/bin/bash
# SOC Lab Start Script - Updated
# Services: Cassandra → Wazuh Indexer → Wazuh Manager → Wazuh Dashboard → TheHive → Shuffle

set -e

echo "======================================"
echo "      SOC Lab - Starting Services     "
echo "======================================"
echo ""

echo "[1/6] Starting Cassandra..."
sudo systemctl start cassandra
echo "      Waiting 40s for Cassandra to settle..."
sleep 40

echo "[2/6] Starting Wazuh Indexer..."
sudo systemctl start wazuh-indexer
echo "      Waiting 60s for Indexer to settle..."
sleep 60

echo "[3/6] Starting Wazuh Manager..."
sudo systemctl start wazuh-manager
sleep 15

echo "[4/6] Starting Wazuh Dashboard..."
sudo systemctl start wazuh-dashboard
sleep 15

echo "[5/6] Starting TheHive..."
sudo systemctl start thehive
echo "      TheHive needs ~8 minutes to fully start. Waiting in background..."
echo "      (Pipeline continues, TheHive port 9000 will open later)"

echo "[6/6] Starting Shuffle (Docker)..."
cd /home/soc-server/Shuffle && sudo docker-compose up -d
cd ~

echo ""
echo "======================================"
echo "         Service Status Check         "
echo "======================================"
for svc in cassandra wazuh-indexer wazuh-manager wazuh-dashboard thehive; do
  status=$(systemctl is-active $svc)
  if [ "$status" = "active" ]; then
    echo "  ✓ $svc: $status"
  else
    echo "  ✗ $svc: $status  <-- PROBLEM"
  fi
done

echo ""
echo "  Docker containers:"
sudo docker ps --format "  ✓ {{.Names}}: {{.Status}}" | grep shuffle

echo ""
echo "======================================"
echo "           Port Status                "
echo "======================================"
echo "  Open ports:"
ss -tlnp | grep -E "9000|9200|3001|5001|443" | awk '{print "  " $4}'

echo ""
echo "======================================"
echo "           Memory Status              "
echo "======================================"
free -h

echo ""
echo "======================================"
echo "  Access URLs (from HOST machine):    "
echo "    TheHive  → http://127.0.0.1:9000  "
echo "    Shuffle  → http://127.0.0.1:3001  "
echo "    Wazuh    → https://127.0.0.1:8443 "
echo ""
echo "  NOTE: TheHive port 9000 may take    "
echo "  up to 8 minutes to open!            "
echo "======================================"
