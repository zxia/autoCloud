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

workDir=$(dirname $0)

function loadiniFile() {
  local configFile=$1

  while read line; do

    case $line in
    '^$' | '#*') ;;

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

genDir=${workDir}/output

function genService() {

  genServicePackage || return $?
  genServiceData || return $?
  local RC=$?
  log "genService" $RC
  return $RC
}
function genServicePackage(){
  eval gen${servicePackageType^}ServicePackage || return $?
  log "genServicePackage"
}

function genHelmServicePackage() {
  local servicePackageDir=${genDir}/helm/
  [ -d ${servicePackageDir} ] || mkdir -p ${servicePackageDir}

  local servicePackage=${servicePackageDir}/${servicePackageName}
  local servicePackageApp=${servicePackage}-app
  local servicePackageNetwork=${servicePackage}-network

  [ -d ${servicePackageApp} ] || rm -rf ${servicePackageApp}
  [ -d ${servicePackageNetwork} ] || rm -rf ${servicePackageNetwork}
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

function genServiceData(){
  genPackageData  || return $?
  genDevConfigTemplate || return $?
  genOpsConfigTemplate || return $?
}

function execFuncs(){
  local functions=( $* )

  for func in ${functions[@]}
  do
    if [ "$(type -t ${func})" = "function" ] ;then
        eval ${func}  || return $?
    fi
  done
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
icon: https://ctsi.com/sites/all/themes/logo.png
version: ${servicePackageVersion}
appVersion: ${serviceApplicationVersion}
maintainers:
  - name: Xia ZengWu
    mail: xiazw1@chinatelecom.cn
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
  livenessProbe: ""
  readinessProbe: ""
  resources: ""
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
  command: /bin/sh
    args:
      - c
      - |
        mkdir -p /test
        ls -lrt /test
## scripts in container , detect if the application is living
  livenessProbe:
    exec:
      command:
        - sh
        - -c
        - |
          #!/usr/bin/env bash -e
          curl --fail 127.0.0.1:5066
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
  readinessProbe:
## scripts in container , detect if the application is ready
  readinessProbe:
    exec:
      command:
        - sh
        - -c
        - |
          #!/usr/bin/env bash -e
          filebeat test output
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
EOF

}

function genHelmDeploymentOpsConfigTemplate() {
 local version=${serviceApplicationVersion}
 local servicePackage=${genDir}/data/${servicePackageName}-app${version}

 [ -d ${servicePackage} ] || mkdir -p ${servicePackage}

 cat <<EOF >${servicePackage}/userValues.yaml
## define the workload
server:
  image:
    repository: "repository"
    tag:  "tag"
    pullPolicy: IfNotPresent
    imagePullSecrets: ""
## the number of the replication of the pod
  replica: 1
  version: ${serviceApplicationVersion}

## define the resource for the pod
# resources:
#   requests:
#     memory: "512Mi"
#     cpu: "500m"
#   limits:
#     memory: "1200Mi"
#     cpu: "1200m"
  env:
    - name: appVersion
      value: ${servicePackageVersion}
  extraContainerargs:
    ports:
      - containerPort: 9080
    securityContext:
      runAsUser: 1000
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
        port: 9080
        targetPort: 9080
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

  if [ "${gateway[status]}" = "enable" ]; then
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
          host: ${servicePackageName}-internal
          subset: ${serviceApplicationVersion}

EOF4
  fi


  if [ "${virtualService[status]}" = "enable" -a "${gateway[status]}" != "enable" ]; then
    cat << EOF6 >> ${servicePackage}/userValues.yaml
  virtualservice:
EOF6
  fi
  if [ "${virtualService[status]}" = "enable" ]; then
    cat << EOF5 >> ${servicePackage}/userValues.yaml
  - name: ${servicePackageName1}
    hosts:
      - ${servicePackageName1}-internal
    http:
      - route:
          - destination:
              host: ${servicePackageName}-internal
              subset: v1
EOF5
 fi

 if [ "${destinationRule[status]}" = "enable" ]; then
    cat << EOF6 >> ${servicePackage}/userValues.yaml
  destination:
    name: ${servicePackageName1}
    host: ${servicePackageName}-internal
    subsets:
      - name: v1
        labels:
          version: v1
EOF6
 fi
}

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

genService