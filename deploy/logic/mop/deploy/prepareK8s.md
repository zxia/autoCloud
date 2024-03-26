# 数智云平台-Kubernetes 主机准备安装分册（基于数智中台构建）

## 准备Kubernetes安装

### 安装 kubeadm

```bash
setConfig k8s
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "yum install -y kubeadm kubectl kubelet"
```

### K8s安装需要调整的环境变量

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH   prepareK8sInstall
executeExpect SSH  "forwordIpv4"
setConfig k8s
executeExpect SSH  "addEtcHost: ${controlPlaneEndpoint} ${controlPlaneEndpointIP}"
hostName=$(grep "${SSH_HOST}" ${workDir}/lab/${LAB_NAME}/nodes.ini | awk '{print $1}')
executeExpect SSH  "addEtcHost: ${hostName} ${SSH_HOST}"
unsetConfig k8s 
genCalicoNetworkManagerConf
executeExpect Bash "rsyncFoldExp:${workDir}/output/deploy /home/opuser/deploy"
executeExpect SSH "updateCalicoNetworkManagerConf"
executeExpect SSH  "changeNodeState:5GMC_HOST"
```

#### @由数智云图-自动化云平台构建工具支持