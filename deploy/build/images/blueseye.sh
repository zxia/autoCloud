function genBlueseyeDockerFile(){
  local dockerPath=${workDir}/output/docker/blueseye
  local proxy=${BUILDDOCKER_PROXY}
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  local  version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')

  cat << EOF > ${dockerPath}/dockerfile
FROM python:3.11.0rc2-bullseye
ENV https_proxy=http://${proxy}
ENV http_proxy=http://${proxy}
RUN apt-get update -y &&
    apt-get install -y  --no-install-recommends\
     expect \
     rsync \
     jq \
     openssh-server \
     vim \
     dialog \
     iputils-ping \
  &&  apt-get clean

COPY ./files/requirements.txt /requirements.txt
RUN pip install --no-cache-dir --upgrade -r /requirements.txt

# 取消代理设置
ENV https_proxy=
ENV http_proxy=

RUN ln -s /bin/bash /usr/bin/bash
EOF

}
function prepareBlueseyeDockerfile(){
  local type=blueseye
  local dockerPath=${workDir}/output/docker/${type}/files
  [ -d ${workDir}/output/docker/${type} ] && rm rf ${workDir}/output/docker/${type}
  [ -d ${dockerPath} ] || mkdir -p ${dockerPath}

  cp -r ${workDir}/data/build/pip/requirements.txt  ${dockerPath}/

}
