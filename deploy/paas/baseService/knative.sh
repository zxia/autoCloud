function setupKnative(){

  isKnativeSupport || return 0

  local types=( knative-serving knative-eventing )

  for type in ${types[@]}
  do
    createDomain ${type} || return $?
  done

  for type in ${types[@]}
  do
    labelPaasNodes ${type}
  done

  deployKnative || return $?

  waitFunctionReady  300  "healthCheckPods knative-serving "  || return $?
  waitFunctionReady  300  "healthCheckPods knative-eventing "  || return $?

  local ret=$?
  log "setupKnative" $ret
  return $ret
}
function  isKnativeSupport(){
   cat ${cnfRoot}/data/k8s/nodes.cnf | grep -v "#" | grep -w knative-eventing || return $?
   cat ${cnfRoot}/data/k8s/nodes.cnf | grep -v "#" | grep -w knative-serving || return $?
}

function deployKnativeOperator(){
   local operatorYaml="${cnfRoot}/k8s/hosts/knative/knative-operator.yaml"
 sed -i "s/regcred/${regcred}/g" ${operatorYaml}
 #local dockerRegistry need to escape the \

 sed -i "s/dockerRegistry/${dockerRegistry/\//\/}/g" ${operatorYaml}
 kubectl config set-context --current --namespace=default
 kubectl apply -f ${operatorYaml} || return $?
 sleep 60

}

function deployKnativeServing(){
 genKnativeServiceYaml  || return $?
 kubectl apply -f ${cnfRoot}/k8s/hosts/knative/knative-serving.yaml || return $?

 sleep 30
}

function deployKnativeDNS(){
  local dnsyaml="${cnfRoot}/k8s/hosts/knative/serving-default-domain.yaml"
 sed -i "s/regcred/${regcred}/g" ${dnsyaml}
 #local dockerRegistry need to escape the \

 sed -i "s/dockerRegistry/${dockerRegistry/\//\/}/g" ${dnsyaml}
 kubectl apply -f ${dnsyaml} || return $?
}
function deployKnativeEventing(){
  genKnativeEventingYaml  || return $?
 kubectl apply -f ${cnfRoot}/k8s/hosts/knative/knative-eventing.yaml || return $?

}
function deployKnative(){
 deployKnativeOperator  || return $?
 deployKnativeServing || return $?
# deployKnativeDNS || return $?
 deployKnativeEventing || return $?
 setupKnativeCert || return $?
}

function genKnativeServiceYaml(){
  cat << EOF > ${cnfRoot}/k8s/hosts/knative/knative-serving.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: knative-serving
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeServing
metadata:
  name: knative-serving
  namespace: knative-serving
spec:
  registry:
    default: ${dockerRegistry}/knative-releases/knative.dev/serving/cmd/\${NAME}:v1.2.0
    imagePullSecrets:
      - name: ${regcred}
    override:
      net-istio-controller/controller: ${dockerRegistry}/knative-releases/knative.dev/net-istio/cmd/controller:v1.2.0
      net-istio-webhook/webhook: ${dockerRegistry}/knative-releases/knative.dev/net-istio/cmd/webhook:v1.2.0
      migrate: ${dockerRegistry}/knative-releases/knative.dev/pkg/apiextensions/storageversion/cmd/migrate:v1.2.0
      default-domain: ${dockerRegistry}/knative-releases/knative.dev/serving/cmd/default-domain:v1.2.0
  config:
    deployment:
      registries-skipping-tag-resolving: "kind.local,ko.local,dev.local,${harbor}"
      queueSidecarImage: ${dockerRegistry}/knative-releases/knative.dev/serving/cmd/queue:v1.2.0
  controller-custom-certs:
    name: ${regcred}
    type: Secret
EOF
}


function genKnativeEventingYaml(){
   cat << EOF > ${cnfRoot}/k8s/hosts/knative/knative-eventing.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: knative-eventing
---
apiVersion: operator.knative.dev/v1alpha1
kind: KnativeEventing
metadata:
  name: knative-eventing
  namespace: knative-eventing
spec:
  registry:
    default: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/\${NAME}:v1.2.0
    imagePullSecrets:
      - name: ${regcred}
    override:
      eventing-controller: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/controller:v1.2.0
      eventing-webhook: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/webhook:v1.2.0
      imc-controller/controller: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/in_memory/channel_controller:v1.2.0
      imc-dispatcher/dispatcher: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/in_memory/channel_dispatcher:v1.2.0
      kafka-controller-manager/manager: ${dockerRegistry}/knative-releases/knative.dev/eventing-kafka/cmd/source/controller:v1.2.0
      mt-broker-controller: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/mtchannel_broker:v1.2.0
      mt-broker-filter/filter: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/broker/filter:v1.2.0
      mt-broker-ingress/ingress: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/broker/ingress:v1.2.0
      migrate: ${dockerRegistry}/knative-releases/knative.dev/eventing/vendor/knative.dev/pkg/apiextensions/storageversion/cmd/migrate:v1.2.0
      sugar-controller/controller: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/sugar_controller:v1.2.0
      receive_adapter: ${dockerRegistry}/knative-releases/knative.dev/eventing/cmd/receive_adapter:v1.2.0
      KAFKA_RA_IMAGE: ${dockerRegistry}/knative-releases/knative.dev/eventing-kafka/cmd/source/receive_adapter:v1.2.0
  source:
    kafka:
      enabled: true
EOF

}

