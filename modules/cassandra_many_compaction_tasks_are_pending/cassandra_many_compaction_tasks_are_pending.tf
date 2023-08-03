resource "shoreline_notebook" "cassandra_many_compaction_tasks_are_pending" {
  name       = "cassandra_many_compaction_tasks_are_pending"
  data       = file("${path.module}/data/cassandra_many_compaction_tasks_are_pending.json")
  depends_on = [shoreline_action.invoke_threshold_check,shoreline_action.invoke_cassandra_script,shoreline_action.invoke_check_cassandra_config,shoreline_action.invoke_compaction_remediation]
}

resource "shoreline_file" "threshold_check" {
  name             = "threshold_check"
  input_file       = "${path.module}/data/threshold_check.sh"
  md5              = filemd5("${path.module}/data/threshold_check.sh")
  description      = "Insufficient resources such as CPU, memory, or disk space, causing compaction to slow down or stop."
  destination_path = "/agent/scripts/threshold_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "cassandra_script" {
  name             = "cassandra_script"
  input_file       = "${path.module}/data/cassandra_script.sh"
  md5              = filemd5("${path.module}/data/cassandra_script.sh")
  description      = "Set variables"
  destination_path = "/agent/scripts/cassandra_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "check_cassandra_config" {
  name             = "check_cassandra_config"
  input_file       = "${path.module}/data/check_cassandra_config.sh"
  md5              = filemd5("${path.module}/data/check_cassandra_config.sh")
  description      = "Check if cassandra config file exists"
  destination_path = "/agent/scripts/check_cassandra_config.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "compaction_remediation" {
  name             = "compaction_remediation"
  input_file       = "${path.module}/data/compaction_remediation.sh"
  md5              = filemd5("${path.module}/data/compaction_remediation.sh")
  description      = "Reduce the size of SSTables in the cluster by increasing the frequency of compaction or by manually triggering it. This will help reduce the number of pending tasks and improve performance."
  destination_path = "/agent/scripts/compaction_remediation.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_threshold_check" {
  name        = "invoke_threshold_check"
  description = "Insufficient resources such as CPU, memory, or disk space, causing compaction to slow down or stop."
  command     = "`chmod +x /agent/scripts/threshold_check.sh && /agent/scripts/threshold_check.sh`"
  params      = ["MEMORY_THRESHOLD","CASSANDRA_DATA_DIRECTORY"]
  file_deps   = ["threshold_check"]
  enabled     = true
  depends_on  = [shoreline_file.threshold_check]
}

resource "shoreline_action" "invoke_cassandra_script" {
  name        = "invoke_cassandra_script"
  description = "Set variables"
  command     = "`chmod +x /agent/scripts/cassandra_script.sh && /agent/scripts/cassandra_script.sh`"
  params      = ["PATH_TO_CASSANDRA_YAML","NUMBER_OF_COMPACTION_THREADS"]
  file_deps   = ["cassandra_script"]
  enabled     = true
  depends_on  = [shoreline_file.cassandra_script]
}

resource "shoreline_action" "invoke_check_cassandra_config" {
  name        = "invoke_check_cassandra_config"
  description = "Check if cassandra config file exists"
  command     = "`chmod +x /agent/scripts/check_cassandra_config.sh && /agent/scripts/check_cassandra_config.sh`"
  params      = []
  file_deps   = ["check_cassandra_config"]
  enabled     = true
  depends_on  = [shoreline_file.check_cassandra_config]
}

resource "shoreline_action" "invoke_compaction_remediation" {
  name        = "invoke_compaction_remediation"
  description = "Reduce the size of SSTables in the cluster by increasing the frequency of compaction or by manually triggering it. This will help reduce the number of pending tasks and improve performance."
  command     = "`chmod +x /agent/scripts/compaction_remediation.sh && /agent/scripts/compaction_remediation.sh`"
  params      = ["NEW_COMPACTION_THROUGHPUT"]
  file_deps   = ["compaction_remediation"]
  enabled     = true
  depends_on  = [shoreline_file.compaction_remediation]
}

