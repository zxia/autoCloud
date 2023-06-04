
function setupConfd(){

  local namespace="confd-system"
  local srt="confd-secret"
  local confdWorkDir="${confdWorkDir}"
  local tomlPath="${confdWorkDir}/conf.d"
  local templatePath="${confdWorkDir}/templates"
  local dataPath="${confdWorkDir}/data"

  createDomain ${namespace}  || return $?

  if [ ! -d "${confdWorkDir}" ];then
      mkdir -p ${confdWorkDir}
      chmod 777 -R ${confdWorkDir}
  fi

  # 判断路径是否存在
  if [ ! -d ${tomlPath} ];then
     mkdir -p ${tomlPath}
     chmod 777 -R ${tomlPath}
  fi

  if [ ! -d ${templatePath} ];then
      mkdir -p ${templatePath}
      chmod 777 -R ${templatePath}
  fi

  if [ ! -d ${dataPath} ];then
      mkdir -p ${dataPath}
      chmod 777 -R ${dataPath}
  fi

  createConfdSecret "$srt" "$namespace" || return $?

  deployConfd "$namespace"|| return $?

  waitFunctionReady  300  "healthCheckPods ${namespace}"  || return $?

  local RC=$?
  log "setupConfd" $RC
  return $RC

}

function createConfdSecret() {
    local srt=$1
    local namespace=$2

    [ -f /root/.ssh/id_rsa ] || return $?
    [ -f /root/.ssh/id_rsa.pub ] || return $?
    [ -f /root/.ssh/known_hosts ] || return $?

    kubectl create --namespace="${namespace}" secret generic "$srt" \
    --from-file=ssh-privatekey=/root/.ssh/id_rsa \
    --from-file=ssh-publickey=/root/.ssh/id_rsa.pub \
    --from-file=ssh-knownhosts=/root/.ssh/known_hosts

    RC=$?
    log "createConfdSecret" $RC
    return $RC
}

function deployConfd(){
  local namespace=$1
  local type=confd

  deployService confd "${namespace}"

}

function  isConfdSupport(){
   cat ${cnfRoot}/data/k8s/nodes.ini | grep -v "#" | grep -w confd || return $?
}

function genConfdValue() {
  local userValue=$1
  cat <<EOF >"${userValue}"
fullNameOverride: confd
replicaCount: 1
namespace: confd-system
nodeSelector:
  confd: confd
image:
  repository: "${dockerRegistry}/confd:1.0.5"
  pullPolicy: Always
imagePullSecrets:
  - name: ${regcred}
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 200m
    memory: 256Mi
logLevel: debug
table: foo_conf
mongoUrl: "mongodb://confd:confd@mongodb-mongodb-sharded.mongodb-system.svc.cluster.local"
mountPath: "${confdWorkDir}"
EOF
}