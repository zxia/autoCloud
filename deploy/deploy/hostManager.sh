function genSSHkeyExp(){

  [ -d ${localFile} ] || mkdir -p ${localFile}
  cat << EOF >> $1
send --  "ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519\r"
expect -re ${prompt}
EOF
}
#未完成有些问题
function copySSHKeyExp(){
  local hosts="$(echo $2 | tr -d \')"
  for host in ${hosts}
  do
  cat << EOF >> $1
send --  "ssh-copy-id ${host}\r"
expect "assword"
send -- "${SSH_ROOT_PASSWORD}\r"
expect -re ${prompt}
EOF
  done
}

function etcdHealthCheck(){
  export NODE_IPS="$1"
for ip in ${NODE_IPS}; do
  ETCDCTL_API=3 etcdctl \
  --endpoints=https://${ip}:2379  \
  --cacert=/etc/kubernetes/ssl/ca.pem \
  --cert=/etc/kubernetes/ssl/etcd.pem \
  --key=/etc/kubernetes/ssl/etcd-key.pem \
  endpoint health; done

for ip in ${NODE_IPS}; do
  ETCDCTL_API=3 etcdctl \
  --endpoints=https://${ip}:2379  \
  --cacert=/etc/kubernetes/ssl/ca.pem \
  --cert=/etc/kubernetes/ssl/etcd.pem \
  --key=/etc/kubernetes/ssl/etcd-key.pem \
  --write-out=table endpoint status; done

}

function rebootHosts(){
  local clusterName=$1
  local hosts=$(cat /etc/kubeasz/clusters/${clusterName}/hosts  \
      | grep -r "k8s_nodename=[w|m].*" | awk '{print $1}'| xargs )
  for host in $hosts ; do
    ssh $host reboot
  done
}