function enableNodePort(){
  local service=$1
  local nameSpace=$2

  kubectl patch svc ${service} -n ${nameSpace} \
         -p '{"spec": {"type": "NodePort"}}'
}