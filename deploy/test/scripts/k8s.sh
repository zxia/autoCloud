function rebootK8sComponentS(){
  local workdir="/etc/kubernetes/manifests"
  local components=$(ls ${workdir}/*.yaml | xargs)
  local backup=/home/opuser/backup/manifests
  [ -d ${backup} ] &&  rm -rf ${backup}
  mkdir -p ${backup}
  mv ${workdir}/*.yaml ${backup}/  || return $?
  sleep 30
  cp -r ${backup}/*.yaml ${workdir}/
  sleep 30
}