#!/usr/bin/bash
#-----------------------------------------------------------------
#
# DESCRIPTION:
#	Microservice Generator will generate the cloud native service
# manifest package based on the serviceDefinition file
#
# OWNER:
#	Xia ZengWu
#
# NOTES:
#     refer to development guideLine for contribution
#
#
#-----------------------------------------------------------------

umask 022
####when failure ,force to exist
set -o errexit
set -o nounset
set -o pipefail


#--------------------------------------------------------
# Infrastructure codes
#
# --------------------------------------------------------

workDir=$(dirname $0)
genDir=${workDir}/output


#--------------------------------------------------------
# format the log string and save to the main.log
# INPUT: log string
#        return code
# --------------------------------------------------------
function log() {
  local logMessage=$1
  local retCode=${2:-0}
  silentMode=false
  if [ -n "${retCode}" ]; then
    result="Success"
    [ "${retCode}" -eq 0 ] || result="Failed"
  fi
  logfile=${workDir}/main.log
  if [ "${silentMode}" = "false" ]; then
    echo "[$(date +"%Y-%m-%d-%T")]  $logMessage" ${result} >>${logfile}
    echo "[$(date +"%Y-%m-%d-%T")]  $logMessage" ${result}
  fi
}

#--------------------------------------------------------
# execute the input functions one by one
# INPUT: the strings includes the function list
#
# --------------------------------------------------------
function execFuncs(){
  local functions=( $* )

  for func in ${functions[@]}
  do
    if [ "$(type -t ${func})" = "function" ] ;then
        eval ${func}  || return $?
    fi
  done
}

#--------------------------------------------------------
# Read the service definition file, and assign the variables
# INPUT: service definition file
# --------------------------------------------------------
function loadiniFile() {
  local configFile=$1

  while read line; do
    case $line in
    '^$' | '#*')
    ;;
    [[:word:]]*)
      eval ${line} || return $?
      ;;
    *) ;;
    esac
  done <${configFile}

  local RC=$?
  log "loadiniFile ${configFile}" $RC
  return $RC
}

#--------------------------------------------------------
# Main logic
#
# --------------------------------------------------------


#--------------------------------------------------------
# Main entry to generate the service package
# OUTPUT:
#   helm/service : the generated helm package
#   date/service : the generated configuration value.yaml
#
# --------------------------------------------------------
function genService() {
  genServicePackage || return $?
  genServiceData || return $?

  local RC=$?
  log "genService" $RC
  return $RC
}

#--------------------------------------------------------
# Override the function with specified type
# supported type is [Helm,Knative]
#
# --------------------------------------------------------
function genServicePackage(){
  eval gen${servicePackageType^}ServicePackage || return $?
  log "gen${servicePackageType^}ServicePackage success"
}

#--------------------------------------------------------
# Main entry to generate the service Data
# OUTPUT:
#   helm/service : the generated helm package
#   date/service : the generated configuration value.yaml
#
# --------------------------------------------------------
function genServiceData(){
  genPackageData  || return $?
  genDevConfigTemplate || return $?
  genOpsConfigTemplate || return $?
}

function genPackageData() {
  local functions="gen${servicePackageType^}${serviceWorkLoad^}PackageData \
   gen${servicePackageType^}NetworkPackageData"

  execFuncs "${functions}"
}

function genDevConfigTemplate() {
  local functions="gen${servicePackageType^}${serviceWorkLoad^}DevConfigTemplate \
     gen${servicePackageType^}NetworkDevConfigTemplate"
  execFuncs "${functions}"
}

function genOpsConfigTemplate() {
  local functions="gen${servicePackageType^}${serviceWorkLoad^}OpsConfigTemplate \
    gen${servicePackageType^}NetworkOpsConfigTemplate"
  execFuncs "${functions}"
}


function genHelmServicePackage() {
  local servicePackageDir=${genDir}/helm/
  [ -d ${servicePackageDir} ] || mkdir -p ${servicePackageDir}

  local servicePackage=${servicePackageDir}/${servicePackageName}
  local servicePackageApp=${servicePackage}-app
  local servicePackageNetwork=${servicePackage}-network

  [ -d ${servicePackageApp} ] && rm -rf ${servicePackageApp}
  [ -d ${servicePackageNetwork} ] && rm -rf ${servicePackageNetwork}

  case "${serviceWorkLoad}" in
  deployment)
    cp -r ${workDir}/template/helm/deployment ${servicePackageApp}
    cp -r ${workDir}/template/helm/network ${servicePackageNetwork}
    ;;
  network)
    cp -r ${workDir}/template/helm/network ${servicePackageNetwork}
    ;;
  \? | *)
    log "not support workload ${serviceWorkLoad}" 1
    return 1
    ;;
  esac

}

