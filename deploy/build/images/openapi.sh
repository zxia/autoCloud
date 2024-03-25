function genOpenapiOldDockerFile(){

  local dockerPath=${workDir}/output/docker/openapi
  local proxy=${BUILDDOCKER_PROXY}
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')

  cat << EOF > ${dockerPath}/dockerfile
FROM ${HARBOR_URI}/library/blueseye:v4.0.0.1109
COPY ./files/allinone /allinone
ADD ./files/deploy_${version}.tar.gz /
RUN chmod 0755 /deploy/cli
COPY ./files/openapi  /deploy/openapi
COPY ./files/service  /deploy/service
WORKDIR /deploy/openapi
RUN ln /allinone/installpackage/argocd /usr/local/bin/argocd
RUN alias cli="deploy/cli"
RUN unset http_proxy
RUN unset https_proxy
CMD ["bash", "start.sh"]
EOF
}

function genOpenapiDockerFile(){

  local dockerPath=${workDir}/output/docker/openapi
  local proxy=${BUILDDOCKER_PROXY}
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')

  cat << EOF > ${dockerPath}/dockerfile
FROM ${HARBOR_URI}/library/blueseye:3.11
COPY ./files  /deploy
WORKDIR /deploy/openapi
RUN unset http_proxy
RUN unset https_proxy
EOF
}
function prepareOpenapiOldDockerfile(){
  local dockerPath=${workDir}/output/docker/openapi/files
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local proxy=${BUILDDOCKER_PROXY}
  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')
  buildOpenapi || return $?
  \cp /allinone/installpackage/argocd  ${dockerPath}
  \cp ${workDir}/output/deploy_${version}.tar.gz  ${dockerPath}
  \cp ${workDir}/output/build_${version}.tar.gz  ${dockerPath}
  \cp  -r ${workDir}/openapi  ${dockerPath}/
  \cp  -r ${workDir}/service ${dockerPath}/
  rsync -ar /allinone ${dockerPath}/

}
function prepareOpenapiDockerfile(){
  local dockerPath=${workDir}/output/docker/openapi/files
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local proxy=${BUILDDOCKER_PROXY}
  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')
  \cp /allinone/installpackage/argocd  ${dockerPath}
  [ -d ${dockerPath}/deploy/ ] && rm -rf ${dockerPath}/deploy
  mkdir -p ${dockerPath}/deploy

  local files="README.md build cloudtool core custom data deploy dp.c dp.sh lab logic manage openapi  paas package.sh service template test  tools version"
  for fold in  ${files}
  do
      \cp -rf  /deploy/${fold}    ${dockerPath}/deploy/
  done

}

function buildOpenapi(){
   cd ${workDir}
   bash package.sh deploy  || return $?
   bash package.sh build   || return $?
}
