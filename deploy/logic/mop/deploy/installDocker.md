# 数智云平台-Docker安装分册（基于数智中台-云图套件）

## 通用配置参数

### 安装 Docker

- 生成 Docker 安装文件并上传到安装主机

````bash
EXECUTED_PERMISSION="opuser"
setNodeConfig docker
setConfig harbor
genDockerFile
executeExpect Bash "rsyncFoldExp:${workDir}/output/deploy /home/opuser/deploy"
````

- 安装 Docker

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "addEtcHost:${HARBOR_NAME} ${HARBOR_IP}"
executeExpect SSH  "loadcrt:${HARBOR_NAME} ${HARBOR_IP}"
executeExpect SSH "deployDocker"
unsetConfig harbor
unsetNodeConfig docker
````

#### @由数智云图-自动化云平台构建工具支持