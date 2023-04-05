# Databricks notebook source
print(spark.conf.get("spark.ui.prometheus.enabled"))
print(spark.conf.get("spark.executor.processTreeMetrics.enabled"))

# COMMAND ----------

# MAGIC %sh
# MAGIC #Verify all the variables have appropriate information as expected.
# MAGIC echo "CLUSTER_NAME: $CLUSTER_NAME - ENV_ENVIRONMENT: $ENV_ENVIRONMENT - ENV_BU: $ENV_BU - INSTANCE_TYPE: $INSTANCE_TYPE - DB_IS_DRIVER: $DB_IS_DRIVER - CLUSTER_ID: $CLUSTER_ID"

# COMMAND ----------

# MAGIC %sh
# MAGIC #Verify grafana agent process is running in background
# MAGIC ps -ef | grep grafana-agent

# COMMAND ----------

# MAGIC %sh
# MAGIC #Verify grafana agent config file
# MAGIC ls -ltr /etc/grafana-agent.yaml

# COMMAND ----------

# MAGIC %sh
# MAGIC cat $SPARK_HOME/conf/metrics.properties

# COMMAND ----------

# MAGIC %sh
# MAGIC netstat -tunlp | grep 10.139.64.4

# COMMAND ----------

# MAGIC %sh
# MAGIC ifconfig

# COMMAND ----------

# MAGIC %sh
# MAGIC sudo systemctl status prometheus
