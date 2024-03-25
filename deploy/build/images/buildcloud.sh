function genBuildcloudDockerFile(){

  local dockerPath=${workDir}/output/docker/buildcloud
  local proxy=${BUILDDOCKER_PROXY}
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')

  cat << EOF > ${dockerPath}/dockerfile
FROM ${HARBOR_URI}/library/blueseye:v4.0.0.1109
ADD ./files/build_${version}.tar.gz /
RUN chmod 0755 /build/cli
COPY ./files/openapi  /build/openapi
WORKDIR /build/openapi
CMD ["bash", "build.sh"]
EOF

}
function prepareBuildcloudDockerfile(){
  local dockerPath=${workDir}/output/docker/buildcloud/files
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local proxy=${BUILDDOCKER_PROXY}
  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')
  buildCloud || return $?
  \cp ${workDir}/output/build_${version}.tar.gz  ${dockerPath}
  \cp  -r ${workDir}/openapi  ${dockerPath}/
}

function buildCloud(){
   cd ${workDir}
   bash package.sh deploy  || return $?
   bash package.sh build   || return $?
}
