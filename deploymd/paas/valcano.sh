function genVolcanoValue(){
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
    cat << EOF > ${userValue}
basic:
  controller_image_name: "${dockerRegistry}/volcanosh/vc-controller-manager"
  scheduler_image_name: "${dockerRegistry}/volcanosh/vc-scheduler"
  admission_image_name: "${dockerRegistry}/volcanosh/vc-webhook-manager"
kubestatemetrics:
  image: ${dockerRegistry}/coreos/kube-state-metrics:v1.9.7
  nodeselector: kubestatemetrics
prom:
  image:  ${dockerRegistry}/prom/prometheus:latest
grafana:
  image:  ${dockerRegistry}/grafana/grafana:latest
custom:
  metrics_enable: true
EOF
}