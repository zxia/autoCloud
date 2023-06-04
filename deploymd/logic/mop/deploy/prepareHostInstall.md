# 数智云平台-主机安装分册（基于数智中台-云图套件）

## 通用配置参数

```
LOCAL_HOST_IP=$(getLocalHostIP)
```

## 安装配置

- 安装准备工作

````bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH createFold:/home/opuser/installpackage
executeExpect Bash "rsyncFoldExp:/allinone/installpackage /home/opuser/installpackage"
````

- 配置安装repository, 并更新yum

````bash
setConfig repo
EXECUTED_PERMISSION="opuser"
genMiddlePlatformRepo
executeExpect SSH "createFold:/home/opuser/deploy/${REPO_VERSION}"
executeExpect Bash "rsyncFoldExp:${workDir}/output/deploy/${REPO_VERSION} /home/opuser/deploy/${REPO_VERSION}"
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "prepareCtyunOS:${REPO_VERSION}"
executeExpect SSH  "addHostAllow:${LOCAL_HOST_IP}"
executeExpect SSH  "yum update -y"
unsetConfig repo
````

- 安装Helm

````bash
EXECUTED_PERMISSION="suroot"
executeExpect Bash "rsyncFoldExp:/allinone/installpackage /home/opuser/installpackage"
executeExpect SSH "deployHelm"
````

#### @由数智云图-自动化云平台构建工具支持
