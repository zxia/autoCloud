function deployContainerd(){

  # install procedure from https://github.com/containerd/containerd/blob/main/docs/getting-started.md
  yum install containerd -y || return $?
  rsync /home/opuser/deploy/config.toml  /etc/containerd/config.toml  || return $?
  systemctl daemon-reload
  systemctl enable --now containerd  || return $?

  rsync /home/opuser/deploy/crictl.yaml  /etc/crictl.yaml || return $?

}
function deployContainerdback(){

  # install procedure from https://github.com/containerd/containerd/blob/main/docs/getting-started.md
  tar Cxzvf /usr/local /home/opuser/installpackage/containerd-*-linux-amd64.tar.gz || return $?
  [ -d /usr/local/lib/systemd/system ] || mkdir -p /usr/local/lib/systemd/system
  rsync /home/opuser/deploy/containerd.service /usr/local/lib/systemd/system/  || return $?

  install -m 755 /home/opuser/installpackage/runc.amd64 /usr/local/sbin/runc || return $?

  mkdir -p /opt/cni/bin
  tar Cxzvf /opt/cni/bin /home/opuser/installpackage/cni-plugins-linux-amd64-v*.tgz  || return $?

  [ -d /etc/containerd ] || mkdir -p  /etc/containerd
  rsync /home/opuser/deploy/config.toml  /etc/containerd/config.toml  || return $?
  systemctl daemon-reload
  systemctl enable --now containerd  || return $?

  rsync /home/opuser/deploy/crictl.yaml  /etc/crictl.yaml || return $?

}

function genContainerdFile(){
  local fromDir=${workDir}/template/deploy
  local toDir=${workDir}/output/deploy

  [ -d ${toDir} ] || mkdir -p ${toDir}
  rsync  ${fromDir}/config.toml.tpl   ${toDir}/config.toml || return $?

  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' ${toDir}/config.toml
  replaceVariabls harbor ${toDir}/config.toml || return $?
  replaceNodeVariabls containerd ${toDir}/config.toml || return $?
  rsync ${fromDir}/containerd.service.tpl  ${toDir}/containerd.service || return $?

  rsync ${fromDir}/crictl.yaml.tpl  ${toDir}/crictl.yaml || return $?
}

function deployDocker(){
  # install procedure from https://docs.docker.com/engine/install/centos/
  yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

  yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  [ -d /etc/docker ] || mkdir -p /etc/docker
  rsync /home/opuser/deploy/daemon.json  /etc/docker/daemon.json || return $?
  systemctl restart docker || return $?
}

function genDockerFile(){

  cat << EOF > ${workDir}/output/deploy/daemon.json

{
 "exec-opts": ["native.cgroupdriver=systemd"],
 "log-driver": "json-file",
 "log-opts": {
 "max-size": "50m",
 "max-file": "20"},
 "registry-mirrors": ["https://8ozmms6w.mirror.aliyuncs.com"],
 "data-root": "${DOCKER_PATH}",
 "storage-driver": "overlay2",
 "insecure-registries": [
 ]
}
EOF
}
