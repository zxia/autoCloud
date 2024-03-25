
function prepareDockerImage(){
  local type=$1
  isFunction=$(type -t prepareDocker${type^}Image)
  if [ "${isFunction}" = "function" ]; then
    eval prepareDocker${type^}Image
  fi
}

function genDockerInitScript(){
    local type=$1
    [ -n "${type}" ]  || return $?
    local debug=$2
    local buildPath=${workDir}/output/buildDocker/${type}
    [ -d "${buildPath}" ] || mkdir -p ${buildPath}
  cat << 'EOF' >> ${buildPath}/files/init.sh
#!/bin/bash
EOF
    eval genDocker${type^}InitScript || return $?

    if [ "${debug}" = "true" ]; then
    cat << 'EOF' >> ${buildPath}/files/init.sh
while :; do
   sleep 60
done
EOF
  fi
}

function genDockerFile(){
    local type=$1
    local baseImage=${BUILD_DOCKER_BASE_IMAGE}
    local proxy=${BUILDDOCKER_PROXY}
    [ -n "${type}" ]  || return $?

    local buildServer=${workDir}/output/buildDocker/${type}
  #common header
  cat << EOF > ${buildServer}/Dockerfile
FROM ${baseImage}
ENV https_proxy=${proxy}
ENV http_proxy=${proxy}
RUN yum -y install wget
EOF
  # specific part
  eval gen${type^}DockerFile || return $?
  # common tailer
  cat << 'EOF' >> ${buildServer}/Dockerfile
COPY files/init.sh /etc/
RUN chmod 0755 /etc/init.sh
CMD ["/etc/init.sh "]
EOF
}

function genDockerBuildScripts(){
    local service=$2
    local buildType=$1
    local type=${buildType^}${service^}
    local buildScript=${cnfRoot}/k8s/devops/build/dockerBuild/${type}.sh
    local buildServer=\${runDir}/${type}

    [ -f ${buildScript} ] && return 0

    cat << EOF > ${buildScript}
#!/bin/bash
# generated file to describe how to build docker image for ${type}

function genDocker${type}DockerFile(){
   cat << 'EOFB' >> ${buildServer}/Dockerfile
   # write the dockerfile following the docker specification

EOFB
}

function genDocker${type^}InitScript(){

    cat << 'EOFA' >> ${buildServer}/files/init.sh
    # add the init scripts your docker

EOFA
}

function prepareDocker${type^}Image(){

  local buildServer=\${runDir}/${type}
  # copy the files to docker build directory
  #

}

function genDocker${type^}Image(){
  genDockerImage ${buildType}  ${service} true
}

function deploy${type^}Service(){
  local node=\$1
  deployBuild  ${buildType}  ${service} \${node}
}
EOF

}

function deployBuildHelm(){

  local buildType=$1
  local service=$2
  local node=$3
  local type=${buildType^}${service^}

  [ -n "${type}" ] || return 1

  local imageName=${dockerRegistry}/$(tolowerCase ${type})
  local imageTag=${version}

  helm upgrade --install $(tolowerCase ${type})  \
               --set images.repository=${imageName} \
               --set images.tag=${imageTag} \
               --set name=$(tolowerCase ${type})  ${cnfRoot}/helm/buildbox \
               --set  label=${node}

}

function deployBuild(){

  local buildType=$1
  local service=$2
  local type=${buildType^}${service^}
  local dockerRegistry=$3


  [ -n "${type}" ] || return 1

  local imageName=${dockerRegistry}/$(tolowerCase ${type})
  local imageTag=${version}

  docker run -it  -v /home/opuser/build/:build ${imageName}:${imageTag}
}
function genDockerImage()
{
  local buildType=$1
  local service=$2
  local debug=$3
  local type=${buildType^}${service^}
  local dockerRegistry=$4

  [ -n "${type}" ] || return $?

  local imageName=${dockerRegistry}/$(tolowerCase ${type})
  local imageTag=${version}

  local buildServer=${runDir}/${type}
  [ -d "${buildServer}" ] && rm -rf ${buildServer}
  mkdir -p ${buildServer}/files

  prepareDockerImage ${type}

  genDockerInitScript ${type} ${debug}  || return $?

  genDockerFile ${type} || return $?

  cd ${buildServer}
  docker build --tag ${imageName}:${imageTag}  .
  docker push ${imageName}:${imageTag}
}


