function genCentospythonDockerFile(){
  local dockerPath=${workDir}/output/docker/centospython
  local proxy=${BUILD_DOCKER_PROXY}
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
     git\
     openssl-devel \
     bzip2-devl \
     libffi-devel \
     wget
RUN yum remove -y python python3
RUN yum groupinstall -y "Development Tools"
RUN wget https://www.python.org/ftp/python/3.10.8/Python-3.10.8.tgz
RUN tar -xzf Python-3.10.8.tgz
WORKDIR /Python-3.10.8
RUN ./configure --enable-optimizations
RUN make altinstall
ln /usr/local/bin/python3.10  /usr/local/bin/python
ln /usr/local/bin/pip3.10 /usr/local/bin/pip
EOF

}
function prepareOpenapiDockerfile(){
  local dockerPath=${workDir}/output/docker/openapi/files
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local proxy=${BUILD_DOCKER_PROXY}
  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')
  buildOpenapi || return $?
  \cp /allinone/installpackage/argocd  ${dockerPath}
  \cp ${workDir}/output/deploy_${version}.tar.gz  ${dockerPath}
  \cp  -r ${workDir}/openapi  ${dockerPath}/
  \cp  -r ${workDir}/service ${dockerPath}/
}

function buildOpenapi(){
   cd ${workDir}
   bash package.sh deploy  || return $?
   bash package.sh build   || return $?
}
