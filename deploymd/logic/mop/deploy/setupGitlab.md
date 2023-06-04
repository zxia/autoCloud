# 数智云平台-Gitlab安装分册（基于数智中台-云图套件）

### 准备工作

````bash
setConfig gitlabBase
setConfig harbor
````

### 安装 Gitlab

- 生成 Gitlab 安装文件并上传到安装主机

````bash
EXECUTED_PERMISSION="opuser"
genGitlabValue
executeExpect SSH "createFold: /home/opuser/gitlab"
executeExpect Bash "rsyncFoldExp:${workDir}/output/gitlab /home/opuser/gitlab"
````

- 安装 Harbor

````bash
EXECUTED_PERMISSION="suroot" 
executeExpect SSH  "loadcrt:${HARBOR_NAME} ${HARBOR_IP}"
executeExpect SSH "prepareGitlab:${GITLABBASE_GITLAB_PORT} ${GITLABBASE_GITLAB_WEBPORT} ${GITLABBASE_GITLAB_SSH_PORT} ${HARBOR_NAME} ${HARBOR_USER} ${HARBOR_PASSWORD} ${HARBOR_LIBRARY}"    
executeExpect SSH "configGitlab"
executeExpect SSH "deployGitlab"
unsetConfig gitlabBase
````