#############################################################
function genOpensipsInitScript(){
  #https://yum.opensips.org/howto.php
  local type=opensips
  local buildServer=${runDir}/build${type}
  [ -d ${buildServer}/files/ ] || mkdir -p ${buildServer}/files/
  cat << 'EOF' >> ${buildServer}/files/init.sh

EOF
}

function genOpensipsDockerFile(){
    local type=opensips
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/Dockerfile

EOF

}

#############################################################


function genK8sInitScript(){
    local type=K8s
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/files/init.sh
GOPATH=/build/go
export PATH=$PATH:/usr/local/go/bin
if [ ! -d $GOPATH/src/k8s.io/kubernetes ] ; then
  mkdir -p $GOPATH/src/k8s.io
  cd $GOPATH/src/k8s.io
  git clone https://github.com/kubernetes/kubernetes
fi
cd $GOPATH/src/k8s.io/kubernetes
make
EOF
}

function genK8sDockerFile(){
    local type=K8s
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/Dockerfile

RUN  yum install -y make \
     diffutils \
     rsync \
     openssh-clients \
     gcc \
     git \
     wget

RUN  wget --no-verbose --output-document=/go1.15.5.linux-amd64.tar.gz  https://golang.org/dl/go1.15.5.linux-amd64.tar.gz    \
     && tar -C /usr/local -xzf /go1.15.5.linux-amd64.tar.gz \
     && export PATH=$PATH:/usr/local/go/bin \
     && go version \
     && rm -rf /go1.15.5.linux-amd64.tar.gz

EOF

}

function genNodeExporterInitScript(){
    local type=NodeExporter
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/files/init.sh
services=/build/mcas/services/
GOPATH=/build/go
NodeExporterDir=$GOPATH/src/github.com
export PATH=$PATH:/usr/local/go/bin
if [ ! -d ${NodeExporterDir}/node_exporter ] ; then

   mkdir -p ${NodeExporterDir}
   cd  ${NodeExporterDir}
   git  clone https://github.com/prometheus/node_exporter.git
   cd node_exporter/
   git checkout v1.0.1
fi
   cd ${NodeExporterDir}/node_exporter/
   cp  -r ${services}/node_exporter/collector .
   make build
EOF
}

function genNodeExporterDockerFile(){
    local type=NodeExporter
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/Dockerfile

RUN  dnf install -y make \
     openssh-clients \
     git \
     wget

RUN  wget --no-verbose --output-document=/go1.15.5.linux-amd64.tar.gz  https://golang.org/dl/go1.15.5.linux-amd64.tar.gz    \
     && tar -C /usr/local -xzf /go1.15.5.linux-amd64.tar.gz \
     && export PATH=$PATH:/usr/local/go/bin \
     && go version \
     && rm -rf /go1.15.5.linux-amd64.tar.gz

EOF

}
###mcasAlert
function genMcasAlertInitScript(){
    local type=McasAlert
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/files/init.sh
services=/build/mcas/services/
GOPATH=/build/go
NodeExporterDir=$GOPATH/src/github.com
export PATH=$PATH:/usr/local/go/bin

if [ ! -d ${NodeExporterDir} ] ; then
   mkdir -p ${NodeExporterDir}
fi

cp  -r ${services}/mcasAlert/  ${NodeExporterDir}/
cd ${NodeExporterDir}/mcasAlert/
go get github.com/prometheus/alertmanager/template
go build
EOF
}

function genMcasAlertDockerFile(){
    local type=McasAlert
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/Dockerfile

RUN  dnf install -y make \
     openssh-clients \
     git \
     wget

RUN  wget --no-verbose --output-document=/go1.15.5.linux-amd64.tar.gz  https://golang.org/dl/go1.15.5.linux-amd64.tar.gz    \
     && tar -C /usr/local -xzf /go1.15.5.linux-amd64.tar.gz \
     && export PATH=$PATH:/usr/local/go/bin \
     && go version \
     && rm -rf /go1.15.5.linux-amd64.tar.gz

EOF

}
function genPrometheusInitScript(){
    local type=Prometheus
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/files/init.sh
GOPATH=/build/go
promDir=$GOPATH/src/github.com/prometheus
export PATH=$PATH:/usr/local/go/bin
if [ ! -d ${promDir} ] ; then

   mkdir -p ${promDir}
   cd  ${promDir}
   git  clone https://github.com/prometheus/prometheus.git
   cd prometheus/
   make build
fi
EOF
}

