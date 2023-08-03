
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Cassandra many compaction tasks are pending.
---

This incident type occurs when there are many pending compaction tasks in a Cassandra cluster. Compaction is the process of merging and removing data from SSTables (sorted string tables) in Cassandra. When compaction tasks are pending, it means that the process is not completing in a timely manner and is causing performance issues in the cluster. This incident requires investigation and resolution to ensure the cluster's health and performance.

### Parameters
```shell
# Environment Variables

export CASSANDRA_NODE_IP="PLACEHOLDER"

export PATH_TO_CASSANDRA_YAML="PLACEHOLDER"

export NUMBER_OF_COMPACTION_THREADS="PLACEHOLDER"

export CASSANDRA_DATA_DIRECTORY="PLACEHOLDER"

export MEMORY_THRESHOLD="PLACEHOLDER"

export NEW_COMPACTION_THROUGHPUT="PLACEHOLDER"
```

## Debug

### Check the status of the Cassandra service
```shell
systemctl status cassandra
```

### Check the number of pending compaction tasks in Cassandra
```shell
nodetool compactionstats | grep pending_tasks
```

### Check the health of the Cassandra cluster
```shell
nodetool status
```

### Check the Cassandra logs for errors or warnings
```shell
tail -n 100 /var/log/cassandra/system.log
```

### Check the system load and CPU usage
```shell
top
```

### Check the disk usage and available space
```shell
df -h
```

### Check the network connectivity and latency
```shell
ping ${CASSANDRA_NODE_IP}
```

### Check the firewall rules and open ports
```shell
iptables -L -n
```

### Insufficient resources such as CPU, memory, or disk space, causing compaction to slow down or stop.
```shell


#!/bin/bash


 CPU_THRESHOLD="PLACEHOLDER"

 DISK_THRESHOLD="PLACEHOLDER"
# Check CPU usage

cpu_usage=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')

if (( $(echo "$cpu_usage > ${CPU_THRESHOLD}" | bc -l) )); then

  echo "CPU usage is high ($cpu_usage%), which may be causing compaction to slow down or stop."

fi



# Check memory usage

mem_usage=$(free | awk '/Mem/{printf("%.2f"), $3/$2*100}')

if (( $(echo "$mem_usage > ${MEMORY_THRESHOLD}" | bc -l) )); then

  echo "Memory usage is high ($mem_usage%), which may be causing compaction to slow down or stop."

fi



# Check disk space

disk_usage=$(df -h ${CASSANDRA_DATA_DIRECTORY} | tail -1 | awk '{print $5}' | tr -d '%')

if (( $disk_usage > ${DISK_THRESHOLD} )); then

  echo "Disk space usage is high ($disk_usage%), which may be causing compaction to slow down or stop."

fi


```

## Repair

### Set variables
```shell
CASSANDRA_CONFIG_FILE=${PATH_TO_CASSANDRA_YAML}

CONCURRENT_COMPACTORS=${NUMBER_OF_COMPACTION_THREADS}
```

### Check if cassandra config file exists
```shell
if [ ! -f $CASSANDRA_CONFIG_FILE ]; then

  echo "Cassandra config file not found: $CASSANDRA_CONFIG_FILE"

  exit 1

fi
```

### Backup cassandra config file
```shell
cp $CASSANDRA_CONFIG_FILE $CASSANDRA_CONFIG_FILE.bak
```

### Update concurrent_compactors property
```shell
sed -i "s/^concurrent_compactors:.*$/concurrent_compactors: $CONCURRENT_COMPACTORS/" $CASSANDRA_CONFIG_FILE
```

### Restart cassandra service
```shell
systemctl restart cassandra.service
```

### Next Step
```shell
echo "Compaction threads increased to $CONCURRENT_COMPACTORS."
```

### Reduce the size of SSTables in the cluster by increasing the frequency of compaction or by manually triggering it. This will help reduce the number of pending tasks and improve performance.
```shell
bash

#!/bin/bash

# Set the Cassandra home directory

CASSANDRA_HOME="PLACEHOLDER"

# Set the maximum number of pending compaction tasks allowed before triggering manual compaction

MAX_PENDING_COMPACTION_TASKS="PLACEHOLDER"

# Get the current number of pending compaction tasks

PENDING_COMPACTION_TASKS=$(nodetool compactionstats | grep pending | awk '{print $NF}')

# If the number of pending compaction tasks is greater than the maximum allowed, trigger manual compaction

if [ "$PENDING_COMPACTION_TASKS" -gt "$MAX_PENDING_COMPACTION_TASKS" ]; then

    echo "Too many pending compaction tasks. Triggering manual compaction..."

    nodetool compact

fi

# If the number of pending compaction tasks is within the allowed limit, increase the frequency of compaction

echo "Increasing the frequency of compaction..."

sed -i 's/^# auto_snapshot: .*$/auto_snapshot: true/' $CASSANDRA_HOME/conf/cassandra.yaml

sed -i 's/^# compaction_throughput_mb_per_sec: .*$/compaction_throughput_mb_per_sec: ${NEW_COMPACTION_THROUGHPUT}/' $CASSANDRA_HOME/conf/cassandra.yaml

# Restart Cassandra to apply the changes

echo "Restarting Cassandra..."

sudo service cassandra restart

echo "Compaction remediation complete."

```