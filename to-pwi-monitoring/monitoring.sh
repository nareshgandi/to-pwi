#!/bin/bash
set -e

# ONE CLICK MONITORING STACK FOR TEACHING PURPOSES
# CentOS 9 - Prometheus + Grafana + Node Exporter + Postgres Exporter + Dashboard 9628

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root!"
  exit 1
fi

PROM_PORT=9090
GRAFANA_PORT=3000
NODE_PORT=9100
PG_EXP_PORT=9187

echo "=== Installing Dependencies ==="
dnf install -y wget curl tar > /dev/null

# -------------------------------
# Node Exporter
# -------------------------------
echo "Installing Node Exporter..."
NODE_VER=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep tag_name | cut -d '"' -f 4)

cd /tmp
wget -q https://github.com/prometheus/node_exporter/releases/download/${NODE_VER}/node_exporter-${NODE_VER#v}.linux-amd64.tar.gz
tar -xf node_exporter-${NODE_VER#v}.linux-amd64.tar.gz
cp node_exporter-${NODE_VER#v}.linux-amd64/node_exporter /usr/local/bin/

cat >/etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter --web.listen-address=":${NODE_PORT}"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now node_exporter

# -------------------------------
# Postgres Exporter (prometheus-community)
# -------------------------------
echo "Installing postgres_exporter..."
PGE_URL=$(curl -s https://api.github.com/repos/prometheus-community/postgres_exporter/releases/latest | grep "browser_download_url" | grep linux-amd64 | cut -d '"' -f 4)

wget -q $PGE_URL -O postgres_exporter.tar.gz
tar -xf postgres_exporter.tar.gz
EXPORTER_DIR=$(find . -maxdepth 1 -type d -name "postgres_exporter*" | head -1)
cp $EXPORTER_DIR/postgres_exporter /usr/local/bin/

cat >/etc/systemd/system/postgres_exporter.service <<EOF
[Unit]
Description=Postgres Exporter

[Service]
Environment="DATA_SOURCE_NAME=postgresql://postgres@localhost:5432/postgres?sslmode=disable"
ExecStart=/usr/local/bin/postgres_exporter --web.listen-address=":${PG_EXP_PORT}"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now postgres_exporter

# -------------------------------
# Prometheus
# -------------------------------
echo "Installing Prometheus..."
PROM_VER=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep tag_name | cut -d '"' -f 4)

cd /tmp
wget -q https://github.com/prometheus/prometheus/releases/download/${PROM_VER}/prometheus-${PROM_VER#v}.linux-amd64.tar.gz
tar -xf prometheus-${PROM_VER#v}.linux-amd64.tar.gz

PROM_DIR=prometheus-${PROM_VER#v}.linux-amd64

cp $PROM_DIR/prometheus /usr/local/bin/
cp $PROM_DIR/promtool /usr/local/bin/

mkdir -p /etc/prometheus /var/lib/prometheus

if [ -d "$PROM_DIR/consoles" ]; then
    cp -r $PROM_DIR/consoles /etc/prometheus/
    cp -r $PROM_DIR/console_libraries /etc/prometheus/
else
    echo "Prometheus 3.x: No consoles directory, skipping copy"
fi

cat >/etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: node
    static_configs:
      - targets: ['localhost:${NODE_PORT}']

  - job_name: postgres
    static_configs:
      - targets: ['localhost:${PG_EXP_PORT}']
EOF

cat >/etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus

[Service]
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now prometheus

# -------------------------------
# Grafana + auto-import dashboard 9628
# -------------------------------
echo "Installing Grafana..."
cat >/etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=Grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
EOF

dnf install -y grafana > /dev/null
systemctl enable --now grafana-server

sleep 8  # give Grafana time to boot

echo "Waiting for Grafana to become ready..."
until curl -s http://admin:admin@localhost:3000/api/health | grep -q '"database":'; do
  echo "Waiting..."
  sleep 3
done
echo "Grafana Ready ✔"

# Force session into Main Org (Org 1)
curl -s -X POST http://admin:admin@localhost:3000/api/user/using/1 >/dev/null

# -------------------------------------------------------
# 1. Create Prometheus datasource
# -------------------------------------------------------
echo "Creating Prometheus datasource..."
curl -s -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
        "name": "Prometheus",
        "type": "prometheus",
        "access": "proxy",
        "url": "http://localhost:9090"
      }' >/dev/null

# Verify datasource exists
DS_CHECK=$(curl -s http://admin:admin@localhost:3000/api/datasources | grep Prometheus || true)
if [[ -z "$DS_CHECK" ]]; then
  echo "❌ Datasource creation failed."
  exit 1
else
  echo "Prometheus datasource created ✔"
fi

# -------------------------------------------------------
# 2. Create an empty dashboard (forces proper org init)
# -------------------------------------------------------
echo "Creating temporary dashboard (for org init)..."
curl -s -X POST http://admin:admin@localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d '{
        "dashboard": {
          "uid": "temp_dash",
          "title": "TEMP_DASH",
          "panels": []
        },
        "folderId": 0,
        "overwrite": true
      }' >/dev/null

echo "Temporary dashboard created ✔"

# -------------------------------------------------------
# 3. Import dashboards
# -------------------------------------------------------

import_dashboard () {
  ID=$1
  echo "Importing dashboard $ID..."
  curl -s -X POST http://admin:admin@localhost:3000/api/dashboards/import \
    -H "Content-Type: application/json" \
    -d "{
          \"dashboard\": $(curl -s https://grafana.com/api/dashboards/${ID}/revisions/1/download),
          \"overwrite\": true,
          \"folderId\": 0,
          \"inputs\": [
            {
              \"name\": \"DS_PROMETHEUS\",
              \"type\": \"datasource\",
              \"pluginId\": \"prometheus\",
              \"value\": \"Prometheus\"
            }
          ]
        }" >/dev/null
  echo "✔ Dashboard $ID imported"
}

import_dashboard 9628
import_dashboard 12485
import_dashboard 13115
import_dashboard 14114
echo "All dashboards imported successfully!"


# Clean up temp dashboard
echo "Removing temporary dashboard..."
curl -s -X DELETE http://admin:admin@localhost:3000/api/dashboards/uid/temp_dash >/dev/null

echo ""
echo "=================================================="
echo " ✔ ONE-CLICK Monitoring Installed!"
echo "--------------------------------------------------"
echo "Grafana      → http://$IP:3000  (admin/admin)"
echo "Prometheus   → http://$IP:9090"
echo "Node Exporter → http://$IP:9100/metrics"
echo "Postgres Exporter → http://$IP:9187/metrics"
echo "Dashboard 9628 imported automatically ✔"
echo "=================================================="