function genPrometheusDockerFile(){
    local type=Prometheus
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/Dockerfile

RUN  dnf install -y make \
     openssh-clients \
     git \
     wget

RUN  wget --no-verbose --output-document=/go1.15.5.linux-amd64.tar.gz  https://golang.org/dl/go1.15.5.linux-amd64.tar.gz    \
     && tar -C /usr/local -xzf /go1.15.5.linux-amd64.tar.gz \
     && export PATH=$PATH:/usr/local/go/bin \
     && go version \
     && rm -rf /go1.15.5.linux-amd64.tar.gz

RUN  dnf install -y @nodejs \
     && curl -sL https://dl.yarnpkg.com/rpm/yarn.repo -o /etc/yum.repos.d/yarn.repo \
     && rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg \
     && dnf install -y  yarn \
     && yarn --version
EOF

}

function prepareBuildPromImage(){
  local type=Prom
  local buildServer=${runDir}/build${type}

  cp  ${rootDir}/host/mcasMeasureExporter.sh ${buildServer}/files/
  cp  ${rootDir}/host/app.tar ${buildServer}/files/
  cp  ${rootDir}/host/node_exporter ${buildServer}/files/
  cp  ${rootDir}/host/mcasAlert ${buildServer}/files/
  cp  ${rootDir}/host/mcasPromHealthCheck.sh ${buildServer}/files/healthCheck.sh
}

function genPromInitScript(){
    local type=Prom
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/files/init.sh
if [ -d /host-ssh ];then
   [ -d /root/.ssh ] || mkdir -p /root/.ssh
   cp -r /host-ssh/id_rsa*  /root/.ssh/
fi
cd /measurement
nohup node_exporter --collector.textfile.directory="/svc" \
              --web.listen-address=":${port}" \
              --web.disable-exporter-metrics \
              --collector.disable-defaults \
              --collector.textfile &
nohup /usr/bin/mcasAlert &
bash /measurement/mcasMeasureExporter.sh
EOF
}

function genPromDockerFile(){
    local type=Prom
    local buildServer=${runDir}/build${type}
    cat << 'EOF' >> ${buildServer}/Dockerfile

RUN dnf -y install java-11-openjdk.x86_64 \
    && dnf -y install openssh-clients \
    && dnf -y install openssh-server \
    && dnf -y install openssh \
    && dnf -y install rsync \
    && dnf -y install which \
    && mkdir -p /svc \
    && mkdir -p /measurement
ENV http_proxy ''
ENV https_proxy ''
COPY files/mcasMeasureExporter.sh /measurement
COPY files/app.tar /
COPY files/node_exporter /bin/node_exporter
COPY files/mcasAlert  /bin/mcasAlert
COPY files/healthCheck.sh /bin/
RUN cd / \
    && tar xvf app.tar \
    && chmod 0755 /bin/node_exporter \
    && chmod 0755 /bin/mcasAlert \
    && chmod 0755 /bin/healthCheck.sh

EOF
}

function genJavaInitScript(){
    local type=Java
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/files/init.sh
echo "genJavaInitScript"

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk

services=/build/mcas/services/
javaPath=/build/java

[ -d ${javaPath} ] || mkdir -p ${javaPath}
[ -d ${javaPath}/mcasNodeManager ] || rm -rf  ${javaPath}/mcasNodeManager

cp -r ${services}/mcasNodeManager  ${javaPath}/
cd  ${javaPath}/mcasNodeManager
gradle -Dhttps.proxyHost=135.245.48.34 -Dhttps.proxyPort=8000 build

[ -d ${javaPath}/mcasMeasurementConvertor ] || rm -rf ${javaPath}/mcasMeasurementConvertor
cp -r ${services}/mcasMeasurementConvertor ${javaPath}/
cd  ${javaPath}/mcasMeasurementConvertor
gradle -Dhttps.proxyHost=135.245.48.34 -Dhttps.proxyPort=8000 build
echo "build mcasMeasurementConvertor success"

EOF
}

function genJavaDockerFile(){
    local type=Java
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/Dockerfile
RUN dnf -y install java-11-openjdk-devel.x86_64 \
     openssh-clients \
     wget \
     unzip \
     git
ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 6.7.1
ARG GRADLE_DOWNLOAD_SHA256=3239b5ed86c3838a37d983ac100573f64c1f3fd8e1eb6c89fa5f9529b5ec091d
RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle
EOF

}
function genAnsibleInitScript(){
    local type=Ansible
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/files/init.sh
if [ -d /host-ssh ];then
   [ -d /root/.ssh ] || mkdir -p /root/.ssh
   cp -r /host-ssh/id_rsa*  /root/.ssh/
fi
EOF
}

