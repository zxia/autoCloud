function setupNacos() {
  labelPaasNodes nacos

  createDomain nacos-system || return $?

  deployNacos || return $?

  waitFunctionReady 300 "healthCheckPods nacos-system " || return $?

  local ret=$?
  log "setupNacos" $ret
  return $ret
}

function isNacosSupport() {
  cat ${cnfRoot}/data/k8s/nodes.ini | grep -v "#" | grep -w nacos || return $?
}

function genNacosValue() {
  baseDir=${cnfRoot}/data/helm/nacos
  [ -d "${baseDir}" ] || mkdir -p ${baseDir}

  MARIADB_ROOT_PASSWORD=$(kubectl get secret mariadb -n mariadb-system -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)

  cat <<EOF >${baseDir}/userValues.yaml
global:
  mode: cluster
  namespace: nacos-system
serviceAccount:
  imagePullSecrets: ${regcred}
nacos:
  image:
    repository: ${dockerRegistry}/nacos/nacos-server
    tag: v2.1.0
    pullPolicy: IfNotPresent
  plugin:
    enable: true
    image:
      repository: ${dockerRegistry}/nacos/nacos-peer-finder-plugin
      tag: 1.1
  replicaCount: 3
  storage:
    type: mysql
    db:
      host: mariadb-primary-0.mariadb-primary.mariadb-system.svc.cluster.local
      name: nacos_config
      port: "3306"
      username: root
      password: ${MARIADB_ROOT_PASSWORD}
      param: characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false
affinity:
  nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: nacos
                operator: In
                values:
                  - nacos
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: nacos
          namespaces:
            - "nacos-system"
          topologyKey: kubernetes.io/hostname
EOF
}

function deployNacos() {
  deployService nacos nacos-system
}