function checkMariadb() {
    local namespace=${1:=default}
    local state=$( kubectl get pods -n ${namespace} | grep "mariadb" | sed -n 1p | awk '{print $3}')
    [ $state = Running ] || return $?
}

function genNacosValue() {
  local userValues=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}

  local replicas=${NACOS_REPLICAS}
  local dbType=${NACOS_DB_TYPE}
  local dbHost=${NACOS_DB_HOST}
  local dbName=${NACOS_DB_NAME}
  local dbPort=${NACOS_DB_PORT}
  local dbUsername=${NACOS_DB_USERNAME}
  local dbPassword=${NACOS_DB_PASSWORD}

cat <<EOF >${userValues}
---
global:
  mode: cluster
nacos:
  image:
    repository: ${dockerRegistry}/nacos/nacos-server
    tag: v2.1.1
    pullPolicy: IfNotPresent
  plugin:
    enable: true
    image:
      repository: ${dockerRegistry}/nacos/nacos-peer-finder-plugin
      tag: 1.1
  replicaCount: ${replicas}
  storage:
    type: ${dbType}
    db:
      host: ${dbHost}
      name: ${dbName}
      port: ${dbPort}
      username: ${dbUsername}
      password: ${dbPassword}
      param: characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false
persistence:
  enabled: false
affinity:
  nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: ${COMPONENT}
                operator: In
                values:
                  - ${COMPONENT}
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: ${COMPONENT}
          namespaces:
            - "${NAMESPACE}"
          topologyKey: kubernetes.io/hostname
EOF
}


