
function genMongodbshardedValue() {
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local mongoShard=${MONGODB_SHARDED_SHARD_NUMBER}
  local volume["mongodata"]=${MONGODB_SHARDED_DATA_VOLUME}
  local volume["mongoconf"]=${MONGODB_SHARDED_CONFIG_VOLUME}
  local mongodbRootPassword=${MONGODB_ROOT_PASSWORD:="Ctsi5G+2021"}
  cat <<EOF >${userValue}
global:
  imageRegistry: ${dockerRegistry}
  storageClass: topolvm-provisioner
mongodbRootPassword: "${mongodbRootPassword}"
mongos:
  replicaCount: 2
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: mongos
                operator: In
                values:
                  - mongos
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app.kubernetes.io/component: mongos
            namespaces:
              - "${NAMESPACE}"
            topologyKey: kubernetes.io/hostname
shards: ${mongoShard}
shardsvr:
  persistence:
    size: ${volume["mongodata"]}
  dataNode:
    replicaCount: 3
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
                - key: mongodata
                  operator: In
                  values:
                    - mongodata
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app.kubernetes.io/component: shardsvr
              namespaces:
                - "${NAMESPACE}"
              topologyKey: kubernetes.io/hostname

configsvr:
  replicaCount: 3
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: mongoconf
                operator: In
                values:
                  - mongoconf
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app.kubernetes.io/component: configsvr
            namespaces:
              - "${NAMESPACE}"
            topologyKey: kubernetes.io/hostname
  persistence:
    size: ${volume["mongoconf"]}
metrics:
  enabled: true
EOF
}

function deployMongo() {
  deployService mongodb mongodb-system
}

function initMongo() {
  [ -f ${dataRoot}/k8s/mongo.cnf ] || cp ${dataRoot}/k8s/mongo.cnf.templ ${dataRoot}/k8s/mongo.cnf
}

function getMongoPwd() {
  local namespace=$1
  local pwd=$(kubectl get secret --namespace ${namespace} mongodb-mongodb-sharded -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
  echo "${pwd} end"
}

function removeMongo() {
  local componentName=$1
  local nameSpace=$2

  helm list -n ${nameSpace} | grep ${componentName} || return $?
  helm uninstall ${componentName} -n ${nameSpace} || return $?
}

function setupMongoBackup() {
  baseHelm=${helmRoot}/backup/mongodb/helm
  [ -d ${baseHelm} ] || exit 1

  serviceDataDir=${dataRoot}/helm/mongoBackup
  [ -d ${serviceDataDir} ] || exit 1

  cp -rf ${serviceDataDir}/mongoBackup.ini ${baseHelm}/configs/

  helm upgrade --install -f ${serviceDataDir}/userValues.yaml mongoBackup ${baseHelm}/
}

function genMongoBackupValue() {
  baseHelm=${helmRoot}/backup/mongodb/helm
  [ -d ${baseHelm} ] || exit 1

  serviceData=${cnfRoot}/data/helm/mongoBackup
  [ -d "${baseDir}" ] || mkdir -p ${baseDir}

  serviceConfig=${cnfRoot}/config/mongoBackup
  configFiles=$(ls ${serviceConfig})
  cp -rf ${serviceConfig}/mongoBackup.ini ${serviceData}/

  cat <<EOF >${serviceData}/userValues.yaml
fullnameOverride: mongodb-backup
image:
  repository: ${dockerRegistry}/mongodb-backup
  pullPolicy: Always
  tag: "latest"
imagePullSecrets:
  - name: ${regcred}
namespace: default
resources:
  limits:
    cpu: 1
    memory: 2048Mi
  requests:
    cpu: 1
    memory: 2048Mi
mongodbSecret:
  name: mongodb-mongodb-sharded
  key: mongodb-root-password
cronjob:
  schedule: "*/5 * * * *"
nodeSelector: |
  topology.topolvm.cybozu.com/node: "k8s01"
EOF
}