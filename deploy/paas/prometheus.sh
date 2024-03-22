
function genPrometheusValue() {
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local volume["alertmanager"]=${PROMETHEUS_ALERT_MANAGER_VOLUME}
  local volume["prometheus"]=${PROMETHEUS_SERVER_VOLUME}
  cat <<EOF >${userValue}
alertmanager:
  ## alertmanager container image
  ##
  image:
    repository: ${dockerRegistry}/prometheus/alertmanager
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: alertmanager
            operator: In
            values:
            - "alertmanager"
  persistentVolume:
    ## If true, alertmanager will create/use a Persistent Volume Claim
    ## If false, use emptyDir
    ##
    enabled: true
    storageClass: topolvm-provisioner
    size: ${volume["alertmanager"]}
configmapReload:
  prometheus:
    enabled: true
    ## configmap-reload container image
    ##
    image:
      repository: ${dockerRegistry}/jimmidyson/configmap-reload
  alertmanager:
    enabled: true
    ## configmap-reload container image
    ##
    image:
      repository: ${dockerRegistry}/configmap-reload
nodeExporter:
  ## node-exporter container image
  ##
  image:
    repository: ${dockerRegistry}/prometheus/node-exporter
server:
  ## Prometheus server container image
  ##
  image:
    repository: ${dockerRegistry}/prometheus/prometheus
  ## Node labels for Prometheus server pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  replicaCount: 2
  statefulSet:
    enabled: true
  extraFlags:
    - web.enable-lifecycle
    - storage.tsdb.retention.size=10GB
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: prometheus
            operator: In
            values:
            - "prometheus"
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - podAffinityTerm:
            labelSelector:
              matchLabels:
                app: "prometheus"
            namespaces:
              - "default"
            topologyKey: kubernetes.io/hostname
          weight: 1
  persistentVolume:
    ## If true, Prometheus server will create/use a Persistent Volume Claim
    ## If false, use emptyDir
    ##
    enabled: true
    storageClass: topolvm-provisioner
    size: ${volume["prometheus"]}
kube-state-metrics:
  image:
    repository: ${dockerRegistry}/kube-state-metrics/kube-state-metrics
pushgateway:
  ## pushgateway container image
  ##
  image:
    repository: ${dockerRegistry}/prom/pushgateway
  ## Node labels for pushgateway pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
EOF
genAlertManagerValues  ${userValue}
appendJobValue ${userValue}
}

function genAlertManagerValues(){
local valueFile=$1
cat << EOF >> ${valueFile}

## alertmanager ConfigMap entries
##
alertmanagerFiles:
  alertmanager.yml:
    global: {}
      # slack_api_url: ''

    receivers:
      - name: mcas-receiver
        webhook_configs:
        - url: 'http://${controlPlaneEndpoint}:${mcasAlarmPort}/webhooks/${appName}'
          send_resolved: true
    route:
      group_wait: 10s
      group_interval: 5m
      receiver: mcas-receiver
      repeat_interval: 3h

## Prometheus server ConfigMap entries
##
serverFiles:
  ## Alerts configuration
  ## Ref: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
  alerting_rules.yml:
    groups:
      - name: Instances
        rules:
          - alert: InstanceDown
            expr: up == 0
            for: 5m
            labels:
              severity: CRITICAL
            annotations:
              description: '{{ \$labels.instance }} of job {{ \$labels.job }} has been down for more than 5 minutes.'
              summary: 'Instance {{ \$labels.instance }} down'
EOF

}
#genOpenSipsPrometheusJob $userValue
function appendJobValue(){
  local userValue=$1
  cat << EOF >> ${userValue}
extraScrapeConfigs: |
  - job_name: kafka-metric
    static_configs:
    - targets:
      - kafka-metrics:9308
EOF

  for genPrometheusFun in ${genPrometheusJobs}
  do
     eval ${genPrometheusFun}  ${userValue}
  done

}
