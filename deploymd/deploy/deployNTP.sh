function genChronyValue(){
  [ -d ${workDir}/output/chrony ] || mkdir ${workDir}/output/chrony

  rsync ${workDir}/template/deploy/chrony.conf.tpl  ${workDir}/output/chrony/chrony.conf || return $?
  replaceVariabls chrony ${workDir}/output/chrony/chrony.conf || return $?
}

function deployChrony(){
  local version=$1
  local package=chrony-full-${version}.tgz
  tar xf /home/opuser/installpackage/"${package}"   || return $?
  cd chrony
  rpm -Uvh --force --nodeps '*.rpm'  || return $?
  rsync  /home/opuser/chrony/chrony.conf   /etc/chrony.conf || return $?
  systemctl enable chronyd  || return $?
  systemctl restart chronyd || return $?
  timedatectl status || return $?
  timedatectl set-ntp yes || return $?

}

