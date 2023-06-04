# 数智云平台-主机安装分册（基于数智中台-云图套件）

## 用户管理

- 创建管理用户

````bash 
EXECUTED_PERMISSION="root"
executeExpect SSH "createUser:${SSH_USER}"
executeExpect SSH "changeUserPasswordExp:${SSH_USER} ${SSH_USER_PASSWORD}"
````

## 安装准备工作

````bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH createFold:/home/opuser/installpackage
executeExpect Bash 'rsyncFoldExp:/allinone/installpackage /home/opuser/installpackage'
executeExpect SSH createFold:/home/opuser/deploy
executeExpect Bash "rsyncFoldExp:/${workDir}/output/deploy /home/opuser/deploy"
````

## 主机配置

- 配置主机名称

 ````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH changeHostNameExp
````

- 配置安装repository

````bash
setConfig repo
EXECUTED_PERMISSION="opuser"
genMiddlePlatformRepo
executeExpect Bash "rsyncFoldExp:/allinone/installpackage /home/opuser/installpackage"
genMiddlePlatformRepo
executeExpect SSH "createFold:/home/opuser/deploy/${REPO_VERSION}"
executeExpect Bash "rsyncFoldExp:/${workDir}/output/deploy/${REPO_VERSION} /home/opuser/deploy/${REPO_VERSION}"
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "prepareCtyunOS:${REPO_VERSION}"
executeExpect SSH  "addHostAllow:${LOCAL_HOST_IP}"
executeExpect SSH  "yum update -y"
unsetConfig repo
````

## 磁盘操作

````bash
EXECUTED_PERMISSION="suroot"
setNodeConfig disk 
setNodeConfig docker 
executeExpect SSH  "yum install -y lvm2"
executeExpect SSH "formatFsDisk:${DISK_ERASED} ${DOCKER_PATH} ${DISK_DISK} ${DOCKER_VOLUME} ${DOCKER_LV} ${DISK_VG}"
unsetNodeConfig disk 
unsetNodeConfig docker 
````

#### @由数智云图-自动化云平台构建工具支持
