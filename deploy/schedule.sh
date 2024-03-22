function scheduleTask() {
  local taskName=$1
  local scheduleFile=/home/opuser/workflow/task/${taskName}.yaml

  argo -n argo submit ${scheduleFile}
}

function scheduleCronTask() {
  local taskName=$1
  local cronTime=$2
  local params=$3
  local scheduleFile=/home/opuser/workflow/task/${taskName}.yaml

  argo -n argo cron create ${scheduleFile} --schedule="${cronTime}" --parameter-file=${params}
}

