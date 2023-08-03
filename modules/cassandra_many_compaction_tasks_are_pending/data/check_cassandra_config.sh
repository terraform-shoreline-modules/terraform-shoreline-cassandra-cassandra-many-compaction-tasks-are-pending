if [ ! -f $CASSANDRA_CONFIG_FILE ]; then

  echo "Cassandra config file not found: $CASSANDRA_CONFIG_FILE"

  exit 1

fi