function genAnsibleDockerFile(){
    local type=Ansible
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/Dockerfile
RUN dnf makecache \
   && dnf -y install epel-release \
   && dnf makecache \
   && dnf -y install ansible
EOF

}

function genSIPInitScript(){
    local type=SIP
    local buildServer=${runDir}/build${type}

    cat << 'EOF' >> ${buildServer}/files/init.sh
 [ -d /usr/local/src/kamailio-devel ] || mkdir -p /usr/local/src/kamailio-devel
 cd /usr/local/src/kamailio-devel
 rm -rf *
 git clone --depth 1 --no-single-branch https://github.com/kamailio/kamailio kamailio
 cd kamailio
 make cfg
 echo "include_modules= db_mysql" >> src/modules.lst
 make all
 make install

EOF
}

function genSIPDockerFile(){
    local type=SIP
    local buildServer=${runDir}/build${type}
    cat << EOF >> ${buildServer}/proxy.conf
Acquire {
  HTTP::proxy "http://135.245.48.34:8000";
  HTTPS::proxy "http://http://135.245.48.34:8000";
}
EOF
    cat << EOF >> ${buildServer}/Dockerfile
COPY proxy.conf /etc/apt/apt.conf.d
RUN apt-get update
RUN apt-get -y install apt-utils

RUN apt-get -y install git\
   && apt-get -y install gcc g++ \
   && apt-get -y install flex \
   && apt-get -y install bison \
   && apt-get -y install default-libmysqlclient-dev \
   && apt-get -y install make autoconf pkg-config \
   && apt-get -y install libssl-dev \
   && apt-get -y install libcurl4-openssl-dev \
   && apt-get -y install libxml2-dev \
   && apt-get -y install libpcre3-dev \
   && apt-get -y install default-mysql-server\
   && apt-get -y install apt-get install procps\
   && apt-get -y install apt-get install vim
EOF

}


function mountCentOs(){
  cdrom=/mnt/cdrom
  centosDVD=/system/CentOS-8.2.2004-x86_64-dvd1.iso
  [ -d ${cdrom} ] || mkdir -p ${cdrom}
  mount -o loop ${centosDVD} ${cdrom}
  cp -v ${cdrom}/media.repo  /etc/yum.repos.d/centos8.repo
  chmod 644 /etc/yum.repos.d/centos8.repo
cat << EOF > /etc/yum.repos.d/centos8.repo
[InstallMedia-BaseOS]
name=CentOS Linux 8 - BaseOS
metadata_expire=-1
gpgcheck=1
enabled=1
baseurl=file://${cdrom}/BaseOS/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[InstallMedia-AppStream]
name=CentOS Linux 8 - AppStream
metadata_expire=-1
gpgcheck=1
enabled=1
baseurl=file://${cdrom}/AppStream/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
EOF

}

function buildOpensips(){
  genMesImage build opensips
}

function triggerServiceBuild(){
  local buildPath=/PLATsoftware/build


}

function triggerFullBuild() {
    local buildPath=/PLATsoftware/build
    enableDockerProxy
    sleep 60

    genMesImage build Java
    genMesImage build NodeExporter
    genMesImage build McasAlert

    helm uninstall buildnodeexporter
    helm uninstall buildjava
    helm uninstall buildmcasalert

    [ -d "${buildPath}" ] && rm -rf  ${buildPath}
    mkdir -p ${buildPath}/mcas
    cp -r ${cnfRoot}/services ${buildPath}/mcas/

    deployBuild Java
    deployBuild NodeExporter
    deployBuild McasAlert

    sleep 120

    local mcasNodeManagerJar=/PLATsoftware/build//java/mcasNodeManager/build/libs/mcasNodeManager-0.0.1-SNAPSHOT.jar
    [ -f "${mcasNodeManagerJar}" ] || return $?
    cp -r ${mcasNodeManagerJar} ${rootDir}/host
    log "build mcasNodeManager " $?

    local mcasMeasurementConvertorTar=/PLATsoftware/build/java/mcasMeasurementConvertor/app/build/distributions/app.tar
    [ -f "${mcasMeasurementConvertorTar}" ] || return $?
    cp -r ${mcasMeasurementConvertorTar} ${rootDir}/host
    log "build mcasMeasurementConvertor " $?

    local nodeExporterBin=/PLATsoftware/build/go/src/github.com/node_exporter/node_exporter
    [ -f "${nodeExporterBin}" ] || return $?
    cp -r ${nodeExporterBin} ${rootDir}/host
    log "build nodeExporter " $?

    local nodeExporterBin=/PLATsoftware/build/go/src/github.com/mcasAlert/mcasAlert
    [ -f "${nodeExporterBin}" ] || return $?
    cp -r ${nodeExporterBin} ${rootDir}/host
    log "build mcas Alert gateway " $?

    genMesImage mes prom  || return $?
    disableDockerProxy
    saveMesImages  || return $?
}


