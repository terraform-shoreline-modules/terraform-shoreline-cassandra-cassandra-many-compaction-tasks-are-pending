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