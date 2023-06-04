# 数智云平台-Containerd 安装分册（基于数智中台-云图套件）

### 安装 Containerd

- 生成 containerd 安装文件并上传到安装主机

````bash
EXECUTED_PERMISSION="opuser"
setNodeConfig containerd 
setConfig harbor
genContainerdFile
executeExpect Bash "rsyncFoldExp:${workDir}/output/deploy /home/opuser/deploy"
````

- 安装 Containerd

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "addEtcHost:${HARBOR_NAME} ${HARBOR_IP}"
executeExpect SSH  "loadcrt:${HARBOR_NAME} ${HARBOR_IP}"
executeExpect SSH "deployContainerd"
unsetNodeConfig containerd 
unsetConfig harbor
````

#### @由数智云图-自动化云平台构建工具支持