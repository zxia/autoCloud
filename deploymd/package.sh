function loadScripts(){
  local command=$1
  loadFunction core  || return $?
  case ${command} in
  deploy)
    loadFunction deploy  || return $?
    loadFunction paas || return $?
  ;;
  build)
    loadFunction build  || return $?
    loadFunction build/images  || return $?
  ;;
  manage)
    loadFunction manage || return $?
  ;;
  *)
    log "unsupported $command"
    return 1
  ;;
 esac
}
baseFile=""
function loadFunction() {
  local fold=${workDir}/$1
  [ -d ${fold} ] || return $?
  files=( $(ls ${fold}/*.sh) )

  for file in ${files[@]}
  do
     mergeFunction ${baseFile} $file
  done

}
function mergeFunction() {
  local baseFile=$1
  local newFile=$2
  cat ${newFile} | grep -v "#!"  >> ${baseFile}
}

function buildPackage(){
  local command=$1
  baseFile=${workDir}/output/${command}/${command}.sh
  [ -d ${baseFile%/*} ] && rm -rf ${baseFile%/*}
  mkdir -p ${baseFile%/*}
cat << EOF > ${baseFile}
#!/usr/bin/bash
EOF
 loadScripts ${command}
 mergeFunction ${baseFile} ${workDir}/dp.sh
 shc -v -r -f ${baseFile}
 cp ${baseFile}.x  ${workDir}/output/${command}/cli
 cat ${baseFile}.x | base64 > ${workDir}/output/${command}/.dp
 rm -rf ${baseFile}.*
 rm -rf ${baseFile}

 cp -r dp.c ${workDir}/output/${command}/
 cd ${workDir}/output/${command}/
 gcc dp.c -o dp

 rm -rf dp.c dp.o

}

function deliveryLogic(){
  local command=$1
  case ${command} in
  deploy)
  \cp -r ${workDir}/logic  ${workDir}/output/${command}/
  \cp -r ${workDir}/template ${workDir}/output/${command}/
  \cp -r ${workDir}/custom ${workDir}/output/${command}/
  \cp -r ${workDir}/version ${workDir}/output/${command}/
  \cp -r ${workDir}/data  ${workDir}/output/${command}/
  \cp  -r ${workDir}/version  ${workDir}/output/${command}/
  ;;
  build)
  \cp -r  ${workDir}/logic  ${workDir}/output/${command}/
  \cp -r ${workDir}/template ${workDir}/output/${command}/
  \cp -r ${workDir}/lab ${workDir}/output/${command}/
  \cp -r ${workDir}/data ${workDir}/output/${command}/
  \cp -r ${workDir}/version ${workDir}/output/${command}/
  ;;
  esac
}

workDir=$(dirname $0)

if [ ${workDir:0:1} = '.' ]; then
     workDir=${PWD}
elif [  ! ${workDir:0:1} = '/' ]; then
      workDir=${PWD}/${workDir}
fi

find . -name "*.*" | xargs dos2unix

version=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')
buildPackage $1
deliveryLogic $1
cd ${workDir}/output
tar cvzf $1_${version}.tar.gz $1