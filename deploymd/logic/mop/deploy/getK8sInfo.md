# 数智云平台-Kubernetes 安装分册（基于数智中台构建）

## 准备安装命令

 ```bash
setConfig k8s
EXECUTED_PERMISSION="opuser"
executeExpect SSH createFold:/home/opuser/k8s
EXECUTED_PERMISSION="suroot"
ping -c 5 ${SSH_HOST} || exit 0
executeExpect SSH "getLiveK8sNodesInfo"

EXECUTED_PERMISSION="opuser"
rm -rf ${workDir}/output/k8s  || return 0
mkdir -p ${workDir}/output/k8s  || return 0 
executeExpect Bash "rsyncDownFoldExp:${workDir}/output/k8s /home/opuser/k8s"
```

#### @由数智云图-自动化云平台构建工具支持
