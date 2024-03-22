
function genRedisValue() {
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local volume["redis"]=${REDIS_VOLUME}
  local redisNodes=${REDIS_NODE_NUMBER}
  local redisPassWord=${REDIS_PASSWORD}
  cat <<EOF >${userValue}
global:
  imageRegistry: ${dockerRegistry}
  storageClass: "topolvm-provisioner"
  redis:
    password: "${redisPassWord}"
commonConfiguration: |-
  appendonly yes
  save ""
master:
  persistence:
    size: ${volume["redis"]}
replica:
  replicaCount: 3
  persistence:
    size: ${volume["redis"]}
  nodeAffinityPreset:
    type: hard
    key: redis
    values:
      - redis
metrics:
  enabled: true
EOF
}

function genRedisclusterValue(){
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local volume["redis"]=${REDIS_CLUSTER_VOLUME}
  local redisNodes=${REDIS_CLUSTER_NODE_NUMBER}
  local redisPassWord=${REDIS_CLUSTER_PASSWORD}
  local redisReplica=${REDIS_CLUSTER_REPLICA}
  cat << EOF >${userValue}
global:
  imageRegistry: ${dockerRegistry}
  storageClass: "topolvm-provisioner"
  redis:
    password: "${redisPassWord}"
persistence:
  size: ${volume["redis"]}
redis:
  useAOFPersistence: "yes"
  nodeAffinityPreset:
    type: hard
    key: redis-cluster
    values:
      - redis-cluster
cluster:
  nodes: ${redisNodes}
  replicas: ${redisReplica}
metrics:
  enabled: true
EOF
}