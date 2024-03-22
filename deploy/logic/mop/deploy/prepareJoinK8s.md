# 数智云平台-Kubernetes 安装分册（基于数智中台构建）

## 检查主机是否准备好安装Kubernetes

## 准备安装命令

需要登录到Control plane 结点上去生成相关证书, 将证书下发到本地后，生成joinMaster和joinWork 命令

```bash
EXECUTED_PERMISSION="suroot"
setConfig k8s
setConfig harbor
SSH_HOST_BK=${SSH_HOST}
SSH_HOST=${controlPlaneEndpointIP}
executeExpect SSH "genK8sSetupCerts"
EXECUTED_PERMISSION="opuser"
executeExpect Bash "rsyncDownFoldExp:${workDir}/output/k8sSec /tmp/k8sSec"
unsetConfig harbor
SSH_HOST=${SSH_HOST_BK}
```

#### @由数智云图-自动化云平台构建工具支持
