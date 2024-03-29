################### utilities Begin ###################

function tolowerCase() {
  local str=$1
  local upperStr=$(echo ${str} | tr '[:upper:]' '[:lower:]')
  echo ${upperStr}
}

function SSHCMD() {
  if [ "${logLevel}" -gt 7 ] ; then
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3  "$@"
  else
     ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 -q  "$@"
  fi
}

function SSHCMDShell() {
  local host=$1
  local tmpfile=setupk8s-$(date +"%Y-%m-%d-%T")
  local command=$2

  cat ${command} >${rootDir}/${tmpfile}
  SCPCMD ${rootDir}/${tmpfile} ${host}:/tmp
  SSHCMD ${host} "bash /tmp/${tmpfile}"
  RC=$?
  if [ ${RC} = "0" ]; then
    SSHCMD "rm -rf /tmp/${tmpfile}"
  else
    log "check the error execute on ${host} /tmp/${tmpfile} " ${RC}
  fi
  rm -rf ${rootDir}/${tmpfile}
}

function SCPCMD() {
  scp -q -o StrictHostKeyChecking=no -o ConnectTimeout=3 "$@" 2>&1
}

function log() {
  local logMessage=$1
  local result="Success"
  if [ -n "$2" ]; then
    result="Success"
    [ "$2" -eq 0 ] || result="Failed"
  fi
  logfile=${workDir}/output/main.log
  echo "[$(date +"%Y-%m-%d-%T")]  $logMessage" ${result} >>${logfile}
  echo "[$(date +"%Y-%m-%d-%T")]  $logMessage" ${result}
}

