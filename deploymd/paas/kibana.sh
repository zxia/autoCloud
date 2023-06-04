function genEncryptionKey() {
  local ns=${1:=default}
  local encryptionkey=$( openssl rand -base64 32 )
  [ -n ${encryptionkey} ] || return $?
  kubectl create secret generic kibana --from-literal=encryptionkey=$encryptionkey -n ${ns} || return $?
}

function genKibanaValue() {
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}

  cat <<EOF >${userValue}
---
service:
  type: ${KIBANA_SERVICE_TYPE}
  nodePort: 31256
image: "${dockerRegistry}/kibana"
replicas: ${KIBANA_REPLICAS}
elasticsearchHosts: "https://elasticsearch-ingest-headless:9200"
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kibana
              operator: In
              values:
                - kibana
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        podAffinityTerm:
          topologyKey: kubernetes.io/hostname
          labelSelector:
            matchLabels:
              app: kibana
extraEnvs:
  - name: "KIBANA_ENCRYPTION_KEY"
    valueFrom:
      secretKeyRef:
        name: kibana
        key: encryptionkey
  - name: "ELASTICSEARCH_USERNAME"
    valueFrom:
      secretKeyRef:
        name: kibana-user
        key: username
  - name: "ELASTICSEARCH_PASSWORD"
    valueFrom:
      secretKeyRef:
        name: kibana-user
        key: password
# protocol: https
kibanaConfig:
  kibana.yml: |
    server.ssl:
      enabled: false
      key: /usr/share/kibana/config/certs/elastic-certificate.pem
      certificate: /usr/share/kibana/config/certs/elastic-certificate.pem
    xpack.security.encryptionKey: '\${KIBANA_ENCRYPTION_KEY}'
    elasticsearch.ssl:
      certificateAuthorities: /usr/share/kibana/config/certs/elastic-certificate.pem
      verificationMode: certificate
      certificate: /usr/share/kibana/config/certs/elastic-certificate.pem
secretMounts:
  - name: elastic-certificate-pem
    secretName: elastic-certificate-pem
    path: /usr/share/kibana/config/certs
EOF
}