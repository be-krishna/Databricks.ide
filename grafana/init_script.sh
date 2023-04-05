#!/bin/bash

export ENV_ENVIRONMENT="dev"
export ENV_BU="xyz"
echo export NAMESPACE="ba-databricks" >> /databricks/spark/conf/spark-env.sh
echo export CLUSTER_NAME="\"${DB_CLUSTER_NAME}\"" >> /databricks/spark/conf/spark-env.sh
echo export INSTANCE_TYPE="\"${DB_INSTANCE_TYPE}\"" >> /databricks/spark/conf/spark-env.sh
echo export CLUSTER_ID="\"${DB_CLUSTER_ID}\"" >> /databricks/spark/conf/spark-env.sh
echo export IS_DRIVER="\"${DB_IS_DRIVER}\"" >> /databricks/spark/conf/spark-env.sh

source /databricks/spark/conf/spark-env.sh

curl -O -L "https://github.com/grafana/agent/releases/download/v0.32.1/grafana-agent-linux-amd64.zip"

# extract the binary
unzip "grafana-agent-linux-amd64.zip"

# make sure it is executable
chmod a+x "grafana-agent-linux-amd64"

sudo cp grafana-agent-linux-amd64 /usr/local/bin
 
cat <<EOF >>/tmp/grafana-agent.yaml
integrations:
  node_exporter:
    enabled: true
    relabel_configs:
    - replacement: CLUSTER_NAME
      source_labels:
      - __address__
      target_label: cluster_name
    - replacement: ENV_ENVIRONMENT
      source_labels:
      - __address__
      target_label: environment
    - replacement: ENV_BU
      source_labels:
      - __address__
      target_label: organization_unit
    - replacement: INSTANCE_TYPE
      source_labels:
      - __address__
      target_label: type 
    - replacement: NAMESPACE
      source_labels:
      - __address__
      target_label: namespace
  prometheus_remote_write:
  - basic_auth:
      password:  glc_eyJvIjoiODI4NjQ5IiwibiI6ImRiX2dyYWZhbmFfdG9rZW4iLCJrIjoiOGk5aG5BMzY1czhuNXAyQlBCYjJiOGVtIiwibSI6eyJyIjoicHJvZC1hcC1zb3V0aC0wIn19
      username:  925971
    url: https://prometheus-prod-26-prod-ap-south-0.grafana.net/api/prom/push
logs:
  configs:
  - clients:
    - basic_auth:
        password: glc_eyJvIjoiODI4NjQ5IiwibiI6ImRiX2dyYWZhbmFfdG9rZW4iLCJrIjoiOGk5aG5BMzY1czhuNXAyQlBCYjJiOGVtIiwibSI6eyJyIjoicHJvZC1hcC1zb3V0aC0wIn19
        username: 461954
      url: logs-prod-014.grafana.net/api/prom/push
    name: integrations
    positions:
      filename: /tmp/positions.yaml
    scrape_configs:
    - job_name: integrations/node_exporter_journal_scrape
      journal:
        labels:
          cluster_name: CLUSTER_NAME
          environment: ENV_ENVIRONMENT
          organization_unit: ENV_BU
          type: INSTANCE_TYPE
          namespace: NAMESPACE
          job: integrations/node_exporter
        max_age: 24h
      relabel_configs:
      - source_labels:
        - __journal__systemd_unit
        target_label: unit
      - source_labels:
        - __journal__boot_id
        target_label: boot_id
      - source_labels:
        - __journal__transport
        target_label: transport
      - source_labels:
        - __journal_priority_keyword
        target_label: level
    target_config:
      sync_period: 15s