#todo bug if there is no "ip" command ?
function getLocalHostIP(){
   local ipAddr=$(ip -o addr  | grep eth0 | grep -w inet | awk '{print $4}')
   echo ${ipAddr%/*}
}

function loadProperties(){
 local configFile=$1
 local unset=$2
  set -x
 [ -f "${configFile}" ] || return $?

 while read line; do
    case $line in
    '^$' | '#*') ;;

    [[:word:]]*)
      if [ "${unset}" = "true" ]; then
        line=${line%%=*}'=  '
      fi
      eval "${line}"
      ;;

    *) ;;

    esac
  done <${configFile}

}

function getHostName(){
   local targetIP=$1
   local hostName=$(grep "${targetIP}" ${workDir}/lab/${LAB_NAME}/nodes.ini | awk '{print $1}')
   echo ${hostName}
   return 0
}

function setNodeConfig(){
  local component=${1%_*}
  local nodeName=$(getHostName ${SSH_HOST})
  [ -f ${workDir}/lab/${LAB_NAME}/${nodeName}/${component}.ini ] || return 0
  loadProperties  ${workDir}/lab/${LAB_NAME}/${nodeName}/${component}.ini
}

function unsetNodeConfig(){
  local component=${1%_*}
  local nodeName=$(getHostName ${SSH_HOST})
  [ -f ${workDir}/lab/${LAB_NAME}/${nodeName}/${component}.ini ] || return 0
  loadProperties  ${workDir}/lab/${LAB_NAME}/${nodeName}/${component}.ini "true"
}

function setConfig(){
  local component=${1%-*}
  [ -f ${workDir}/lab/${LAB_NAME}/${component}.ini ] || return 0
  loadProperties  "${workDir}/lab/${LAB_NAME}/${component}.ini"
}

function unsetConfig(){
  local component=${1%-*}
  [ -f ${workDir}/lab/${LAB_NAME}/${component}.ini ] || return 0
  loadProperties  "${workDir}/lab/${LAB_NAME}/${component}.ini"  "true"
}

function trs(){
  set +x
  local out=''
  input=$(echo -e $1 )
  for i in $(seq ${#input})
  do
  tmp=${input:$i-1:1}
    case ${tmp} in
    \\)
        tmp='\\'
    ;;
    \})
        tmp='\}'
    ;;
    \[)
        tmp='\['
    ;;
    \$)
       tmp='\$'
    ;;
    \')
       tmp="\'"
    ;;
    \")
       tmp='\"'
    ;;
    ' ')
       tmp=' '
    ;;
    esac
   out=${out}${tmp}
  done

  echo $out
}
function trs1(){
  local out=''
  input=$(echo -e $1 )
  for i in $(seq ${#input})
  do
  tmp=${input:$i-1:1}
    case ${tmp} in
    \/)
        tmp='\/'
    ;;
    esac
   out=${out}${tmp}
  done
  echo $out
}

function logResult() {
  set +x
  local RC=$2
  local function=$1
  if [ "$RC" = "0" ] ; then
    echo "${function} success"
  else
    echo  "${function} failed"
  fi
}
function replaceVariablsAll(){
  local path=$1
  local varComponents=$2
  local files=$(find ${path} -name "*.*" | xargs)
  for file in ${files}
  do
    for component in ${varComponent//[~]/ }
    do
       replaceVariabls ${component} ${file}
    done
  done
}

function replaceVariabls(){
  local type=$1
  local file=$2
  [ -f ${file} ]  || return $?
  local vars=$(cat ${workDir}/lab/${LAB_NAME}/${type}.ini | grep -v "#" | awk '{print $1}'| xargs)
  local value=''
  local key=''
  local escapeValue=''
  for var in ${vars}
  do
    eval $var
    key=${var%%=*}
    eval "value=\$$key"
    escapeValue=$(trs1 $value )
    #escapeValue=${value/\//\\/}
    sed -i "s/${key}/${escapeValue}/g" ${file}
  done

}

function convertVariabls(){
  local infile=$1
  local file=$2
  [ -f ${file} ]  || return $?
  local vars=$(cat ${infile}| grep -v "#" | awk '{print $1}'| xargs)
  local value=''
  local key=''
  local escapeValue=''
  for var in ${vars}
  do
    eval $var
    key=${var%%=*}
    eval "value=\$$key"
    escapeValue=$(trs1 $value )
    #escapeValue=${value/\//\\/}
    sed -i "s/\${${key}}/${escapeValue}/g" ${file}
  done

}

function replaceNodeVariabls(){
  local type=$1
  local file=$2
  [ -f ${file} ]  || return $?
  local nodeName=$(getHostName ${SSH_HOST})
  local vars=$(cat ${workDir}/lab/${LAB_NAME}/${nodeName}/${type}.ini | grep -v "#" | awk '{print $1}'| xargs)
  local value=''
  local key=''
  local escapeValue=''
  for var in ${vars}
  do
    eval $var
    key=${var%%=*}
    eval "value=\$$key"
    escapeValue=$(trs1 $value )
    #escapeValue=${value/\//\\/}
    sed -i "s/${key}/${escapeValue}/g" ${file}
  done

}

#--------------------------------------------------------
# utility function to diff two set
# Input: arrayA : A
#        arrayB : B
# OutPut: arrayC : A-B
#         currentWorkNodes -- k8s Work Nodes
#--------------------------------------------------------
function complementSet() {
  eval "local arrayA=\$$1"
  eval  "local arrayB=\$$2"
  local arrayC
  local flag=0
  for a in ${arrayA[@]}; do
    flag=0
    for b in ${arrayB[@]}; do
      [ "$a" = "$b" ] && flag=1
    done

    [ $flag -eq 0 ] && arrayC+=(  $a)
  done
  echo ${arrayC[@]}
}


function getNodeListByType(){
   local type=$1
   local nodeInfo=${workDir}/lab/${LAB_NAME}/nodes.ini
   nodes=($(cat ${nodeInfo} | grep -v "#" | grep -w ${type} | awk '{print $1}' | xargs))
   echo "${nodes[@]}"
}

function getNodeIpListByType(){
   local  type=$1
   local nodeInfo=${workDir}/lab/${LAB_NAME}/nodes.ini
   nodes=($(cat ${nodeInfo} | grep -v "#" | grep -w ${type} | awk '{print $4}' | xargs))
   echo "${nodes[@]}"
}

function getNodeList(){
  local nodeInfo=${workDir}/lab/${LAB_NAME}/nodes.ini
  nodes=($(cat ${nodeInfo} | grep -v "#" | awk '{print $1}' | xargs))
  echo "${nodes[@]}"
}


function getNodeIpList(){
   local nodeInfo=${workDir}/lab/${LAB_NAME}/nodes.ini
   nodes=($(cat ${nodeInfo} | grep -v "#" | awk '{print $4}' | xargs))
   echo "${nodes[@]}"
}
function getNodeListByExcludeType(){
   local type=$1
   local nodeInfo=${workDir}/lab/${LAB_NAME}/nodes.ini
   nodes=($(cat ${nodeInfo} | grep -v "#" | grep -v ${type} | awk '{print $1}' | xargs))
   echo "${nodes[@]}"
}

function getHostIP(){
  local nodeName=$1
  local nodeInfo=${workDir}/lab/${LAB_NAME}/k8s.json
  nodes=($(cat ${nodeInfo} |  jq -r '.k8s.controlPlaneEndpointIP'))
  echo "${nodes[@]}"
}

function getNodeIpListByExcludeType(){
   local type=$1
   local nodeInfo=${workDir}/lab/${LAB_NAME}/nodes.ini
   nodes=($(cat ${nodeInfo} | grep -v "#" | grep -v ${type} | awk '{print $1}' | xargs))
   echo "${nodes[@]}"
}

function isMasterNode(){
  local node=$1
  local type="master"
  cat ${nodeInfo} | grep -v "#" | grep -w ${type} | grep -w ${node}
  ret=$?
  log "isMasterNode $node" $ret
  return $ret
}

function getNodeListByExcludeType(){
   local type=$1
   nodes=($(cat ${nodeInfo} | grep -v "#" | grep -v ${type} | awk '{print $1}' | xargs))
   echo "${nodes[@]}"
}

function getK8sNodeListByNodeType(){
   local type=$1
   nodes=($(kubectl get nodes --show-labels | grep nodeType=${type} | awk '{print $1}' | xargs) )
   echo "${nodes[@]}"
}

function getParam(){
  local serverParams=$1
  local key=$2
  local value=$(jq -j .${key} ${serverParams})
  echo ${value}
}

#copy the remote file or folder to local
function scpFileExp() {
  local serverParams=${GLOBAL_PARAMS_JSON}

  local user=$(getParam ${serverParams} USER)
  local passwd=$(getParam ${serverParams} PASSWORD)
  local remoteFile=$(getParam ${serverParams} REMOTE_PATH)
  local localFile=$(getParam ${serverParams} LOCAL_PATH)

  [ -d ${localFile} ] || mkdir -p ${localFile}


  cat <<EOF >>$1
send -- "mkdir -p   ${localFile} \r "
expect -re "${prompt}"
send -- "scp -r  ${user}@${remoteFile} ${localFile} \r"
expect {
  *sername* {
    send -- "${passwd}\r"
    exp_continue
  }
  *continue* {
    send -- "yes\r"
    exp_continue
  }

  *assword* {
    send -- "${passwd}\r"
  }
  "*Proceed insecurely*" {
    send -- "y\r"
    exp_continue
  }
}
expect -re "${prompt}"

EOF
}

#copy the local file or folder to remote
function scpUpFileExp() {
  local serverParams=${GLOBAL_PARAMS_JSON}

  local user=$(getParam ${serverParams} USER)
  local passwd=$(getParam ${serverParams} PASSWORD)
  local remoteFile=$(getParam ${serverParams} REMOTE_PATH)
  local localFile=$(getParam ${serverParams} LOCAL_PATH)


  cat <<EOF >>$1
send -- "mkdir -p   ${localFile} \r "
expect -re "${prompt}"
send -- "scp -r  ${localFile} ${user}@${remoteFile}/  \r"
expect {
  *sername* {
    send -- "${passwd}\r"
    exp_continue
  }
  *continue* {
    send -- "yes\r"
    exp_continue
  }

  *assword* {
    send -- "${passwd}\r"
  }
  "*Proceed insecurely*" {
    send -- "y\r"
    exp_continue
  }
}
expect -re "${prompt}"

EOF
}