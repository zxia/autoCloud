function getImageURI() {
  local serviceName=$1
  local tag=$(getImageTag $serviceName)
  echo ${imageRegistry}/${serviceName}:${tag}
  return
}

function getImageTag(){
  local serviceName=$1
  echo $(cat ${workDir}/service/app/upgrade.ini | grep ${serviceName} | awk '{ print $2"-"$3}')
  return
}

function downloadImage(){
  local serviceName=$1
  local server=$2
  local user=$3
  local password=$4

  local imageURI=$(getImageURI ${serviceName})

  ssh ${server} "/opt/kube/bin/containerd-bin/ctr -n k8s.io images pull -u ${user}:${password} ${imageURI}" >/etc/null || return $?
  ssh ${server} "/opt/kube/bin/containerd-bin/ctr -n k8s.io images list | grep ${imageURI}" || return $?

}

workDir=/opt/acx
imageRegistry="image.sourcefind.cn:5000/acx"


