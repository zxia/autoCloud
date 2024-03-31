
#execute as root
function prepareTopolvm(){
  local target=/var/lib/scheduler/scheduler-config.yaml
  [ -d ${target%/*} ] || mkdir -p  ${target%/*}
  rsync /home/opuser/topolvm/scheduler-config.yaml ${target} || return $?
  rsync /home/opuser/topolvm/kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml || return $?
}
function installCertManagerCRD(){
    kubectl apply -f /home/opuser/topolvm/cert-manager.crds.yaml -n topolvm-system
    kubectl label namespace topolvm-system topolvm.io/webhook=ignore
    kubectl label namespace kube-system topolvm.io/webhook=ignore
}
function genTopolvmValue(){
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  cat << EOF >${userValue}
image:
  repository: ${dockerRegistry}/topolvm/topolvm-with-sidecar
  regcred: regcred

EOF
  cat << EOF >>${userValue}
controller:
  storageCapacityTracking:
    # controller.storageCapacityTracking.enabled -- Enable Storage Capacity Tracking for csi-provisoner.
    enabled: true
scheduler:
  enabled: false
webhook:
  podMutatingWebhook:
    enabled: false
EOF
genTopolvmDeviceClass ${userValue}
genTopolvmStorageClass ${userValue}
genCertmanagerValues ${userValue}

}

function genTopolvmDeviceClass(){
   userValue=$1
   cat << EOF >>${userValue}
lvmd:
   deviceClasses:
    - name: hdd
      volume-group: ${TOPOLVM_VOLUME}
      default: true
      spare-gb: 10
EOF
}

function genCertmanagerValues(){
  local userValue=$1
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
cat << EOF >>${userValue}
cert-manager:
  enabled: true
  global:
    ## Reference to one or more secrets to be used when pulling images
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ##
    imagePullSecrets:
      - name: regcred
  image:
    repository: ${dockerRegistry}/jetstack/cert-manager-controller
  webhook:
    image:
      repository: ${dockerRegistry}/jetstack/cert-manager-webhook
    # You can manage a registry with
    # registry: quay.io
    # repository: jetstack/jetstack/cert-manager-webhook
  cainjector:
    image:
      repository: ${dockerRegistry}/jetstack/cert-manager-cainjector

EOF
}
function genTopolvmStorageClass(){
   userValue=$1
   cat << EOF >>${userValue}
storageClasses:
  - name: topolvm-provisioner  # Defines name of storage classe.
    storageClass:
      # Supported filesystems are: ext4, xfs, and btrfs.
      fsType: xfs
      # reclaimPolicy
      reclaimPolicy:  # Delete
      # Additional annotations
      
      annotations: {}
      # Default storage class for dynamic volume provisioning
      # ref: https://kubernetes.io/docs/concepts/storage/dynamic-provisioning
      isDefaultClass: false
      # volumeBindingMode can be either WaitForFirstConsumer or Immediate. WaitForFirstConsumer is recommended because TopoLVM cannot schedule pods wisely if volumeBindingMode is Immediate.
      volumeBindingMode: WaitForFirstConsumer
      # enables CSI drivers to expand volumes. This feature is available for Kubernetes 1.16 and later releases.
      allowVolumeExpansion: true
      additionalParameters: {}
      # "topolvm.cybozu.com/device-class": "ssd"
EOF
}


# execute as root on the target Master node
function  getK8sSchedulerFile(){
  [ -f /home/opuser/topolvm/kube-scheduler.yaml.tpl ] && return 0
  rsync /etc/kubernetes/manifests/kube-scheduler.yaml  /home/opuser/topolvm/kube-scheduler.yaml.tpl
  chown opuser:opusergroup /home/opuser/topolvm/kube-scheduler.yaml.tpl
}


function genTopolvmFile(){
  #gen cert-manager.crds.yaml
  local topolvmPath=${workDir}/output/topolvm
  [ -d ${topolvmPath} ] || mkdir -p ${topolvmPath}

  rsync ${workDir}/template/deploy/cert-manager.crds.yaml.tpl  ${topolvmPath}/cert-manager.crds.yaml  || return $?

  #rsync ${workDir}/template/deploy/scheduler-config-v1beta2.yaml.tpl  ${topolvmPath}/scheduler-config.yaml || return $?

  #genSchedulerFile || return $?

}

function genSchedulerFile(){

  local schedulerBack=${workDir}/output/topolvm/kube-scheduler.yaml.tpl
  local schedulerTEMPL=${workDir}/output/topolvm/kube-scheduler.yaml.tmpl
  local scheduler=${workDir}/output/topolvm/kube-scheduler.yaml
  [ -f ${scheduler} ] && rm -rf ${scheduler}

  cp -rf  ${schedulerBack} ${schedulerTEMPL}

  sed -i "/--kubeconfig/i genScheduler1" ${schedulerTEMPL} || return $?
  sed -i "/- mountPath:/i genScheduler2" ${schedulerTEMPL} || return $?
  sed -i "/- hostPath:/i genScheduler3" ${schedulerTEMPL} || return $?
  sed -i "s/ /@/g" ${schedulerTEMPL} || return $?
  log "genSchedulerTEMPL"

  while read line; do
    case $line in
    *genScheduler*)
      eval $line  || return $?
      ;;
    *)
      cat << EOF >>${scheduler}
${line}
EOF
      ;;

    esac
  done <${schedulerTEMPL}
  sed -i "s/@/ /g" ${scheduler} || return $?
}

function genScheduler1(){
  local scheduler=${workDir}/output/topolvm/kube-scheduler.yaml
  cat << EOF >> ${scheduler}
    - --config=/var/lib/scheduler/scheduler-config.yaml
EOF
}

function genScheduler2(){
  local scheduler=${workDir}/output/topolvm/kube-scheduler.yaml
cat << EOF >> ${scheduler}
    - mountPath: /var/lib/scheduler
      name: topolvm-config
      readOnly: true
EOF
}

function genScheduler3(){
  local scheduler=${workDir}/output/topolvm/kube-scheduler.yaml
cat << EOF >> ${scheduler}
  - hostPath:
      path: /var/lib/scheduler
      type: Directory
    name: topolvm-config
EOF
}