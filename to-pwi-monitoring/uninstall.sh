#!/bin/bash
set -e

echo "=== UNINSTALLING PROMETHEUS + GRAFANA + EXPORTERS ==="

# Stop services if they exist
systemctl stop grafana-server 2>/dev/null || true
systemctl stop prometheus 2>/dev/null || true
systemctl stop node_exporter 2>/dev/null || true
systemctl stop postgres_exporter 2>/dev/null || true

# Disable them
systemctl disable grafana-server 2>/dev/null || true
systemctl disable prometheus 2>/dev/null || true
systemctl disable node_exporter 2>/dev/null || true
systemctl disable postgres_exporter 2>/dev/null || true

echo "--- Removing systemd service files ---"
rm -f /etc/systemd/system/node_exporter.service
rm -f /etc/systemd/system/postgres_exporter.service
rm -f /etc/systemd/system/prometheus.service
rm -f /etc/systemd/system/grafana-server.service 2>/dev/null

systemctl daemon-reload

echo "--- Removing binaries ---"
rm -f /usr/local/bin/node_exporter
rm -f /usr/local/bin/postgres_exporter
rm -f /usr/local/bin/prometheus
rm -f /usr/local/bin/promtool

echo "--- Removing Prometheus directories ---"
rm -rf /etc/prometheus
rm -rf /var/lib/prometheus

echo "--- Removing Grafana ---"
dnf remove -y grafana || true
rm -f /etc/yum.repos.d/grafana.repo

echo "--- Removing leftover folders ---"
rm -rf /tmp/node_exporter*
rm -rf /tmp/postgres_exporter*
rm -rf /tmp/prometheus*

echo "--- Removing firewall rules (if any) ---"
firewall-cmd --remove-port=3000/tcp --permanent 2>/dev/null || true
firewall-cmd --remove-port=9090/tcp --permanent 2>/dev/null || true
firewall-cmd --remove-port=9100/tcp --permanent 2>/dev/null || true
firewall-cmd --remove-port=9187/tcp --permanent 2>/dev/null || true
firewall-cmd --reload 2>/dev/null || true

echo "================================================="
echo " ✔ COMPLETE! All monitoring components removed."
echo "================================================="

