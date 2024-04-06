function updateSSH() {
  sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config /etc/ssh/ssh_config || return $?
  systemctl restart sshd
}

function createFold(){
  local fold=$1
  [ -d  ${fold} ] || mkdir -p ${fold}
}

function addHostAllow(){
  local nodeIP=$1
  echo "sshd:${nodeIP}" >> /etc/hosts.allow
  systemctl restart sshd
}

function formatFsDisk(){
    local DISK_ERASED=$1
    local largeDisk=$2
    local directory=$3
    local size=$4
    local lvName=$5
    local vgName=$6
    lvs | grep ${lvName}
    isLvCreate=$?

     # remove lvs if possible
    if [ "${DISK_ERASED}" = "true" -a ${isLvCreate} -eq 0 ] ;then
      mount | grep ${largeDisk} && umount  ${largeDisk}
      [ -d "${largeDisk}" -a  -n "${largeDisk}" ]  && rm -rf ${largeDisk}

      lvs  | grep  LV
      if [ $? -eq 0 ]; then
          lvs | awk ' { print $1} ' | grep -v LV  | xargs -I {} lvremove -f /dev/vg01/{} || return  $?
      fi
      vgs  | grep  VG
      if [ $? -eq 0 ];then
          vgs | grep -v VG | awk '{print $1}' | xargs  vgremove || return  $?
      fi

      pvs | grep PV
      if [ $? -eq 0 ];then
         pvs  | grep -v PV | awk '{print $1}' | xargs pvremove  || return  $?
      fi
    fi

    if [ "${DISK_ERASED}" = "true" -o ${isLvCreate} -eq 0 ]; then
      mkfs.xfs -f ${directory} || return $?
      pvcreate -y ${directory} || return $?
      vgcreate -ff -y ${vgName} ${directory}  || return $?
      echo y|lvcreate -L ${size} -n ${lvName} ${vgName}
      mkfs.xfs  -f /dev/${vgName}/${lvName}  || return $?
    fi

    [ -d "${largeDisk}" -a  -n "${largeDisk}" ]  && rm -rf ${largeDisk}
    mkdir -p ${largeDisk}
    sed -i "/${lvName}/d"   /etc/fstab
    echo "/dev/${vgName}/${lvName} ${largeDisk} xfs rw 0 0" >> /etc/fstab
    mount -a  || return $?
}
#create vg
function formatFsDiskNew(){
    local DISK_ERASED=$1
    local largeDisk=$2
    local directory=$3
    local size=$4
    local lvName=$5
    local vgName=$6
    vgs | grep ${vgName}
    isVgCreate=$?

    if [ "${DISK_ERASED}" = "true" -o ${isVgCreate} -eq 0 ]; then
      mkfs.xfs -f ${directory} || return $?
      pvcreate -ff -y ${directory} || return $?
      vgcreate -ff -y ${vgName} ${directory}  || return $?
    fi
}

function prepareCtyunOS() {
   local rpmDir=$1
   rm -rf /etc/yum.repos.d/*.repo
   rsync /home/opuser/deploy/${rpmDir}/middlePlatform.repo  /etc/yum.repos.d/middlePlatform.repo
}

function changeHostNameExp(){
  local targetIP=${SSH_HOST}
  local hostName=$(grep "${targetIP}" ${workDir}/lab/${LAB_NAME}/nodes.ini | awk '{print $1}')
  cat << EOF >> $1
send -- "hostnamectl set-hostname ${hostName}\r"
expect -re ${prompt}
EOF
}

function installKernal(){
  yum install kernel-lt.x86_64 -y
  grub2-set-default 0
  sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' /etc/default/grub
  grub2-mkconfig -o g
}

function addEtcHost(){
  local name=$1
  local ip=$2
  name=$(echo ${name} | tr -d ' ')
  sed -i "/${name}/d"  /etc/hosts
  echo "${ip}    ${name}" >> /etc/hosts
}

function getHostReadyHostIpList(){
  local nodes=$1
  local state
  local nodeList=""
  for node in ${nodes}
  do
     state=$(getHostState $node )
     [ ${state} = 5GMC_HOST -o ${state} = 5GMC_K8S ] && nodeList="$nodeList $node "
  done

  echo ${nodeList}
}
function getHostNotReadyHostIpList(){
  local nodes=$1
  local state
  local nodeList=""
  for node in ${nodes}
  do
     state=$(getHostState $node )
     if [ ${state} = 5GMC_HOST -o ${state} = 5GMC_K8S ]; then
        continue
     else
        nodeList="$nodeList $node "
     fi
  done

  echo ${nodeList}
}

function isInitHostReady(){
    local node=$1
    local liveNode=$(getLiveNodes "${node}")
    if [ -z ${liveNode} ]; then
      echo "node does not live "
      return 1
    fi

    local state=$(getHostState "${node}")

    if [ "${state}" = "5GMC_HOST"  -o "${state}" = "5GMC_K8S" ];then
       return  0
    else
      echo "wrong state is ${state}"
      return 1
    fi

}

function getInitK8sNodeIP(){
  local node=$1
  local state=$(getHostState "${node}")
  if [ "${state}" = "5GMC_HOST" ]; then
    echo "${node}"
  fi
  echo ""
}

function getHostState(){
  local tmpHostDir=${workDir}/output/state
  getHostStateHelper $1
  RC=$?
  local state="UNKNOWN"
  if [ $RC = 0 ]; then
    state=$(cat ${tmpHostDir}/.state)
  fi
  echo ${state}
}


function getHostStateHelper(){
  local tmpHostDir=${workDir}/output/state
  [ -d ${tmpHostDir} ] ||  mkdir -p ${tmpHostDir}
  rm -rf ${tmpHostDir}/.state
  local back_host=${SSH_HOST}
  local back_user=${EXECUTED_PERMISSION}
  local RC=0
  SSH_HOST=$1
  EXECUTED_PERMISSION="opuser"
  executeExpect Bash "rsyncDownFoldExp:${tmpHostDir} /home/opuser/state" >/dev/null || RC=$?

  SSH_HOST=${back_host}
  EXECUTED_PERMISSION=${back_user}

  return $RC
}

