function initKubernetes(){
  local hostIp=${SSH_HOST}
  local hostName=$(grep "${hostIp}" ${workDir}/lab/${LAB_NAME}/nodes.ini | awk '{print $1}')
  executeExpect SSH "initKubernetesHelper:${hostName}  ${hostIp} \
             ${controlPlaneEndpoint} ${podNetworkCidr}  ${kubernetesVersion} ${HARBOR_NAME} 86"
  return $?
}

function deployHelm() {
  tar Cxzvf /usr/local /home/opuser/installpackage/helm-v*.*-linux-amd64.tar.gz || return $?
  rsync /usr/local/linux-amd64/helm /usr/local/sbin/helm  || return $?
}

function genK8sSetupCerts() {
  local k8sSec=/tmp/k8sSec/
  [ -d ${k8sSec} ] || mkdir -p ${k8sSec}
  kubeadm init phase upload-certs   --upload-certs >${k8sSec}/certs.key
  kubeadm token create >${k8sSec}/token.key
  openssl x509 -in /etc/kubernetes/pki/ca.crt -pubkey -noout |
    openssl pkey -pubin -outform DER |
    openssl dgst -sha256 |  awk '{print $2}'> ${k8sSec}/ca.key
}
#@setConfig k8s
function genJoinK8sCommand()
{
  local type=$(grep "${SSH_HOST}" ${workDir}/lab/${LAB_NAME}/nodes.ini | awk '{print $2}')
  local hostName=$(grep "${SSH_HOST}" ${workDir}/lab/${LAB_NAME}/nodes.ini | awk '{print $1}')
  local hostIP=${SSH_HOST}
  local k8sSec=${workDir}/output/k8sSec
  local kubeadmUploadCerts=$(grep -v "upload-certs" ${k8sSec}/certs.key)
  local kubeadmToken=$(cat ${k8sSec}/token.key)
  local kubeadmCA=$(cat ${k8sSec}/ca.key)
  local controlPlaneEndpoint=${controlPlaneEndpoint}

  executeExpect SSH "joinNode:${type} ${hostName} ${hostIP} ${kubeadmUploadCerts} ${kubeadmToken} ${kubeadmCA}  ${controlPlaneEndpoint}"

}

function joinNode(){

  local type=$1
  local hostName=$2
  local hostIP=$3
  local kubeadmUploadCerts=$4
  local kubeadmToken=$5
  local kubeadmCA=$6
  local controlPlaneEndpoint=$7
  local k8sSec=${workDir}/output/k8sSec

  kubeadm reset -f >/dev/null
  rm -rf /etc/kubernetes/pki
  rm -rf /etc/cni/net.d
  rm -rf $HOME/.kube/config

   if [ ${type} = "master" ]; then
     kubeadm join ${controlPlaneEndpoint}:6443 \
    --token ${kubeadmToken} \
    --discovery-token-ca-cert-hash sha256:${kubeadmCA} \
    --control-plane \
    --certificate-key ${kubeadmUploadCerts} \
    --apiserver-advertise-address=${hostIP} \
    --node-name=${hostName} \
    --v=10
  elif [ ${type} = "work" ]; then
     kubeadm join ${controlPlaneEndpoint}:6443 --token ${kubeadmToken}  \
    --discovery-token-ca-cert-hash sha256:${kubeadmCA} \
    --node-name=${hostName}
  fi

  result=$?

  if [ "${result}" -ne 0 ]; then
    echo "execute kubeadm failure"
    return 1
  fi

  if [ ${type} = "master" ]; then

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    kubectl taint nodes ${hostName} node-role.kubernetes.io/control-plane-
  fi

  return 0
}

#--------------------------------------------------------
# generate the command to join the node as master
# INPUT: the node ip for joining
# --------------------------------------------------------
function genJoinMasterCommand() {
  local hostName=$1
  local hostIP=$(getHostIP ${hostName})
  masterJoin="kubeadm join ${controlPlaneEndpoint}:6443 \
    --token ${kubeadmToken} \
    --discovery-token-ca-cert-hash sha256:${kubeadmCA} \
    --control-plane \
    --certificate-key ${kubeadmUploadCerts} \
    --apiserver-advertise-address=${hostIP} \
    --node-name=${hostName} \
    --v=${logLevel}  "
  echo ${masterJoin}
}

#--------------------------------------------------------
# generate the command to join the node as work node
#--------------------------------------------------------
function genJoinNodeCommand() {
  local hostName=$1
  local hostIP=$(getHostIP "${hostName}")
  workNodeJoin="kubeadm join ${controlPlaneEndpoint}:6443 --token ${kubeadmToken}  \
    --discovery-token-ca-cert-hash sha256:${kubeadmCA} \
    --node-name=${hostName} \
    --v=${logLevel} "

  echo ${workNodeJoin}
}

function initKubernetesHelper() {

  local hostName=$1
  local hostIp=$2
  local controlPlaneEndpoint=$3
  local podNetworkCidr=$4
  local kubernetesVersion=$5
  local dockerRegistry=$6
  local index=$7

  state=$(cat /home/opuser/state/.state)
  [ "${state}" = "5GMC_HOST" -o "${state}" = "5GMC_K8S" ] || return $?

  kubeadm reset -f >/dev/null
  rm -rf /etc/kubernetes/pki
  rm -rf /etc/cni/net.d
  rm -rf $HOME/.kube/config

  kubeadm init --control-plane-endpoint ${controlPlaneEndpoint} \
      --upload-certs --pod-network-cidr=${podNetworkCidr}/16 \
      --kubernetes-version=${kubernetesVersion} \
      --image-repository=${dockerRegistry}/library \
      --apiserver-advertise-address=${hostIp} \
      --service-cidr=10.${index}.0.0/16 \
      --node-name=${hostName} \
      --v=10
  result=$?

  if [ "${result}" -ne 0 ]; then
    echo "execute kubeadm failure"
    return 1
  fi

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  return 0
}

function getK8sReadyIpList(){
  local nodeInfo=${workDir}/output/k8s/nodes.log
  local nodesList=$(cat ${nodeInfo} | grep Ready | awk '{print $6}'|xargs)
  echo ${nodesList}
}
function getK8sReadyIpListByType(){
  local type=$1
  local nodeInfo=${workDir}/output/k8s/nodes.log
  local nodesList=$(cat ${nodeInfo} | grep Ready | grep ${type} | awk '{print $6}'|xargs)
  echo ${nodesList}
}
function updateReadyIpList() {
  rm -rf /home/opuser/k8s  || return 0
  mkdir -p /home/opuser/k8s  || return 0 
  kubectl get nodes -o wide > /home/opuser/k8s/nodes.log || return 0
}

function getLiveK8sNodesInfo(){
  [ -d /home/opuser/k8s ] || mkdir -p /home/opuser/k8s
  local nodeInfo=/home/opuser/k8s/nodes.log
  kubectl get nodes -o wide >${nodeInfo}
  #whatever success or failure, return 0
  return 0
}
function getLiveNodes(){
  local nodes=$1
  local nodeList=""
  for node in ${nodes}
  do
      ping -c 3  ${node} >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        nodeList="${nodeList} ${node}"
      fi
  done
  echo ${nodeList}
}