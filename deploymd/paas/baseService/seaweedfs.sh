function setupSeaweedfs() {
  labelNames=(seaweedfsmaster seaweedfsvolume seaweedfsfiler swcsicontroller swcsinode)

  createDomain seaweedfs-system || return $?

  for label in ${labelNames[@]}; do
    labelPaasNodes  ${label} || return $?
  done

  deploySeaweedFS || return $?

  waitFunctionReady  300  "healthCheckPods seaweedfs-system "  || return $?

  local ret=$?
  log "deploySeaweedFS" $ret
  return $ret
}


function isSeaweedfsSupport() {
  labelNames=(seaweedfsmaster seaweedfsvolume seaweedfsfiler )

  for label in ${labelNames[@]}; do
    cat ${nodeInfo} | grep -v "#" | grep -w ${label} || return $?
  done

  local ret=$?
  log "isSeaweedfsSupport" $ret
  return $ret
}

function genSeaweedfsValue() {
  baseDir=${cnfRoot}/data/helm/seaweedfs
  [ -d "${baseDir}" ] || mkdir -p ${baseDir}

  cat <<EOF >${baseDir}/userValues.yaml
global:
  registry: "${harbor}/"
  repository: "library/"
  imageName: "seaweedfs"
  imageTag: "2.76"
  imagePullPolicy: IfNotPresent
  imagePullSecrets: ${regcred}
  restartPolicy: Always
  loggingLevel: 3

master:
  replicas: 1
  defaultReplication: "100"
  nodeSelector: |
    seaweedfsmaster: seaweedfsmaster

volume:
  replicas: 3
  minFreeSpacePercent: 7
  index: "leveldb"
  compactionMBps: "50"
  dir: "/data"
  dir_idx: null
  maxVolumes: "20"
  rack: "rack"
  dataCenter: "dc"
  metrics:
    enabled: true
  nodeSelector: |
    seaweedfsvolume: seaweedfsvolume
  data:
    type: "persistentVolumeClaim"
    size: ${volume[seaweedfs]}
    storageClass: "topolvm-provisioner"
  idx:
    type: "persistentVolumeClaim"
    size: ${volume[seaweedfs]}
    storageClass: "topolvm-provisioner"
  logs:
    type: "persistentVolumeClaim"
    size: ${volume[seaweedfs]}
    storageClass: "topolvm-provisioner"

filer:
  replicas: 1
  loggingOverrideLevel: null
  defaultReplicaPlacement: "100"
  nodeSelector: |
    seaweedfsfiler: seaweedfsfiler
  metrics:
    enabled: true

csi:
  storageClassName: seaweedfs-storage-class
  csiProvisioner:
    image: ${harbor}/library/csi-provisioner:v3.0.0
  csiAttacher:
    image: ${harbor}/library/csi-attacher:v3.3.0
  csiNodeDriverRegistrar:
    image: ${harbor}/library/csi-node-driver-registrar:v2.3.0
  seaweedfsCsiPlugin:
    image: ${harbor}/library/seaweedfs-csi-driver:v1.0.2
  csiController:
    nodeSelector: |
      swcsicontroller: swcsicontroller
  csiNode:
    nodeSelector: |
      swcsinode: swcsinode
EOF
}

function deploySeaweedFS() {
  deployService seaweedfs   seaweedfs-system
}

function removeSeaweedFS() {
  local componentName=$1
  local nameSpace=$2

  helm list -n ${nameSpace} | grep ${componentName} || return $?
  helm uninstall ${componentName} -n ${nameSpace} || return $?
}

function genSeaweedfsPort() {
  cat <<EOF >>${userValue}
    - port: ${seaweedfsMasterPort}
      nodePort: ${seaweedfsMasterNodePort}
      targetPort: ${seaweedfsMasterPort}
      name: seaweedfs-master-port
      protocol: TCP
    - port: ${seaweedfsFilerPort}
      nodePort: ${seaweedfsFilerNodePort}
      targetPort: ${seaweedfsFilerPort}
      name: seaweedfs-filer-port
      protocol: TCP
EOF
}
