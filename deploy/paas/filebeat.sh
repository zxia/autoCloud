# pod加"co.elastic.logs/enabled": "false"
function genFilebeatValue1() {
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local filebeatContainerPath=${FILEBEAT_CONTAINER_PATH}

  cat << EOF > ${userValue}
daemonset:
  labels:
    k8s-app: filebeat
  extraEnvs: []
  extraVolumes:
    - name: varslibdockercontainers
      hostPath:
        path: ${filebeatContainerPath}
  extraVolumeMounts:
    - name: varslibdockercontainers
      mountPath: /containers
      readOnly: true
  filebeatConfig:
    filebeat.yml: |
      output.logstash:
          hosts: ["logstash-logstash:5044"]
      filebeat.autodiscover: #使用filebeat自动发现的方式
        providers:
          - type: kubernetes
            hints.enabled: true
            hints.default_config:
              type: container
              paths:
               - "/containers/${data.kubernetes.container.id}/*-json.log"
  secretMounts: []
image: "${dockerRegistry}/beats/filebeat"
EOF

}
# pod加applogs: kafka 等label
function genFilebeatValue() {
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local filebeatContainerPath=${FILEBEAT_CONTAINER_PATH}

  cat << EOF > ${userValue}
daemonset:
  labels:
    filebeat: filebeat
  extraEnvs: []
  nodeSelector:
    filebeat: "filebeat"
  resources:
    requests:
      cpu: "200m"
      memory: "200Mi"
    limits:
      cpu: "1000m"
      memory: "1000Mi" 
  extraVolumes:
    - name: varslibdockercontainers
      hostPath:
        path: ${filebeatContainerPath}
  extraVolumeMounts:
    - name: varslibdockercontainers
      mountPath: /containers
      readOnly: true
  filebeatConfig:
    filebeat.yml: |
      output.logstash:
          hosts: ["logstash-logstash:5044"]
      filebeat.autodiscover:
        providers:
          - type: kubernetes
            resource: pod
            scope: cluster
            templates:
              - condition:
                  equals:
                    kubernetes.labels.logcollections: fb
                config:
                  - type: container
                    paths:
                      - "/containers/*\${data.kubernetes.container.id}/*-json.log"
  secretMounts: []
image: "${dockerRegistry}/beats/filebeat"
EOF

}