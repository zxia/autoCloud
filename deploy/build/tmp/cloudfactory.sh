function genCloudfactoryDockerFile(){
  local dockerPath=${workDir}/output/docker/cloudfactory
  local proxy=${BUILDDOCKER_PROXY}
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')

  cat << EOF > ${dockerPath}/dockerfile
FROM centos:7.9.2009
ENV https_proxy=http://${proxy}
ENV http_proxy=http://${proxy}
RUN yum install -y expect \
     rsync \
     jq \
     openssh-server \
     openssh-clients \
     initscripts \
     git
ADD files/deploy_${version}.tar.gz /
COPY files/argocd   /usr/bin/
EOF

}
function prepareCloudfactoryDockerfile(){
  local dockerPath=${workDir}/output/docker/cloudfactory/files
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local proxy=${BUILDDOCKER_PROXY}
  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')
  buildCloudfactory || return $?
  \cp /allinone/installpackage/argocd  ${dockerPath}
  \cp ${workDir}/output/deploy_${version}.tar.gz  ${dockerPath}
}

function buildCloudfactory(){
   cd ${workDir}
   bash package.sh deploy  || return $?
   bash package.sh build   || return $?
}
