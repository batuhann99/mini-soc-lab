#!/bin/bash
echo "=== Starting SOC Lab Services ==="

echo "[1/6] Starting Cassandra..."
sudo systemctl start cassandra
sleep 30

echo "[2/6] Starting Wazuh Indexer..."
sudo systemctl start wazuh-indexer
sleep 60

echo "[3/6] Starting Elasticsearch..."
sudo systemctl start elasticsearch
sleep 30

echo "[4/6] Starting Wazuh Manager..."
sudo systemctl start wazuh-manager
sleep 10

echo "[5/6] Starting Wazuh Dashboard..."
sudo systemctl start wazuh-dashboard
sleep 10

echo "[6/6] Starting TheHive..."
sudo systemctl start thehive
sleep 10

echo "=== Checking Services ==="
for svc in cassandra wazuh-indexer elasticsearch wazuh-manager wazuh-dashboard thehive; do
  status=$(systemctl is-active $svc)
  echo "$svc: $status"
done

echo ""
echo "=== Checking Ports ==="
ss -tlnp | grep -E "9000|9200|9201|443"
echo ""
free -h
echo "=== Done ==="
