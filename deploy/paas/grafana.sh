
function genGrafanaValue() {
  local  userValue=$1/userValues.yaml
  local  dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local  volume["grafana"]=${GRAFANA_VOLUME}
  local  serviceType=${GRAFANA_SERVICE_TYPE}
  cat <<EOF >${userValue}
#genVersion: ${version}
image:
  registry: ${dockerRegistry}
  repository: grafana/grafana-oss
  tag: "9.0.5"
service:
  type: NodePort
  port: 8180
  targetPort: 3000
  portName: service
  nodePort: 31245
adminUser: admin
adminPassword: Ctsi5G2021
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: grafana
          operator: In
          values:
          - "grafana"
persistence:
  enabled: true
  storageClassName: "topolvm-provisioner"
  size: ${volume["grafana"]}
testFramework:
  enabled: false
downloadDashboardsImage:
  registry: ${dockerRegistry}
  repository: curl
  tag: 7.87.0
initChownData:
  image:
    registry: ${dockerRegistry}
    repository: busybox
    tag: 1.31.1
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.prometheus-system
dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
EOF

local folder=$(ls ${workDir}/data/deploy/grafana_dashboard)
for fold in ${folder}
do
  cat <<EOF1 >> ${userValue}
      - name: ${fold}
        orgId: 1
        folder:  ${fold}
        type: file
        disableDeletion: false
        options:
          path: /var/lib/grafana/dashboards/${fold}
EOF1
done

cat <<EOF2 >> ${userValue}
dashboardsConfigMaps:
EOF2

for fold in ${folder}
do
cat <<EOF3 >> ${userValue}
  ${fold}: "${fold}-grafana-dashboards"
EOF3
done

genGrafanaIni ${userValue}

}

function genGrafanaIni(){
  local userValue=$1
  local grafanaAnonymous=${GRAFANA_ANONYMOUSE}
  [ ${grafanaAnonymous} = "true" ] || return 0

  cat <<EOF >>${userValue}
grafana.ini:
    auth.anonymous:
      enabled: true
EOF
}

function compressDashboard() {
  local DASHBOARDS=$1
  local dirname=$2
  local TMP=${dirname}/tmp
  [ -d ${TMP} ] || mkdir -p ${TMP}
  < "${DASHBOARDS}/$1" jq -c  > "${TMP}/$1"
}

function loadDashboard(){
  local dependency="loadDashboardHelper compressDashboard"
  local dirNames=$(ls /home/opuser/grafana/dashboard/)
  for dirname in ${dirNames}
  do
     loadDashboardHelper ${dirname}
  done
}

function loadDashboardHelper(){
  local dependency="compressDashboard"
  local dirName=$1
  local force=$2
  local DASHBOARDS=/home/opuser/grafana/dashboard/${dirName}
  local TMP=${DASHBOARDS}/tmp

  cd ${DASHBOARDS}
  # Set up grafana dashboards. Split into 2 and compress to single line json to avoid Kubernetes size limits
  for dashboard in $(ls *.json| xargs )
  do
     ${dashboard} ${DASHBOARDS}
  done

  if [ "${force}" = "true"  ]; then
      kubectl get cm ${dirName}-grafana-dashboards -n grafana-system && \
      kubectl delete cm ${dirName}-grafana-dashboards -n grafana-system
  fi

  kubectl get cm ${dirName}-grafana-dashboards -n grafana-system
  local RC=$?

  if [  $RC  -ne "0" ]; then
     kubectl create configmap -n grafana-system ${dirName}-grafana-dashboards \
              --from-file=${DASHBOARDS}
  fi

}