function testGenProm(){
  ${cnfRoot}/k8s/setupK8s.sh -b "genMesImage mes prom "
}
function testGenJava(){
  ${cnfRoot}/k8s/setupK8s.sh -b "genMesImage build Java "

}
function testGenK8s(){
  ${cnfRoot}/k8s/setupK8s.sh -b "genMesImage build K8s"
}

function genMesBoxData() {
  mesBox=${dataRoot}/helm/mesbox
  [ -d "${mesBox}" ] || mkdir -p ${mesBox}
  mkdir -p ${mesBox}
  activePilotIP=$(grep ActivePilot /etc/hosts | awk '{print $1}')

  cat << EOF > ${mesBox}/userValues.yaml
mesprom:
  env:
    - port:
      name: port
      value: ${mesPrometheusPort}
    - ActivePilot:
      name: ActivePilot
      value: ${activePilotIP}
    - mcasAlarmPort:
      name: mcasAlarmPort
      value: ${mcasAlarmPort}
EOF
}

function startMesPrometheus(){
  genMesBoxData || return $?
  helm upgrade --install -f ${dataRoot}/helm/mesbox/userValues.yaml mesbox ${helmRoot}/mesbox || return $?

  log "startMesPrometheus" 0
  return 0
}

function genAliyunImage(){
  local genImageFunction=$1
  local internetImage=$2
  local tag=$3
  local privateImage=${dockerRegistry}/${internetImage#*/}
  [ -n ${tag} ] && privateImage=${privateImage[@]%@*}:${tag}

  local workDir=${cnfRoot}/run/buildDocker
  [ -d ${workDir} ] && mv ${workDir}  ${workDir}.$(date +"%Y-%m-%d-%T" | tr -d ':')
  mkdir -p ${workDir}
  cd ${workDir}
  git clone https://deepblue2022:8acc0487cd397aaa21d022ae9a6a1b6e@code.aliyun.com/deepblue2022/buildDocker.git
  cd buildDocker
  git config user.name "deepblue2022"
  git config user.email "15803109@qq.com"
  eval "${genImageFunction} ${internetImage}"
  git commit -am "${genImageFunction} ${internetImage}"
  git push
  sleep 120
  docker login -u deepblue2022 -p wps200000 registry.cn-beijing.aliyuncs.com
  docker pull registry.cn-beijing.aliyuncs.com/zxia_docker/docker:111
  docker tag registry.cn-beijing.aliyuncs.com/zxia_docker/docker:111 ${privateImage}
  docker push ${privateImage}
}

function genAliyunDocker(){
  local image=$1

  cat << EOF > ${cnfRoot}/run/buildDocker/buildDocker/dockerfile
FROM ${image}
EOF
}

#getKnativeImages knative-serving v1.2.0
#getKnativeImages knative-eventing v1.2.0
function getKnativeImages(){

   local tag=$2
   local namespace=$1
   local images=($(kubectl get pods -n ${namespace} |grep -v NAME | awk '{print $1}' | xargs -I {}  kubectl describe pods {} -n ${namespace} | grep Image: | uniq | grep gcr | awk '{ print $2}'| xargs))
   for image in ${images[@]}
   do
       genAliyunImage "genAliyunDocker" "${image}" ${tag}
   done
}

#formatKnativeImages serving v1.2.0
function formatKnativeImages(){
  local tag=v1.2.0
  local project=$1
  local images=$(docker images | grep knative | grep dev | awk ' {print $1}' | xargs)

  for image in ${images}
  do
     img=${image##*/}
     docker tag ${image}:${tag} ${dockerRegistry}/knative-releases/${project}/${img}:${tag}
     docker push ${dockerRegistry}/knative-releases/${project}/${img}:${tag}
  done
}


