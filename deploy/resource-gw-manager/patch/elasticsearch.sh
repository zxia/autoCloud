function genElasticsearchmasterValue() {
  local userValues=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local volumeStorage=${ELASTICSEARCH_MASTER_VOLUME}
  local replicas=${ELASTICSEARCH_MASTER_REPLICAS}
  local esPassword=${ELASTICSEARCH_MASTER_PASSWORD}

  cat <<EOF >${userValues}
---
nodeGroup: "master"
image: "${dockerRegistry}/elasticsearch"
replicas: ${replicas}
roles:
  - master
volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  storageClassName: "topolvm-provisioner"
  resources:
    requests:
      storage: ${volumeStorage}
secret:
  enabled: true
  password: "${esPassword}"
createCert: false
protocol: https
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
          - key: app
            operator: In
            values:
              - elasticsearch-master
esConfig:
  elasticsearch.yml: |
    xpack.security.enabled: true
    xpack.security.transport.ssl.enabled: true
    xpack.security.transport.ssl.verification_mode: certificate
    xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.http.ssl.enabled: true
    xpack.security.http.ssl.verification_mode: certificate
    xpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.enrollment.enabled: true
secretMounts:
  - name: elastic-certificates
    secretName: elastic-certificates
    path: /usr/share/elasticsearch/config/certs
EOF
}

function genElasticsearchdataValue() {
  local userValues=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local volumeStorage=${ELASTICSEARCH_DATA_VOLUME}
  local replicas=${ELASTICSEARCH_DATA_REPLICAS}

  cat <<EOF >${userValues}
---
nodeGroup: "data"
image: "${dockerRegistry}/elasticsearch"
replicas: ${replicas}
roles:
  - data
  - data_content
  - data_hot
  - data_warm
  - data_cold
  - data_frozen
secret:
  enabled: false
createCert: false
extraEnvs:
  - name: ELASTIC_PASSWORD
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: password
secretMounts:
  - name: elastic-certificates
    secretName: elastic-certificates
    path: /usr/share/elasticsearch/config/certs
protocol: https
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
          - key: app
            operator: In
            values:
              - elasticsearch-data
esConfig:
  elasticsearch.yml: |
    xpack.security.enabled: true
    xpack.security.transport.ssl.enabled: true
    xpack.security.transport.ssl.verification_mode: certificate
    xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.http.ssl.enabled: true
    xpack.security.http.ssl.verification_mode: certificate
    xpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.enrollment.enabled: true
volumeClaimTemplate:
  accessModes: ["ReadWriteOnce"]
  storageClassName: "topolvm-provisioner"
  resources:
    requests:
      storage: ${volumeStorage}
EOF
}

function genElasticsearchingestValue() {
  local userValues=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local replicas=${ELASTICSEARCH_INGEST_REPLICAS}

  cat <<EOF >${userValues}
---
nodeGroup: "ingest"
image: "${dockerRegistry}/elasticsearch"
replicas: ${replicas}
roles:
  - ingest
persistence:
  enabled: false
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
      - matchExpressions:
          - key: app
            operator: In
            values:
              - elasticsearch-ingest
esConfig:
  elasticsearch.yml: |
    xpack.security.enabled: true
    xpack.security.transport.ssl.enabled: true
    xpack.security.transport.ssl.verification_mode: certificate
    xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.http.ssl.enabled: true
    xpack.security.http.ssl.verification_mode: certificate
    xpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.enrollment.enabled: true
secret:
  enabled: false
createCert: false
protocol: https
extraEnvs:
  - name: ELASTIC_PASSWORD
    valueFrom:
      secretKeyRef:
        name: elasticsearch-master-credentials
        key: password
secretMounts:
  - name: elastic-certificates
    secretName: elastic-certificates
    path: /usr/share/elasticsearch/config/certs
EOF
}

function genESCA() {
  local version=$1
  local esDir=/tmp/elasticsearch-${version}
  [ -d ${workDir}/output/es ] || mkdir -p ${workDir}/output/es
  [ -d ${esDir} ] && rm -rf ${esDir}
  tar -zxvf /allinone/installpackage/elasticsearch-${version}-linux-x86_64.tar.gz -C /tmp/ || return $?
  mkdir -p ${esDir}/ca
  cd ${esDir}
  ./bin/elasticsearch-certutil ca --out ./ca/elastic-stack-ca.p12 --pass '' || return $?
  ./bin/elasticsearch-certutil cert --name elasticsearch --dns elasticsearch-ingest-headless --ca ./ca/elastic-stack-ca.p12 --pass '' --ca-pass '' --out ./ca/elastic-certificates.p12
  openssl pkcs12 -nodes -passin pass:'' -in ./ca/elastic-certificates.p12 -out ./ca/elastic-certificate.pem
  openssl x509 -outform der -in ./ca/elastic-certificate.pem -out ./ca/elastic-certificate.crt
  rsync -av ${esDir}/ca ${workDir}/output/es
}

function genESCASecrets() {
  local esPath=$1
  local namespace=$2
  local kns=$(kubectl get namespace -A | grep ${namespace} | awk '{print $1}')
  [ ! $kns ] && kubectl create namespace ${namespace}
  kubectl delete secret elastic-certificate-crt elastic-certificate-pem elastic-certificates -n ${namespace}
  kubectl create secret generic elastic-certificates --from-file=${esPath}/ca/elastic-certificates.p12 -n ${namespace}  || return $?
  kubectl create secret generic elastic-certificate-pem --from-file=${esPath}/ca/elastic-certificate.pem -n ${namespace} || return $?
  kubectl create secret generic elastic-certificate-crt --from-file=${esPath}/ca/elastic-certificate.crt -n ${namespace} || return $?
}

function addKibanaUser() {
  local namespace=${1:="default"}
  local kibanaUser=$2
  local kibanaPassword=$3
  kubectl exec $(kubectl get pods -n $namespace | grep elasticsearch-ingest | sed -n 1p | awk '{print $1}') -n $namespace -- bin/elasticsearch-users useradd ${kibanaUser} -p ${kibanaPassword} -r kibana_user,kibana_admin,kibana_system || return $?
  kubectl create secret generic kibana-user --from-literal=username=${kibanaUser} --from-literal=password=${kibanaPassword} -n ${namespace}
}