function genHelmDeploymentPackageData() {
  genHelmChartCustomizeData app || return $?
  genHelmDeploymentValues || return $?
}

function genHelmNetworkPackageData(){
  genHelmChartCustomizeData network || return $?
  genHelmNetworkValues || return $?
}

function genHelmChartCustomizeData() {
  local type=$1
  local servicePackage=${genDir}/helm/${servicePackageName}-${type}
  cat <<EOF >${servicePackage}/Chart.yaml
apiVersion: v2
name: ${servicePackageName}
description: ${servicePackageDescription}
icon: https://sugon.com/sites/all/themes/logo.png
version: ${servicePackageVersion}
appVersion: ${serviceApplicationVersion}
maintainers:
  - name: Xia ZengWu
    mail: xiazw@sugon.com
EOF
}

function genHelmDeploymentValues() {
  local type=app
  local servicePackage=${genDir}/helm/${servicePackageName}-${type}

  cat <<EOF >${servicePackage}/values.yaml
###### Define the Microservice application -- k8s deployment  #####
## define the workload
server:
## define the workload as the deployment
  deployed: "true"
  name: ${servicePackageName}
  version: ${serviceApplicationVersion}
  image:
    repository: ""
    tag:  ""
    pullPolicy: IfNotPresent
    imagePullSecrets: ""
## label the node with "schedulelabel=schedulelabel", the workload will be be scheduled to the labeled k8s node
  schedulelabel:  ${servicePackageName}
## the number of the replication of the pod
  replica: "1"
  command: ""
  livenessProbe: []
  readinessProbe: []
  resources: ""
  preStop: []
## define the environment variable
  env: ""
## define the extra
  extraContainerargs: ""
  volumeMounts: ""
  volumes: ""
EOF

}

function genHelmDeploymentDevConfigTemplate(){
 local version=${serviceApplicationVersion}
 local servicePackage=${genDir}/data/${servicePackageName}-app${version}

 [ -d ${servicePackage} ] || mkdir -p ${servicePackage}

 cat <<EOF >${servicePackage}/devValues.yaml
###### Define the values #####
# the file is generated by serviceGenerator.sh , and as a template
# for service developer to
# define the startup, health check scripts
# define the open capabilities via K8s service
#

server:
##application start command
  command: "sh"
  args:
    - "-c"
    - |
      #!/usr/bin/env bash -e
      [ -d /opt/acx/${servicePackageName}/logs ] || mkdir -p /opt/acx/${servicePackageName}/logs
      bash /opt/acx/${servicePackageName}/script/start.sh
## scripts in container , detect if the application is living
  livenessProbe:
    exec:
      command:
        - sh
        - -c
        - |
          #!/usr/bin/env bash -e
          ls -a /opt/acx/${servicePackageName}/conf
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
## scripts in container , detect if the application is ready
  readinessProbe:
    exec:
      command:
        - sh
        - -c
        - |
          #!/usr/bin/env bash -e
          ls -a /opt/acx/${servicePackageName}/conf
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
## scripts in container , preStop some service if necessary
  preStop:
    exec:
      command:
        - sh
        - -c
        - |
          #!/usr/bin/env bash -e
          bash /opt/acx/${servicePackageName}/script/preStop.sh ${servicePackageName} 8080
EOF

}

function genHelmDeploymentOpsConfigTemplate() {
 local version=${serviceApplicationVersion}
 local servicePackage=${genDir}/data/${servicePackageName}-app${version}

 [ -d ${servicePackage} ] || mkdir -p ${servicePackage}

 cat <<EOF >${servicePackage}/userValues.yaml
## define the workload
server:
  name: ${servicePackageName}
  image:
    repository: "repository"
    tag:  "tag"
    pullPolicy: IfNotPresent
    imagePullSecrets: ""
## the number of the replication of the pod
  replica: 1
  version: ${serviceApplicationVersion}

## define the resource for the pod
  resources:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "1200Mi"
      cpu: "1200m"
  env:
    - name: appVersion
      value: ${servicePackageVersion}
  volumeMounts:
    - name: tmp
      mountPath: /tmp
  volumes:
    - name: tmp
      emptyDir: { }

EOF

}

