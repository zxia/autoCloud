function deployCalico(){
  echo "deployCalico"
}
#setConfig harbor
#setConfig k8s
function genCalicoValue(){
  local path=$1

  cat > ${path}/userValues.yaml <<EOF
tigeraOperator:
  registry: ${HARBOR_URI}/${HARBOR_LIBRARY}
installation:
  registry: ${HARBOR_URI}
  imagePath: ${HARBOR_LIBRARY}/calico
  calicoNetwork:
    bgp: Enabled
    ipPools:
    - cidr: ${podNetworkCidr}/16
      encapsulation: IPIP
    nodeAddressAutodetectionV4:
      kubernetes: NodeInternalIP
EOF

}
function updateCalicoNetworkManagerConf(){
  rsync /home/opuser/deploy/calico.conf  /etc/NetworkManager/conf.d/calico.conf
  systemctl restart NetworkManager
}

function genCalicoNetworkManagerConf(){
  rsync ${workDir}/template/deploy/calico.conf.tpl  ${workDir}/output/deploy/calico.conf
}

#function genCalicoValue(){
#  local path=$1
#
#  cat > ${path}/userValues.yaml <<EOF
#tigeraOperator:
#  registry: ${HARBOR_URI}/${HARBOR_LIBRARY}
#installation:
#  registry: ${HARBOR_URI}
#  imagePath: ${HARBOR_LIBRARY}/calico
#  cni:
#    type: Calico
#  calicoNetwork:
#    bgp: "Enabled"
#    ipPools:
#    - cidr: ${podNetworkCidr}/16
#      encapsulation: IPIP
#    nodeAddressAutodetectionV4:
#      kubernetes: NodeInternalIP
#EOF
#}