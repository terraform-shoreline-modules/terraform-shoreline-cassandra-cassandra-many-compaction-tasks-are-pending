

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