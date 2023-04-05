sudo useradd --no-create-home --shell /bin/false prometheus
# sudo useradd --no-create-home --shell /bin/false node_exporter

sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

cd ~
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.43.0/prometheus-2.43.0.linux-amd64.tar.gz

tar xvf prometheus-2.43.0.linux-amd64.tar.gz

sudo cp prometheus-2.43.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.43.0.linux-amd64/promtool /usr/local/bin/

sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo cp -r prometheus-2.43.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.43.0.linux-amd64/console_libraries /etc/prometheus

sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries

rm -rf prometheus-2.43.0.linux-amd64.tar.gz prometheus-2.43.0.linux-amd64

cat <<EOF >>/tmp/prometheus.yml
# global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# A scrape configuration containing exactly one endpoint to scrape:
scrape_configs:
  - job_name: 'prometheus'
    scheme: https
    scrape_interval: 5s
    static_configs:
      - targets: ['adb-dp-418492329278776.16.azuredatabricks.net']
    metrics_path: '/driver-proxy/o/418492329278776/0404-104332-hs7kjtrx/40001/metrics/executors/prometheus/'
    basic_auth:
      username: 925971
      password: glc_eyJvIjoiODI4NjQ5IiwibiI6ImRiX2dyYWZhbmFfdG9rZW4iLCJrIjoiOGk5aG5BMzY1czhuNXAyQlBCYjJiOGVtIiwibSI6eyJyIjoicHJvZC1hcC1zb3V0aC0wIn19

EOF

sudo cp /tmp/prometheus.yml /etc/prometheus/prometheus.yml
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

cat <<EOF >>/tmp/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

EOF

sudo cp /tmp/prometheus.service /etc/systemd/system/prometheus.service

sudo systemctl enable prometheus
sudo systemctl start prometheus