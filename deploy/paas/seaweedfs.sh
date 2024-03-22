function genSeaweedfsPort() {
  cat <<EOF >>${userValue}
    - port: ${SEAWEEDFS_MASTER_PORT}
      nodePort: ${SEAWEEDFS_MASTER_NODE_PORT}
      targetPort: ${SEAWEEDFS_MASTER_PORT}
      name: seaweedfs-master-port
      protocol: TCP
    - port: ${SEAWEEDFS_FILER_PORT}
      nodePort: ${SEAWEEDFS_FILER_NODE_PORT}
      targetPort: ${SEAWEEDFS_FILER_PORT}
      name: seaweedfs-filer-port
      protocol: TCP
EOF
}

function genSeaweedfsValue() {
  local userValues=$1/userValues.yaml
  local harborUri=${HARBOR_URI}
  local harborLibrary=${HARBOR_LIBRARY}

  local dataVolume=${SEAWEEDFS_DATA_VOLUME}
  local idxVolume=${SEAWEEDFS_IDX_VOLUME}
  local masterReplicas=${SEAWEEDFS_MASTER_REPLICAS}
  local volumeReplicas=${SEAWEEDFS_VOLUME_REPLICAS}
  local filerReplicas=${SEAWEEDFS_FILER_REPLICAS}

  cat <<EOF >${userValues}
global:
  registry: "${harborUri}/"
  repository: "${harborLibrary}/"
  imageName: "seaweedfs"
  imagePullPolicy: IfNotPresent
  restartPolicy: Always
  loggingLevel: 3

master:
  replicas: ${masterReplicas}
  defaultReplication: "001"
  nodeSelector: |
    seaweedfsmaster: seaweedfsmaster
  data:
    type: "persistentVolumeClaim"
    size: ${dataVolume}
    storageClass: "topolvm-provisioner"

volume:
  replicas: ${volumeReplicas}
  minFreeSpacePercent: 7
  index: null
  compactionMBps: "50"
  dir: "/data"
  dir_idx: "/idx"
  maxVolumes: "70"
  rack: "defaultRack"
  dataCenter: "defaultDataCenter"
  metrics:
    enabled: true
  nodeSelector: |
    seaweedfsvolume: seaweedfsvolume
  data:
    type: "persistentVolumeClaim"
    size: ${dataVolume}
    storageClass: "topolvm-provisioner"
  idx:
    type: "persistentVolumeClaim"
    size: ${idxVolume}
    storageClass: "topolvm-provisioner"

filer:
  replicas: ${filerReplicas}
  loggingOverrideLevel: null
  defaultReplicaPlacement: "001"
  enablePVC: true
  storage: ${idxVolume}
  storageClass: "topolvm-provisioner"
  nodeSelector: |
    seaweedfsfiler: seaweedfsfiler
  metrics:
    enabled: true

csi:
  storageClassName: seaweedfs-storage-class
  csiProvisioner:
    image: ${harborUri}/${harborLibrary}/csi-provisioner:v3.0.0
  csiAttacher:
    image: ${harborUri}/${harborLibrary}/csi-attacher:v3.3.0
  csiNodeDriverRegistrar:
    image: ${harborUri}/${harborLibrary}/csi-node-driver-registrar:v2.3.0
  seaweedfsCsiPlugin:
    image: ${harborUri}/${harborLibrary}/seaweedfs-csi-driver:v1.0.2
  csiController:
    nodeSelector: |
      swcsicontroller: swcsicontroller
  csiNode:
    nodeSelector: |
      swcsinode: swcsinode
EOF
}