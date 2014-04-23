CAMUS_CONF=/etc/camus/conf
CAMUS_HOME=/usr/lib/camus
JAR_FILE=${CAMUS_HOME}/camus-etl-kafka-0.1.0-SNAPSHOT-shaded.jar

# You have to make camus user if any error
# sudo -E -u hdfs hdfs dfs -mkdir /user/camus
# sudo -E -u hdfs hdfs dfs -chown camus:camus /user/camus

# You have to run this example with:
# sudo -E -u camus /usr/lib/camus/bin/run-camus-example.sh

(cd $CAMUS_CONF && hadoop jar ${JAR_FILE} \
 com.linkedin.camus.etl.kafka.CamusJob -P /etc/camus/conf/camus.properties)

