

function saveHostRpms(){
  BaseRpm=/tmp/baseRpm
  local component=$1
  centosVersion=$(cat  /etc/system-release  | awk ' { print $1$4 } ' | tr -s '.' '_')
  local rpmDir=${BaseRpm}/${centosVersion}/${component}
  [ -d ${rpmDir} ] && rm -rf ${rpmDir}

  mkdir -p ${rpmDir}

  yum install -y  ${component} --downloadonly --downloaddir=${rpmDir}

}

function setupRepos(){
  local dependency="genEpelRepo upgradeKernel"
  rsync /home/opuser/deploy/kubernetes.repo /etc/yum.repos.d/kubernetes.repo
  rsync /home/opuser/deploy/docker-ce.repo     /etc/yum.repos.d/docker-ce.repo
  rsync /home/opuser/deploy/CentOS7-ctyun.repo      /etc/yum.repos.d/ctyun.repo
  sed -i "s/keepcache=0/keepcache=1/g" /etc/yum.conf
  echo "exclude=centos-release*" >> /etc/yum.conf
  genEpelRepo
  upgradeKernel
 }

function genRepos(){
  genKubernetesRepo || return $?
  genDockerRepo || return $?
}

function genKubernetesRepo(){
  cat <<EOF > ${workDir}/output/deploy/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
 http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
}

function genEpelRepo(){
  yum install epel-release -y
  yum update -y
}

function upgradeKernel(){
   rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
   rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
   yum --enablerepo=elrepo-kernel install kernel-lt -y
}

function genDockerRepo(){
    sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' ${workDir}/output/deploy/docker-ce.repo
}

function saveRpms(){
  local dependency="saveHostRpms"
  local file=/home/opuser/repo/data/component.ini
  [ -f $file ]  || return $?

  local components=$(cat $file | grep -v '#' | xargs )

  for component in ${components[@]}
  do
    saveHostRpms $component
  done
}

