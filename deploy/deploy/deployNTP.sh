function genChronyValue(){
  [ -d ${workDir}/output/chrony ] || mkdir ${workDir}/output/chrony

  rsync ${workDir}/template/deploy/chrony.conf.tpl  ${workDir}/output/chrony/chrony.conf || return $?
  replaceVariabls chrony ${workDir}/output/chrony/chrony.conf || return $?
}


function deployChrony(){
  local role=$1

  yum install chrony -y || return $?
  rsync  /home/opuser/chrony/chrony.conf   /etc/chrony.conf || return $?
  if [ "${role}"  = "server" ]; then
     sed -i "s/^server.*iburst$/server 127.0.0.1 iburst/g" /etc/chrony.conf
  fi
  systemctl enable chronyd  || return $?
  systemctl restart chronyd || return $?
  timedatectl status || return $?
  timedatectl set-ntp yes || return $?
  timedatectl set-timezone Asia/Shanghai || return $?
}