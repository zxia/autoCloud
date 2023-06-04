#!/bin/bash
# generated file to describe how to build docker image for GenNodemanager

function genDockerGenNodemanagerDockerFile(){
   cat << 'EOFB' >> ${runDir}/GenNodemanager/Dockerfile
   # write the dockerfile following the docker specification
RUN yum -y install java-11-openjdk-devel.x86_64 \
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
EOFB
}

function genDockerGenNodemanagerInitScript(){

    cat << 'EOFA' >> ${runDir}/GenNodemanager/files/init.sh
    # add the init scripts your docker
echo "genJavaInitScript"

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk

services=/build/paas/services/
javaPath=/build/java

[ -d ${javaPath} ] || mkdir -p ${javaPath}
[ -d ${javaPath}/mcasNodeManager ] || rm -rf  ${javaPath}/mcasNodeManager

cp -r ${services}/mcasNodeManager  ${javaPath}/
cd  ${javaPath}/mcasNodeManager
gradle  build  || return $?

if [ -f /build/java/mcasNodeManager/build/libs/mcasNodeManager-1.0.0.jar ] ; then
  echo "build mcasMeasurementConvertor success "
  echo " output is /build/java/mcasNodeManager/build/libs/mcasNodeManager-1.0.0.jar"
  return 0
else
  echo "build mcasMeasurementConvertor failed"
  return 1
fi

EOFA
}

function prepareDockerGenNodemanagerImage(){

  local buildServer=${runDir}/GenNodemanager
  # copy the files to docker build directory
  # cp  ${cnfRoot}/k8s/host/mcasMeasureExporter.sh ${runDir}/GenNodemanager/files/

}

function genDockerGenNodemanagerImage(){
  genDockerImage gen nodemanager true  || return $?
}

function deployGenNodeManagerService(){
  local node=$1
  deployBuild  gen nodemanager ${node}
}