metrics:
  wal_directory: /tmp/grafana-agent-wal
  configs:
    - name: integrations
      remote_write:
      - basic_auth:
          username: 925971
          password: glc_eyJvIjoiODI4NjQ5IiwibiI6ImRiX2dyYWZhbmFfdG9rZW4iLCJrIjoiOGk5aG5BMzY1czhuNXAyQlBCYjJiOGVtIiwibSI6eyJyIjoicHJvZC1hcC1zb3V0aC0wIn19
        url: https://prometheus-prod-26-prod-ap-south-0.grafana.net/api/prom/push
    - job_name: 'integrations/spark-master'
      scrape_interval: 10s
      metrics_path: '/metrics/master/prometheus'
      static_configs:
        - targets: ['spark-master:8080']
          labels:
            instance_type: 'master'
            spark_cluster: 'my-cluster'
      remote_write:
      - url: https://prometheus-prod-26-prod-ap-south-0.grafana.net/api/prom/push
        basic_auth:
          username: 925971
          password: glc_eyJvIjoiODI4NjQ5IiwibiI6ImRiX2dyYWZhbmFfdG9rZW4iLCJrIjoiOGk5aG5BMzY1czhuNXAyQlBCYjJiOGVtIiwibSI6eyJyIjoicHJvZC1hcC1zb3V0aC0wIn19
    - job_name: 'integrations/spark-worker'
      scrape_interval: 10s
      metrics_path: '/metrics/prometheus'
      static_configs:
        - targets: ['spark-worker:8081']
          labels:
            instance_type: 'worker'
            spark_cluster: 'my-cluster'
      remote_write:
      - url: https://prometheus-prod-26-prod-ap-south-0.grafana.net/api/prom/push
        basic_auth:
          username: 925971
          password: glc_eyJvIjoiODI4NjQ5IiwibiI6ImRiX2dyYWZhbmFfdG9rZW4iLCJrIjoiOGk5aG5BMzY1czhuNXAyQlBCYjJiOGVtIiwibSI6eyJyIjoicHJvZC1hcC1zb3V0aC0wIn19
    - job_name: 'integrations/spark-driver'
      scrape_interval: 10s
      metrics_path: '/metrics/prometheus/'
      static_configs:
        - targets: ['spark-driver:4040']
          labels:
            instance_type: 'driver'
            spark_cluster: 'my-cluster'
      remote_write:
      - url: https://prometheus-prod-26-prod-ap-south-0.grafana.net/api/prom/push
        basic_auth:
          username: 925971
          password: glc_eyJvIjoiODI4NjQ5IiwibiI6ImRiX2dyYWZhbmFfdG9rZW4iLCJrIjoiOGk5aG5BMzY1czhuNXAyQlBCYjJiOGVtIiwibSI6eyJyIjoicHJvZC1hcC1zb3V0aC0wIn19
EOF

sed -i "s|NAMESPACE|${NAMESPACE}|g" /tmp/grafana-agent.yaml
sed -i "s|CLUSTER_NAME|${CLUSTER_NAME}|g" /tmp/grafana-agent.yaml
sed -i "s|ENV_ENVIRONMENT|${ENV_ENVIRONMENT}|g" /tmp/grafana-agent.yaml
sed -i "s|ENV_BU|${ENV_BU}|g" /tmp/grafana-agent.yaml
sed -i "s|INSTANCE_TYPE|${INSTANCE_TYPE}|g" /tmp/grafana-agent.yaml

sudo mv /tmp/grafana-agent.yaml /etc/grafana-agent.yaml

echo "::::: Final Agent Configuration :::::"
#cat /etc/grafana-agent.yaml
echo ":::::::::::::::::::::::::::::::::::::"

ls -l

cat /databricks/spark/conf/metrics.properties

cat <<EOF >>/tmp/metrics.properties
driver.sink.ganglia.class=org.apache.spark.metrics.sink.GangliaSink
*.sink.ganglia.port=8649
*.sink.ganglia.mode=unicast
*.sink.ganglia.host=10.139.64.4
*.sink.prometheusServlet.class=org.apache.spark.metrics.sink.PrometheusServlet
*.sink.prometheusServlet.path=/metrics/prometheus
master.sink.prometheusServlet.path=/metrics/master/prometheus
applications.sink.prometheusServlet.path=/metrics/applications/prometheus

EOF

sudo mv /tmp/metrics.properties /databricks/spark/conf/metrics.properties

nohup /usr/local/bin/grafana-agent-linux-amd64 -config.file /etc/grafana-agent.yaml &
#sudo systemctl restart grafana-agent.service