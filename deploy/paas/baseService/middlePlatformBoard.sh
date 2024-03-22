function installDashBoard(){
   deployMicroService "middle-platform-dashboard-network"
}
function genDashBoardPortAll(){
  local userValue=$1
  local types="grafana prometheus argo kiali kube argoartifact"

  for type in $types
  do
      genDashboardPort $type $userValue
  done
}

function genDashboardPort() {
  local type=$1
  local userValue=$2
  local middlePlatformPort
  local middlePlatformNodePort
  eval "middlePlatformPort=\$${type}DashboardPort"
  eval "middlePlatformNodePort=\$${type}DashboardNodePort"

  cat <<EOF >>${userValue}
    - port: ${middlePlatformPort}
      nodePort: ${middlePlatformNodePort}
      targetPort: ${middlePlatformPort}
      name: ${type}-dashboard-port
      protocol: TCP
EOF
}