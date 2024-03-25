function genCloudfactoryDockerFile(){
  local dockerPath=${workDir}/output/docker/cloudfactory
  local proxy=${BUILD_DOCKER_PROXY}
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')

  cat << EOF > ${dockerPath}/dockerfile
FROM ${HARBOR_URI}/library/blueseye:v4.0.0.01025
RUN ln /bin/bash /usr/bin/bash
ADD files/deploy_${version}.tar.gz /
COPY files/argocd   /usr/bin/
RUN mkdir -p /allinone
COPY files/installpackage /allinone/installpackage
COPY files/helm   /allinone/helm
EOF

}
function prepareCloudfactoryDockerfile(){
  local dockerPath=${workDir}/output/docker/cloudfactory/files
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local proxy=${BUILD_DOCKER_PROXY}
  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')
  buildCloudfactory || return $?
  \cp /allinone/installpackage/argocd  ${dockerPath}
  \cp ${workDir}/output/deploy_${version}.tar.gz  ${dockerPath}
  \cp -r /allinone/installpackage    ${dockerPath}/
  \cp -r /allinone/helm          ${dockerPath}/
}

function buildCloudfactory(){
   cd ${workDir}
   bash package.sh deploy  || return $?
   bash package.sh build   || return $?
}
