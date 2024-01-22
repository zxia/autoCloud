#!/usr/bin/bash
#-----------------------------------------------------------------
#
# DESCRIPTION:
#	 deploy middle platform
#
# OWNER:
#	Xia ZengWu
#
# NOTES:
#
#
#
#-----------------------------------------------------------------

#init declaration functions, no dependency with the other modular
function loadFunction() {
  local fold=${workDir}/$1
  [ -d ${fold} ] || return 0
  files=( $(ls ${fold}/*.sh) )

  for file in ${files[@]}
  do
      eval " source $file"
  done

}

function getAbsPath(){
  local path=$1

  if [ ${path:0:1} = '.' ]; then
       path=${workDir}
  elif [  ! ${path:0:1} = '/' ]; then
        path=${workDir}/${path}
  fi

  echo ${path}
}

function loadParams(){
 local params=$*
 for param in ${params}
 do
     eval "${param//[~]/ }"
 done

}

function loadScripts(){
  local command=$1
  loadFunction core  || return $?

  case ${command} in
  deploy)
    loadFunction deploy  || return $?
    loadFunction paas || return $?
    loadFunction cloudtool/deploy
  ;;
  build)
    loadFunction build  || return $?
    loadFunction build/images  || return $?
    loadFunction cloudtool/build
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

#---------------------------------------------------#
umask 022
####when failure ,force to exist
set -o errexit
set -o nounset
set -o pipefail


workDir=$(dirname $0)

if [ ${workDir:0:1} = '.' ]; then
     workDir=${PWD}
elif [  ! ${workDir:0:1} = '/' ]; then
      workDir=${PWD}/${workDir}
fi


while getopts "a:b:hj:o:p:i:w:" opt; do
  case ${opt} in
  b)
    shellCommand=${OPTARG}
    mode=bash
    ;;
  a)
    #the config file for special Lab
     configFile=$(getAbsPath ${OPTARG})
     mode=engine
    ;;
  i)
    #the confige file for special Lab
     labinfo=$(getAbsPath ${OPTARG})
    ;;
  o)
    paramaters=${OPTARG}
    ;;
  p)
    initParamaters=${OPTARG}
    loadParams ${initParamaters}
    ;;
  j)
    GLOBAL_PARAMS_JSON=${OPTARG}
    ;;
  w)
     designFile=${OPTARG}
     mode=factory
    ;;
  h)
    exit 1
    ;;
  \? | *)
    echo "Wrong options! ${opt}"
    usage
    exit 1
    ;;
  esac
done

shift $((OPTIND - 1))

loadScripts ${COMMAND}  || exit $?
#init properties file is not mandatory
loadProperties ${labinfo}
loadParams ${paramaters}
setConfig dp
setConfig ssh

if [ "${SSH_HOST}" = "" ]; then
  SSH_HOST=$(getHostIP ${LAB_NAME})
fi

case ${mode} in
bash)
  if [ -n "${shellCommand}" ]; then
    eval "${shellCommand}"
    RC=$?
    log "${shellCommand}" $RC
    exit $RC
  else
    usage
  fi
  ;;
engine)
  runEngine ${configFile}  || exit $?
  ;;
factory)
  runFactory ${designFile} || exit $?
  ;;
*)
  echo " unsupported mode"
  ;;
esac