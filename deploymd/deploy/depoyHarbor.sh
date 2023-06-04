function prepareHarbor(){
  local version=$1
  local package=harbor-full-${version}.tgz
  tar xvfz /home/opuser/installpackage/"${package}" -C /usr/local  || return $?
  cd /usr/local/harbor-${version}
  tar xf docker-ce-*.tgz || return $?
  cd /usr/local/harbor-${version}/docker-ce
  rpm -Uvh --force --nodeps '*.rpm'  || return $?
  [ -d /etc/docker/ ] || mkdir -p /etc/docker/
  rsync  /home/opuser/harbor/daemon.json   /etc/docker/daemon.json || return $?
  systemctl start docker  || return $?
  systemctl enable docker || return $?
}

function  genHarborConfig(){
  local harborVersion=$1
  tar xvfz /usr/local/harbor-${harborVersion}/harbor-offline-installer-${harborVersion}.tgz -C /usr/local  || return $?
  rsync  /usr/local/harbor-${harborVersion}/docker-compose-Linux-x86_64   /usr/local/bin/docker-compose || return $?
  chmod +x /usr/local/bin/docker-compose
}

function configHarbor(){
  rsync  /home/opuser/harbor/harbor.yaml   /usr/local/harbor/harbor.yml || return $?
}


function genHarborValue(){
  [ -d ${workDir}/output/harbor ] || mkdir ${workDir}/output/harbor

  rsync ${workDir}/template/deploy/harbor.yaml.tpl  ${workDir}/output/harbor/harbor.yaml || return $?
  replaceVariabls harborbase ${workDir}/output/harbor/harbor.yaml || return $?

  rsync ${workDir}/template/deploy/v3.ext.tpl  ${workDir}/output/harbor/v3.ext || return $?
  replaceVariabls harborbase ${workDir}/output/harbor/v3.ext || return $?

  rsync ${workDir}/template/deploy/daemon.json.tpl  ${workDir}/output/harbor/daemon.json || return $?
  replaceVariabls harborbase ${workDir}/output/harbor/daemon.json || return $?

}
#
function deployCrt(){
  local dnsName=$1

  [ -d /opt/cert ] || mkdir -p /opt/cert
  cd /opt/cert
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -nodes -sha512 -days 3650  -subj "/CN=${dnsName}"  -key ca.key  -out ca.crt || return $?
  openssl genrsa -out server.key 4096 || return $?
  openssl req  -new -sha512  -subj "/CN=${dnsName}"  -key server.key  -out server.csr || return $?
  rsync  /home/opuser/harbor/v3.ext   /opt/cert/v3.ext || return $?
  openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -out server.crt || return $?
}

function uploadcrt(){
    [ -d /usr/local/middlePlatform/cert ] || mkdir -p /usr/local/middlePlatform/cert
    rsync /opt/cert/server.crt  /usr/local/middlePlatform/cert/server.crt || return $?
}

function deployHarbor(){
  bash /usr/local/harbor/install.sh --with-chartmuseum || return $?
}

function loadcrt(){
  local hostName=$1
  local hostIP=$2
  [ -d /etc/docker/certs.d/${hostName} ] || mkdir -p /etc/docker/certs.d/${hostName}
  cd /etc/docker/certs.d/${hostName}
  curl -O http://${hostIP}/middlePlatform/cert/server.crt  || return $?
}
