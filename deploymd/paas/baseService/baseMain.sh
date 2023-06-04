function setupPaas(){
  local components=( ${paasComponents}  )

  for component in ${components[@]}
  do
      isComponentInstalled ${component} && continue

      isComponentSupported ${component} || continue
      if [ $? -eq 0  ] ;
      then
         if [ $(type -t  setup${component^}) = "function" ]; then
             eval setup${component^}
             RC=$?
         else
             setupCommonPaas ${component}
             RC=$?
         fi
      fi
  done

}

function setupCommonPaas(){
  local component=$1
  createDomain "${component}"-system || return $?
  local command='types=${'${component}'System}'
  eval ${command}  || return $?
  for type in $types
  do
    labelPaasNodes ${type} || return $?
  done

  if [ $(type -t  "deploy${component^}") = "function" ]; then
     eval deploy${component^}
     RC=$?
  else
     deployService ${component}  ${component}-system
     RC=$?
  fi

  waitFunctionReady  300  "healthCheckPods ${component}-system "  || return $?

  local ret=$?
  log "setupCommonPaas for component ${component}" $ret
  return $ret
}

function heathCheckComponent(){
  local component=$1
  waitFunctionReady  300  "healthCheckPods ${component}-system "  || return $?

  local ret=$?
  log "checkCommonPaas for component ${component}" $ret
  return $ret
}

function isComponentSupported(){
   local component=$1

   if [ $(type -t  is${component^}Supported) = "function" ]; then
      eval is${component^}Supported
      RC=$?
      log "is${component^})Supported" $RC
      return $RC
  fi

   local types
   local command='types=${'${component}'System}'
   eval ${command}  || return $?

   for type in ${types}
   do
      cat ${cnfRoot}/data/k8s/nodes.ini | grep -v "#" | grep -w ${type} || return $?
   done

   local RC=$?
   log "is component ${component} Supported" $RC
   return $RC
}

function isComponentInstalled(){
  local component=$1

  helm ls | grep ${component}

  if [ $? -ne 0 ]; then
    helm ls  -n ${component}-system | grep ${component}
    return $?
  fi

}

function healthCheckPaas(){

  local components=( ${paasComponents}  )

  for component in ${components[@]}
  do
      eval is${component^}Support
      [ $? -eq 0  ] || continue

      isComponentInstalled ${component}
      if [ $? -ne 0 ]; then
        log "health check ${component} -not installed " 1
      else
         waitFunctionReady  300  "healthCheckPods ${component}-system"
         local RC=$?
         log "health check pods in ${component}-system " $RC
         if [ $RC -ne 0 ];then
           if [ $(type -t  $heathCheck${component^}) = "function" ]; then
               eval heathCheck${component^}
               RC=$?
           fi
         fi
         log "health check ${component} " $RC
      fi
  done

  local RC=$?
  log "healthCheckPaas" $RC

  return $RC

}

function removePaas(){
  local components=( ${paasComponents}  )
  for component in ${components[@]}
  do
       removePaasComponent ${component}
  done
}

function removePaasComponent() {
  local component=$1

  helm ls -n  ${component}-system | grep -v NAME

  if [ $? -eq 0 ]; then
    helm ls -n  ${component}-system | grep -v NAME | awk ' {print $1}' | xargs -I {}  helm uninstall {} -n  ${component}-system  || return $?
  fi

  kubectl get pvc -n ${component}-system |  grep -v NAME
  if [ $? -eq 0 ]; then
    kubectl get pvc -n ${component}-system |  grep -v NAME | grep ${component} |  awk '{ print $1 }' | xargs -I {} kubectl delete pvc  {}  -n ${component}-system  || return $?
  fi

  local  PackageData=${cnfRoot}/data/helm/${component}
  [ -d ${PackageData} ] && rm -rf ${PackageData}

  ret=$?
  log "removePass ${component} " $ret

  return $ret

}

function createDomain() {
  local domain=$1
  [ -n "${domain}" ] || return $?

  kubectl get namespace ${domain} || kubectl create namespace ${domain}
  kubectl get secret ${regcred} -n ${domain} || createImageSecret ${domain}
  local RC=$?
  log "createDomain $domain " $RC
  return $RC
}