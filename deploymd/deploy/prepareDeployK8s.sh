function genKubeadmConfig(){

  cat << EOF > ${workDir}/data/deploy/kubeadm-config.yaml
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.24.3
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd

EOF
}

function forwordIpv4(){
  echo "overlay" >>  /etc/modules-load.d/k8s.conf
  echo "br_netfilter" >>  /etc/modules-load.d/k8s.conf

  modprobe overlay
  modprobe br_netfilter
  modprobe ipip

  echo "net.bridge.bridge-nf-call-iptables  = 1" >> /etc/sysctl.d/k8s.conf
  echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/k8s.conf
  echo "net.ipv4.ip_forward                 = 1" >> /etc/sysctl.d/k8s.conf

  sysctl --system
}

function prepareK8sInstall(){

  swapoff -a
  sed -i /swap/d /etc/fstab

  setenforce 0
  sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/confi

  systemctl stop firewalld
  systemctl disable firewalld
 # systemctl stop NetworkManager
 # systemctl disable NetworkManager

}
function changeNodeState(){
    [ -d /home/opuser/state ] || mkdir -p  /home/opuser/state
    echo $1 > /home/opuser/state/.state
}