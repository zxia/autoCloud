
function genIstioistiodValue(){
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  cat << EOF > ${userValue}
global:
  hub: ${dockerRegistry}/istio
EOF

}

function genIstiobaseValue(){
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  cat << EOF > ${userValue}
#null
EOF

}


function genIstioingressValue(){
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local gatewayType=${ISTIO_GATEWAY_TYPE}
  cat << EOF > ${userValue}
global:
  hub: ${dockerRegistry}/istio
  tag: 1.14.3
gateways:
  istio-ingressgateway:
    ports:
    ## You can add custom gateway ports in user values overrides, but it must include those ports since helm replaces.
    # Note that AWS ELB will by default perform health checks on the first port
    # on this list. Setting this to the health check port will ensure that health
    # checks always work. https://github.com/istio/istio/issues/12503
    - port: 15021
      targetPort: 15021
      name: status-port
      protocol: TCP
    - port: 80
      targetPort: 8080
      name: http2
      protocol: TCP
    - port: 443
      targetPort: 8443
      name: https
      protocol: TCP
EOF
  cat << EOF1 >> ${userValue}
    type: ${gatewayType}
EOF1

}

function setupIstioDashboard(){
  local dependency="enableJaeger"
  [ -d /home/opuser/istio ]  || mkdir -p /home/opuser/istio
  unzip -o /home/opuser/installpackage/istio-1.14.3.zip -d /home/opuser/istio/ || return $?

  local istioDir=/home/opuser/istio/istio-1.14.3
  kubectl apply -f  ${istioDir}/samples/addons || sleep 5;kubectl apply -f  ${istioDir}/samples/addons
  enableJaeger
}

function enableJaeger(){
  local podName=$(kubectl get pods -n istio-system | grep jaeger | awk '{print $1}')
  kubectl patch svc kiali -n istio-system -p '{"spec": {"type": "NodePort"}}'
 }