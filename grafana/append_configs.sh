#!/bin/bash

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