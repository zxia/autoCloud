# 数智云平台-Kubernetes 安装分册（基于数智中台构建）

## 通用配置参数

## 检查主机是否准备好安装Kubernetes

```bash
setConfig k8s
[ "${controlPlaneEndpointIP}" = ${SSH_HOST} ] || return 0
```

## 开始安装Kubernetes

```bash
EXECUTED_PERMISSION="suroot"
setConfig harbor
initKubernetes
executeExpect SSH "kubectl taint nodes --all node-role.kubernetes.io/control-plane-"
unsetConfig k8s
unsetConfig harbor
```

## 安装CNI

- ### 上传helm包，生成和配置定制化数据

```bash
EXECUTED_PERMISSION="opuser"
setConfig k8s
setConfig harbor
executeExpect SSH createFold:/home/opuser/helm
executeExpect Bash 'rsyncFoldExp:/allinone/helm /home/opuser/helm'
genValue calico
executeExpect SSH createFold:/home/opuser/configure
executeExpect Bash "rsyncFoldExp:${workDir}/output/helm  /home/opuser/configure"

EXECUTED_PERMISSION="suroot"

#executeExpect SSH "undeployService calico tigera-operator-v3.23.3.tgz  tigera-operator"
executeExpect SSH "createDomain:tigera-operator ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
executeExpect SSH "deployService calico tigera-operator-v3.23.3.tgz  tigera-operator"
executeExpect SSH 'systemctl restart containerd'
executeExpect SSH  "waitFunctionReady:300 'healthCheckPods kube-system' "
unsetConfig harbor
unsetConfig k8s
```

#### @由数智云图-自动化云平台构建工具支持
