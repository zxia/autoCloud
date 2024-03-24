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
  local serverName=$1
  local serverParams=$2
  local knParam="$(jq -j '. |to_entries|.[]|select(.key != "env" and .key != "traffic" )|" --"+.key + " " + (.value|@json) ' ${serverParams})"
  local envParam="$(jq -j '.env |to_entries|.[]|" --env "+.key + "=" + (.value|@json) ' ${serverParams})"
  local trafficParam="$(jq -j '.traffic |to_entries|.[]|" --traffic "+.key + "=" + (.value|@json) ' ${serverParams})"

  kn service list | grep -v NAME | awk '{print$1}' | grep -e ^${serverName}$
  if [ $? -eq 0 ]; then
    command="kn service update ${serverName} ${knParam} ${envParam} ${trafficParam}"
  else
    command="kn service create ${serverName} ${knParam} ${envParam}"
  fi

  eval "${command}"
}

function scheduleDocker() {
  local serverName=$1
  local serverParams=$2
  local optionParam="$(jq -j '. |to_entries|.[]|select(.key != "volume" and .key != "exec" and .key != "image" )|" --"+.key + " " + (.value|@json) ' ${serverParams})"
  local volumeParam="$(jq -j '.volume |to_entries|.[]|" --volume "+.key + ":" + (.value|@json) ' ${serverParams})"
  local execParam="$(jq -j '.exec |to_entries|.[]|" "+.key + " " + (.value|@json) ' ${serverParams})"
  local image="$(jq -j '.image' ${serverParams})"

  docker stop ${serverName}
  docker rm ${serverName}

  command="docker run -it -d  --name ${serverName} ${optionParam}  ${volumeParam} ${image}  ${execParam}"

  eval "${command}"
}
