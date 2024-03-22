# 数智云平台-云图安装装分册（基于数智中台-云图套件）

## 必须工具安装

- 创建管理用户

````
EXECUTED_PERMISSION="root"
executeExpect SSH "createUser:${SSH_USER}"
executeExpect SSH "changeUserPasswordExp:${SSH_USER} ${SSH_USER_PASSWORD}"
````

##  

- 配置安装repository

````
setConfig repo
EXECUTED_PERMISSION="suroot"
executeExpect SSH "createFold:${REPO_PATH}"
executeExpect Bash "rsyncFoldExp:/allinone/repo ${REPO_PATH}"

executeExpect SSH  "prepareCtyunOS"
executeExpect SSH  "curl http://${REPO_HOST}:/repo/middlePlatform.repo -o /etc/yum.repos.d/middlePlatform.repo"
executeExpect SSH  "addHostAllow:${LOCAL_HOST_IP}"
executeExpect SSH  "yum update -y"
unsetConfig repo
````

- 配置主机名称

 ```` 
EXECUTED_PERMISSION="suroot"
executeExpect SSH changeHostNameExp
````

## 磁盘操作

````
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "yum install -y lvm2"
DISK_ERASED="true"
executeExpect SSH "formatFsDisk:${DISK_ERASED}"
````

#### @由数智云图-自动化云平台构建工具支持