function removeKnative(){

  kubectl delete KnativeServing knative-serving -n knative-serving
  kubectl delete KnativeEventing knative-eventing -n knative-eventing
  kubectl delete -f ${cnfRoot}/k8s/hosts/knative/serving-default-domain.yaml
  kubectl delete -f "${cnfRoot}/k8s/hosts/knative/knative-operator.yaml"
  waitFunctionReady  100  "healthCheckPods knative-eventing "  || return $?
  waitFunctionReady  100  "healthCheckPods knative-serving "  || return $?
}

function setupKnativeCert(){

kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"${regcred}\"}]}"

cat << EOF > ${cnfRoot}/k8s/hosts/knative/controller-cert.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: controller
  namespace: knative-serving
spec:
  template:
    spec:
      containers:
        - name: controller
          volumeMounts:
            - name: custom-certs
              mountPath: /path/to/custom/certs
          env:
            - name: SSL_CERT_DIR
              value: /path/to/custom/certs
      volumes:
        - name: custom-certs
          secret:
            secretName: ${regcred}
EOF
kubectl apply -f  ${cnfRoot}/k8s/hosts/knative/controller-cert.yaml
}

function setupKnativeKafkaSource(){

 local operatorYaml="${cnfRoot}/k8s/hosts/knative/kafka/eventing-kafka-controller.yaml"
 sed -i "s/dockerRegistry/${dockerRegistry/\//\/}/g" ${operatorYaml}
 sed -i "s/regcred/${regcred}/g" ${operatorYaml}

 kubectl apply -f ${operatorYaml}  || return $?

#kubectl patch serviceaccount kafka-controller -p "{\"imagePullSecrets\": [{\"name\": \"${regcred}\"}]}" -n knative-eventing
 operatorYaml="${cnfRoot}/k8s/hosts/knative/kafka/eventing-kafka-source.yaml"
 sed -i "s/dockerRegistry/${dockerRegistry/\//\/}/g" ${operatorYaml}
 sed -i "s/regcred/${regcred}/g" ${operatorYaml}

 kubectl apply -f ${operatorYaml}  || return $?
# kubectl patch serviceaccount knative-kafka-source-data-plane -p "{\"imagePullSecrets\": [{\"name\": \"${regcred}\"}]}" -n knative-eventing
# kubectl patch serviceaccount kafka-webhook-eventing -p "{\"imagePullSecrets\": [{\"name\": \"${regcred}\"}]}" -n knative-eventing


 waitFunctionReady  30  "healthCheckPods knative-eventing "  || return $?

 operatorYaml="${cnfRoot}/k8s/hosts/knative/kafka/event-display-service.yaml"
 sed -i "s/dockerRegistry/${dockerRegistry/\//\/}/g" ${operatorYaml}
 sed -i "s/regcred/${regcred}/g" ${operatorYaml}

 kubectl apply -f ${operatorYaml}  || return $?

 waitFunctionReady  60  "healthCheckPods  knative-eventing "  || return $?

 kubectl apply -f ${cnfRoot}/k8s/hosts/knative/kafka/sources/kafka-event-source.yaml

 local RC=$?

 log "setupKnativeKafkaSource" $RC

 return $RC
}

function deleteKnativeKafkaSource(){
   kubectl delete -f ${cnfRoot}/k8s/hosts/knative/kafka/sources/kafka-event-source.yaml
   kubectl delete -f ${cnfRoot}/k8s/hosts/knative/kafka/event-display-service.yaml
   kubectl delete -f ${cnfRoot}/k8s/hosts/knative/kafka/eventing-kafka-source.yaml
   kubectl delete -f ${cnfRoot}/k8s/hosts/knative/kafka/eventing-kafka-controller.yaml
   waitFunctionReady  60  "healthCheckPods knative-eventing "  || return $?
}