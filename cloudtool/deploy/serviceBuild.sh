function genServerlessData() {
  [ -d ${workDir}/output/service/${TASK_NAME} ] || mkdir -p ${workDir}/output/service/${TASK_NAME}
  cat ${GLOBAL_PARAMS_JSON} | jq .TASK_PARAM >${workDir}/output/service/${TASK_NAME}/task_params_$$

  if [ -d ${SOURCE_CONF} -a -n "${SOURCE_CONF}" ]; then
    rsync -ar "${SOURCE_CONF}" ${workDir}/output/service/${TASK_NAME}/
  elif [ -d ${workDir}/data/deploy/paas/${TASK_NAME} ]; then
    rsync -ar ${workDir}/data/deploy/paas/${TASK_NAME} ${workDir}/output/service
  else
    return 0
  fi

}

function scheduleServerless() {
  local serviceName=$1
  local serverParams=$2
  local knParam="$(jq -j '. |to_entries|.[]|select(.key != "env" and .key != "traffic" )|" --"+.key + " " + (.value|@json) ' ${serverParams})"
  local envParam="$(jq -j '.env |to_entries|.[]|" --env "+.key + "=" + (.value|@json) ' ${serverParams})"
  local trafficParam="$(jq -j '.traffic |to_entries|.[]|" --traffic "+.key + "=" + (.value|@json) ' ${serverParams})"

  kn service list | grep -v NAME | awk '{print$1}' | grep -e ^${serviceName}$
  if [ $? -eq 0 ]; then
    command="kn service update ${serviceName} ${knParam} ${envParam} ${trafficParam}"
  else
    command="kn service create ${serviceName} ${knParam} ${envParam}"
  fi

  eval "${command}"
}

function scheduleDocker() {
  local serviceName=$1
  local serverParams=$2
  local optionParam="$(jq -j '. |to_entries|.[]|select(.key != "volume" and .key != "exec" and .key != "image" )|" --"+.key + " " + (.value|@json) ' ${serverParams})"
  local volumeParam="$(jq -j '.volume |to_entries|.[]|" --volume "+.key + ":" + (.value|@json) ' ${serverParams})"
  local execParam="$(jq -j '.exec |to_entries|.[]|" "+.key + " " + (.value|@json) ' ${serverParams})"
  local image="$(jq -j '.image' ${serverParams})"

  docker stop ${serviceName}
  docker rm ${serviceName}

  command="docker run -it -d  --name ${serviceName} ${optionParam}  ${volumeParam} ${image}  ${execParam}"

  eval "${command}"
}


function buildImage() {
  local dependency="getParam"
  local serverParams=$1
  local serviceName=$(getParam ${serverParams} SERVICE_NAME)
  local image=$(getParam ${serverParams} IMAGE)
  local localPath=/home/opuser/docker/${serviceName}

  [ -d ${localPath} ] || mkdir -p ${localPath}

  echo "FROM eclipse-temurin:11.0.18_10-jdk" >${localPath}/Dockerfile
  echo "COPY files/${serviceName}.jar /opt/acx/${serviceName}/bin/" >>${localPath}/Dockerfile

  docker build -t ${image} ${localPath}  || return $?
  docker push ${image}  || return $?

}

function deleteK8sNodeLabel(){
  local node=$1
  local label=$2
  kubectl label node ${node} ${label}-
}

function deleteK8sNodesLabels() {
  local dependency="deleteK8sNodeLabel"
  local label=$1
  local nodes=$(kubectl get nodes -l ${label} -o jsonpath='{.items[*].metadata.name}')
  for node in ${nodes}; do
    deleteK8sNodeLabel ${node} ${label}
  done
}
