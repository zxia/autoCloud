# 数智云平台-TopoLVM

TopoLVM 是一个 Kubernetes CSI 插件,
它采用CSI和LVM实现了本地存储能力。[官方地址](https://github.com/topolvm/topolvm#readme)

## 通用配置参数

```bash

LOCAL_HOST_IP=$(getLocalHostIP)
```

## 生成配置数据

- 生成TooLVM 配置数据

````bash
EXECUTED_PERMISSION="opuser"
setConfig harbor
setConfig topolvm
#下载k8s scheduler file 
executeExpect SSH "createFold:/home/opuser/topolvm"
EXECUTED_PERMISSION="suroot"
executeExpect SSH "getK8sSchedulerFile"
EXECUTED_PERMISSION="opuser"
executeExpect Bash "rsyncDownFoldExp:${workDir}/output/topolvm /home/opuser/topolvm"
#生成配置文件
genTopolvmFile
genValue topolvm
````

## 上传安装包

````bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH createFold:/home/opuser/helm
executeExpect Bash 'rsyncFoldExp:/allinone/helm /home/opuser/helm'
executeExpect Bash "rsyncFoldExp:${workDir}/output/topolvm /home/opuser/topolvm"
executeExpect SSH createFold:/home/opuser/configure
executeExpect Bash "rsyncFoldExp:${workDir}/output/helm  /home/opuser/configure"
````

## 安装TopoLVM

- 安装Cert-Manager

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "prepareTopolvm"
executeExpect SSH  "installCertManagerCRD"
executeExpect SSH "createDomain:topolvm-system ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_URI}"
executeExpect SSH "deployService topolvm topolvm-8.0.1.tgz  topolvm-system"

````

##安装后清理

````bash
unsetConfig topolvm
unsetConfig harbor
````

#### @由数智云图-自动化云平台构建工具支持