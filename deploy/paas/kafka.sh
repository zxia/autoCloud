#setConfig harbor ,kafka
function genKafkaValue(){
  type=kafka
  local userValue=$1/userValues.yaml
  [ -d "${baseDir}" ] || mkdir -p ${baseDir}

  cat << EOF > ${userValue}
global:
  imageRegistry: ${HARBOR_URI}/${HARBOR_LIBRARY}
  storageClass: topolvm-provisioner
replicaCount: 3
nodeAffinityPreset:
  type: "hard"
  key: "kafka"
  values:
    - "kafka"
persistence:
  size: ${KAFKA_KAFKA_VOLUME}
zookeeper:
  replicaCount: 3
  nodeAffinityPreset:
    type: "hard"
    key: "zookeeper"
    values:
      - "zookeeper"
  persistence:
    size: ${KAFKA_ZOOKEEPER_VOLUME}
metrics:
  kafka:
    enabled: true
  jmx:
    enabled: true
EOF
}

