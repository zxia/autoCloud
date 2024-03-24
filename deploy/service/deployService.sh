function deployHelmPackage(){
  local serviceName=$1
  local subName=$2
  local labName=$3
  local namespace=$4

  local type=$1
  local appName=$(echo ${subName}| sed 's/v[0-9]\{1,3\}//g')
  local helmPackage=${serviceName}-${appName}
  local helmName=${serviceName}-${subName}
  nameSpace=${nameSpace:=default}

  local package=${workDir}/output/helm/${helmPackage}
  local opValue=${workDir}/output/data/${helmName}/values.yaml
  local deValue=${workDir}/output/data/${helmName}/devValues.yaml
  local configDir=${workDir}/output/conf/${labName}/${helmName}

  if [ -d ${configDir} ]; then
    [ -d ${package}/files ] || mkdir -p ${package}/files
    rm  -rf ${package}/files/*
    cp -rf ${configDir}/*  ${package}/files/
  fi

 # helm upgrade --install -f ${userValue} -f ${opValue} ${type} ${package} -n ${nameSpace} || return $?
 # helm upgrade --install -f ${userValue}  ${helmName} ${package} -n ${nameSpace} || return $?
   helm upgrade --install -f ${opValue} -f ${deValue} ${helmName} ${package} -n ${nameSpace} || return $?
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

  local package=${workDir}/helm/${helmPackage}
  local userValue=${workDir}/configure/${type}/userValues.yaml
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
  docker || return 0
  local sas=$(kubectl get sa -n ${namespace}   | grep -v NAME | awk '{print $1}'| xargs)
  local regcred=regcred
  for sa in ${sas} ; do
     kubectl patch serviceaccount  ${sa} -n ${namespace}  -p "{\"imagePullSecrets\": [{\"name\": \"${regcred}\"}]}" || return $?
  done
}

function labelNode(){
  local serviceName=$1
  local nodes=$(cat ${workDir}/deploy.ini| grep ${serviceName} | awk '{print $2}' | tr -d \" )
  kubectl label nodes ${nodes} ${serviceName}=${serviceName} --overwrite=true
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


workDir=$(dirname $0)
if [ ${workDir:0:1} = '.' ]; then
     workDir=${PWD}
elif [  ! ${workDir:0:1} = '/' ]; then
      workDir=${PWD}/${workDir}
fi

#--------------------------------------------------------
# deploy the service
# INPUT:
#   - serviceName:  micro-service name
#   - subName:   [ appV1,appv2 network]
#   - labName:  the k8s cluster
#   - domain :  the domain where the service will be scheduled.
#
# --------------------------------------------------------
labelNode $1
deployHelmPackage $1 $2 $3 $4