function genHelmNetworkValues() {
  local type=network
  local servicePackage=${genDir}/helm/${servicePackageName}-${type}
  cat <<EOF >${servicePackage}/values.yaml
server:
  name: ${servicePackageName}

###### Define network service #####
##define the K8s service
service: []
## Service mesh with Istio
## see more ref. https://istio.io/latest/docs/concepts/traffic-management/#retries
istio:
  deployed: false
EOF
}

function genHelmNetworkOpsConfigTemplate(){
  local servicePackage=${genDir}/data/${servicePackageName}-network
  local servicePackageName1=$(echo $servicePackageName | tr -d -)
  [ -d ${servicePackage} ] || mkdir -p ${servicePackage}

  cat <<EOF2 >${servicePackage}/userValues.yaml
##define the K8s service for the workload
service:
EOF2

   for service in ${k8sService}
   do
     cat <<EOF1 >>${servicePackage}/userValues.yaml
  - name: ${servicePackageName}-${service}
    protocols:
      - protocol: TCP
        appProtocol: http
        port: 8080
        targetPort: 8080
EOF1
   done

   if [ "${serviceMesh}" = "istio" ]; then
    cat << EOF3 >> ${servicePackage}/userValues.yaml
## Service mesh with Istio
## see more ref. https://istio.io/latest/docs/concepts/traffic-management/#retries
istio:
  deployed: true
EOF3
  else
    return 0
  fi

  if [ "${gatewayStatus}" = "enable" ]; then
    cat << EOF4 >> ${servicePackage}/userValues.yaml

##define the istio gateway, istio ingress default gateway is ingressgateway
##define the receiving protocol and port , and the from host. allow any host with *
  gateway:
    - name: ${servicePackageName}-gateway
      selector: ingressgateway
      servers:
      - port:
          number: 80
          name: http
          protocol: HTTP
        hosts:
        - "*"
  virtualservice:
  - name: ${servicePackageName}-gateway-vs
    hosts:
      - "*"
    gateways:
      - ${servicePackageName}-gateway
    http:
    - match:
      - uri:
          exact: /productpage
      - uri:
          prefix: /static
      - uri:
          exact: /login
      - uri:
          exact: /logout
      - uri:
          prefix: /api/v1/products
      route:
      - destination:
          host: ${servicePackageName}-srv
          subset: ${serviceApplicationVersion}

EOF4
  fi


  if [ "${virtualServiceStatus}" = "enable" -a "${gatewayStatus}" != "enable" ]; then
    cat << EOF6 >> ${servicePackage}/userValues.yaml
  virtualservice:
EOF6
  fi
  if [ "${virtualServiceStatus}" = "enable" ]; then
    cat << EOF5 >> ${servicePackage}/userValues.yaml
  - name: ${servicePackageName1}
    hosts:
      - ${servicePackageName1}-srv
    http:
      - route:
          - destination:
              host: ${servicePackageName}-srv
              subset: v1
EOF5
 fi

 if [ "${destinationRuleStatus}" = "enable" ]; then
    cat << EOF6 >> ${servicePackage}/userValues.yaml
  destination:
    name: ${servicePackageName1}
    host: ${servicePackageName}-srv
    subsets:
      - name: v1
        labels:
          version: v1
EOF6
 fi
}



### define the global variables
declare -A  gateway
declare -A  destinationRule
declare -A  virtualService
declare -A  faultInjection
declare -A  serviceEntry

while getopts "f:h" opt; do
  case ${opt} in
  f)
    serviceIniFile=${OPTARG}
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

[ -f ${serviceIniFile} ] || exit 1
loadiniFile ${serviceIniFile} || exit 2

#--------------------------------------------------------
# Main entry to generate the helm package from micro-service
# INPUT:
#   - service description file
#
# OUTPUT:
#   - output/helm/${service}-app     : workload helm
#   - output/helm/${service}-network : network helm
#   - output/data/${service}-app{version} : workload example value
#   - output/data/${service}-network      :  network example value
# --------------------------------------------------------
genService