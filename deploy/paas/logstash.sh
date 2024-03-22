
function genLogstashValue(){
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local replicas=${LOGSTASH_REPLICAS}
  cat << EOF > ${userValue}
replicas: ${replicas}
logstashConfig:
  logstash.yml: |
    http.host: 0.0.0.0
    xpack.monitoring.enabled: true
    xpack.monitoring.elasticsearch.username: '${ELASTICSEARCH_USERNAME}'
    xpack.monitoring.elasticsearch.password: '${ELASTICSEARCH_PASSWORD}'
    xpack.monitoring.elasticsearch.hosts: ["https://elasticsearch-ingest-headless:9200"]
    xpack.monitoring.elasticsearch.ssl.certificate_authority: /usr/share/logstash/config/certs/elastic-certificate.crt
  log4j2.properties: |
    status=error
    name=LogstashPropertiesConfig
    appender.console.type=Console
    appender.console.name=plain_console
    appender.console.layout.type=PatternLayout
    appender.console.layout.pattern=[%d{ISO8601}][%-5p][%-25c]%notEmpty{[%X{pipeline.id}]}%notEmpty{[%X{plugin.id}]} %m%n
    appender.json_console.type=Console
    appender.json_console.name=json_console
    appender.json_console.layout.type=JSONLayout
    appender.json_console.layout.compact=true
    appender.json_console.layout.eventEol=true
    rootLogger.level=DEBUG
    rootLogger.appenderRef.console.ref=\${sys:ls.log.format}_console
logstashPipeline:
  logstash.conf: |
    input {
       beats {
          port => "5044"
       }
    }
    output {
      elasticsearch {
        hosts => ["https://elasticsearch-ingest-headless:9200"]
        index => "5gmc-%{+YYYY.MM}-000001"
        user => "\${ELASTICSEARCH_USERNAME}"
        password => "\${ELASTICSEARCH_PASSWORD}"
        cacert => "/usr/share/logstash/config/certs/elastic-certificate.crt"
      }
      stdout { codec => rubydebug }
    }
logstashPatternDir: "/usr/share/logstash/patterns/"
extraEnvs:
  - name: "ELASTICSEARCH_USERNAME"
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: username
  - name: "ELASTICSEARCH_PASSWORD"
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: password
secretMounts:
  - name: elastic-certificate-crt
    secretName: elastic-certificate-crt
    path: /usr/share/logstash/config/certs
image: "${dockerRegistry}/elastic/logstash"
podAnnotations:
  sidecar.istio.io/inject: "false"
volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 1Gi
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: logstash
        operator: In
        values:
        - logstash
httpPort: 9600
extraPorts:
  - name: beats
    containerPort: 5044
service:
   type: NodePort
   ports:
     - name: beats
       port: 5044
       protocol: TCP
       targetPort: 5044
       nodePort: 32376
     - name: http
       port: 9600
       protocol: TCP
       targetPort: 9600
       nodePort: 32377
EOF
}
