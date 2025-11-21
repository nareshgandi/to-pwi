# to-pwi-monitoring

**Custom PostgreSQL Monitoring Extension for postgres_exporter + Grafana 9628 Dashboard**

This repository contains custom SQL query collectors for `postgres_exporter` to monitor critical PostgreSQL metrics that are **not included by default**, such as wraparound age, freeze lag, locks, bloat, and replication lag.

These custom metrics integrate directly into the **Grafana 9628 PostgreSQL Overview Dashboard**, adding deeper observability for production PostgreSQL systems.

## 📁 Repository Contents

```
to-pwi-monitoring/
└── custom_queries/
    └── my_custom_queries.yml
└── systemd/
    └── postgres_exporter.service.example
└── docs/
    └── setup-guide.md
└── README.md
```

## 🚀 Features

### ✔ Custom SQL queries for critical DB health:
- XID wraparound percentage  
- Autovacuum freeze lag  
- Top 10 bloat tables  
- Lock waits  
- Replication lag  

### ✔ Works with:
- **postgres_exporter**
- **Prometheus**
- **Grafana (Dashboard 9628)**

### ✔ Safe file location (`/etc/postgres_exporter`)
Ensures exporter can read custom query definitions.

## 🛠️ Installation Guide

### 1️⃣ Move the Custom Query File to a Readable System Location

```bash
sudo mkdir -p /etc/postgres_exporter
sudo cp /root/customqueries/my_custom_queries.yml /etc/postgres_exporter/
sudo chmod 644 /etc/postgres_exporter/my_custom_queries.yml
```

### 2️⃣ Update `postgres_exporter` Systemd Service

Edit:

```bash
sudo vi /etc/systemd/system/postgres_exporter.service
```

Replace old path:

```
--extend.query-path="/root/customqueries"
```

With:

```
--extend.query-path="/etc/postgres_exporter/my_custom_queries.yml"
```

Final ExecStart:

```bash
ExecStart=/usr/local/bin/postgres_exporter   --web.listen-address=":9187"   --extend.query-path="/etc/postgres_exporter/my_custom_queries.yml"
```

### 3️⃣ Reload systemd and Restart Exporter

```bash
sudo systemctl daemon-reload
sudo systemctl restart postgres_exporter
```

### 4️⃣ Verify Custom Metrics Are Loaded

```bash
curl -s http://localhost:9187/metrics | grep -i custom
```

## 📊 Grafana 9628 Dashboard Integration

Metrics available:
- `pg_health_wraparound_percent_pct_wraparound`
- `pg_health_bloat_bloat_pct`
- `pg_health_lock_waits_total_waiting`
- `pg_health_replication_lag_lag_seconds`

Add as new panels inside Dashboard 9628.

## 📝 Example Custom Query Snippet (YAML)

```yaml
pg_health_wraparound_percent:
  query: |
    SELECT age(datfrozenxid) AS xid_age FROM pg_database LIMIT 1;
  metrics:
    - xid_age:
        usage: "GAUGE"
        description: "Age of oldest XID"
```

## ❗ Troubleshooting

**Error:** `pg_exporter_user_queries_load_error`  
Fix:
- Check YAML indentation  
- Ensure file is readable  
- Ensure exporter points to file, not directory  
- Restart service after edits  

## 📢 Contributing

PRs are welcome!

## 📜 License

MIT License
