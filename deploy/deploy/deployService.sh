
function genValue(){
  local pkg=$1
  local folder="${workDir}/output/helm/${pkg,,}/"
  [ -d ${folder} ] || mkdir -p ${folder}
  pkg=$(echo ${pkg} | tr -d -)
  gen${pkg^}Value ${folder}
}

function convertVariablsAcx(){
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

function genAcxConfigValue(){
    local dependency="convertVariablsAcx trs1"
    local labName=$2
    local packageName=$1
    local appName=${packageName%-*}
    local workDir=/deploy
    local labAppInfo=${workDir}/lab/${labName}/app.ini

    local configTemplateDir=${workDir}/service/app/conf/${appName}
    local outputConf=${workDir}/service/output/conf/${labName}/${packageName}

    [ -d ${outputConf} ] && rm -rf ${outputConf}
    mkdir -p ${outputConf}

    rsync -ar ${configTemplateDir}/  ${outputConf} || return $?

    for file in $(ls ${outputConf}/*.*)
    do
        convertVariablsAcx ${labAppInfo} ${file}
    done
}

function deployService(){

  local type=$1
  local helmPackage=$2
  local nameSpace=$3
  nameSpace=${nameSpace:=default}
  local package=/home/opuser/helm/${helmPackage}
  local userValue=/home/opuser/configure/${type}/userValues.yaml
  helm upgrade --install -f ${userValue} ${type} ${package} -n ${nameSpace} || return $?
  sleep 20
  local regcred=regcred
  kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"${regcred}\"}]}" -n ${nameSpace}
}

function deployK8sService(){

  local type=$1
  local path=$2
  local nameSpace=$3
  nameSpace=${nameSpace:=default}
  kubectl apply -f /home/opuser/${type}/${path} -n ${nameSpace} || return $?
  sleep 10
  local regcred=regcred
  kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"${regcred}\"}]}" -n ${nameSpace}
}

function deployHelmPackage(){

  local type=$1
  local helmPackage=$2
  local nameSpace=$3
  local labName=$4
  nameSpace=${nameSpace:=default}

  local package=/home/opuser/service/helm/${helmPackage}
  local userValue=/home/opuser/service/data/${type}/values.yaml
  local configDir=/home/opuser/service/conf/${labName}/${helmPackage}

  if [ -d ${configDir} ]; then
    [ -d ${package}/files ] || mkdir -p ${package}/files
    rm  -rf ${package}/files/*
    cp -rf ${configDir}/*  ${package}/files/
  fi

  helm upgrade --install -f ${userValue} ${type} ${package} -n ${nameSpace} || return $?
}


function undeployHelmService(){
  local type=$1
  local helmPackage=$2
  local nameSpace=$3
  nameSpace=${nameSpace:=default}

  helm uninstall ${type} -n ${nameSpace}
}

function undeployService(){
  local type=$1
  local helmPackage=$2
  local nameSpace=$3
  nameSpace=${nameSpace:=default}

  local package=/home/opuser/helm/${helmPackage}
  local userValue=/home/opuser/configure/${type}/userValues.yaml
  helm uninstall ${type} -n ${nameSpace}

}
function createDomain() {

  local dependency="createImageSecret"
  local domain=$1
  local securityName=$2
  local securityWord=$3
  local harbor=$4
  local regcred=regcred
  [ -n "${domain}" ] || return $?

  kubectl get namespace ${domain}
  if [ $? -eq '0' ] ;then
    echo "${domain} already created"
  else
    kubectl create namespace ${domain} || return $?
  fi

  kubectl get secret ${regcred} -n ${domain}
  if [ $? -eq '0' ]; then
     echo "${regcred} already created"
  else
    createImageSecret ${domain} ${securityName} ${securityWord} ${harbor} || return $?
  fi

}

function applyRegcredSa(){
  local namespace=$1
  local sas=$(kubectl get sa -n ${namespace}   | grep -v NAME | awk '{print $1}'| xargs)
  local regcred=regcred
  for sa in ${sas} ; do
     kubectl patch serviceaccount  ${sa} -n ${namespace}  -p "{\"imagePullSecrets\": [{\"name\": \"${regcred}\"}]}" || return $?
  done
}

function createImageSecret(){
  local domain=$1
  local securityName=$2
  local securityWord=$3
  local harbor=$4
  kubectl create secret docker-registry  regcred -n $1 \
  --docker-server=${harbor} \
  --docker-username="${securityName}" \
  --docker-password="${securityWord}" \
  --docker-email="xiazw@sugon.cn"
}

function genK8sYaml(){
  local service=$1
  local varComponent=$2
  local tempatePath=$3
  [ -d ${workDir}/output/${service} ] && rm -rf ${workDir}/output/${service}

  [ -z "${tempatePath}" ] && tempatePath=${workDir}/template/deploy/${service}
  rsync -ar ${tempatePath} ${workDir}/output/  || return $?
  replaceVariablsAll ${workDir}/output/${service}  ${varComponent}

}

function genGitHelmService2(){
  local git_base=${GITOPS_LOCAL:=/git}
  local type=$1
  local git_path=${git_base}/${type}

  rsync -av ${workDir}/service/output/helm/   ${git_path}/helm || return $?
  rsync -av ${workDir}/service/output/data/   ${git_path}/data || return $?
}

function genGitHelmService(){
  local git_base=${GITOPS_LOCAL:=/git}
  local type=$1
  local service=$2
  local helmPackage=$3
  local git_path=${git_base}/${type}

  [ -d ${git_path}/helm ] || mkdir -p ${git_path}/helm

  [ -d ${git_path}/helm//${service} ] && rm -rf ${git_path}/helm//${service}

  tar xvfz /allinone/helm/${helmPackage} -C ${git_path}/helm/ || return $?
  if [ ! -d ${git_path}/helm/${service} ] ; then
         mv  ${git_path}/helm/${helmPackage%%-*}  ${git_path}/helm/${service} || return $?
  fi

  [ -d ${workDir}/custom/paas/helm/${service} ] && rsync -av  ${workDir}/custom/paas/helm/${service}  ${git_path}/helm/

  genValue ${service} || return $?

  [ -d ${git_path}/data ] || mkdir -p ${git_path}/data
  rsync -av ${workDir}/output/helm/${service}   ${git_path}/data/  || return $?
}


function labelPaasNodes(){
  local key=$1
  local value=$2
  [ -n "${value}" ] || value=${key}
  local labelFile=${workDir}/lab/${LAB_NAME}/${value}.label
  local nodes=""
  if [ -f ${labelFile} ]; then
    nodes=$(cat ${labelFile})
  else
    nodes=$(getNodeListByType ${value})
  fi
  executeExpect SSH  "kubectl label node ${nodes} ${key}=${value} --overwrite=true" || return $?
  return 0
}

function labelNodes(){
  local key=$1
  local value=$2
  local nodes=$3
  [ -n "${value}" ] || value=${key}
  executeExpect SSH  "kubectl label node ${nodes} ${key}=${value} --overwrite=true" || return $?
  return 0
}

function resetPods(){
  docker > dev/null || return 0
  local namespace=$1
  kubectl get pods -n ${namespace} | grep -v NAME | grep -v 'Running' |  awk '{print $1}'| xargs -I{}  kubectl delete pods {} -n ${namespace}
}

function healthCheckPod() {
  local nameSpace=$1
  local podName=$2

  nameSpace=${nameSpace:="default"}

  kubectl get pods  -n ${nameSpace} | grep ${podName}  || return $?

  kubectl get pods  -n ${nameSpace} |   grep ${podName} | awk '{
  split($2,a,"/",seps);
  if(a[1]==a[2]){
    print "true"
  }else {
    print "false"
  }
  }' > /tmp/healthCheckPod.log

 local ret=1

 cat /tmp/healthCheckPod.log | grep false
 [ $? -eq 0 ] || ret=0

 return $ret

}

function healthCheckPods() {
  local nameSpace=$1

  nameSpace=${nameSpace:="default"}

  kubectl get pods  -n ${nameSpace}  || return $?

  kubectl get pods  -n ${nameSpace} |  grep -v NAME |  grep -v Completed | awk '{
  split($2,a,"/",seps);
  if(a[1]==a[2]){
    print "true"
  }else {
    print "false"
  }
  }' > /tmp/healthCheckPod.log
 local ret=1

 cat /tmp/healthCheckPod.log | grep false
 [ $? -eq 0 ] || ret=0

 return $ret

}

function healthCheckNameSpaces(){

  namespaces=($(kubectl get namespace | grep  -v NAME  | awk '{print $1}'| xargs))
  [ -n "${namespaces}" ]  || return 1

  for name in ${namespaces[@]}
  do
    healthCheckPods ${name} || return 1
  done

  ret=$?
  log "healthCheckNameSpaces" $ret
  return $ret
}

function waitFunctionReady(){
  local timeout=$1
  local funcName=$2
  local dependency="healthCheckPods log "
  # check all
  while :; do
      if [ "${timeout}" -lt 10 ] ; then
        return 1
      else
        eval ${funcName}
		    [ $? -eq 0 ] && return 0
        timeout=$(( timeout-10 ))
		sleep 10
      fi
  done
  return 1
}