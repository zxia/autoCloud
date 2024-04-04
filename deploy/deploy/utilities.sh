function enableNodePort(){
  local service=$1
  local nameSpace=$2

  kubectl patch svc ${service} -n ${nameSpace} \
         -p '{"spec": {"type": "NodePort"}}'
}

function updateRepo() {
  yum clean all
  yum makecache
  yum update -y
  yum install -y jq
}