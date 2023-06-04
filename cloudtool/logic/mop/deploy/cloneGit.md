# 原子功能

## GitServer--clone 一个repo

在目标机器上，拉取一个指定repo的代码

### 输入参数

* SSH_HOST :  指定的目标机器

* GIT_LOCAL:  下载的代码临时存放目录

* GIT_URI:  Git RUI  

### 执行命令

```bash
EXECUTED_PERMISSION="root"
setConfig gitops
executeExpect Bash "gitCloneExp:${GIT_LOCAL} ${GIT_URI}"

```

#### 命令解释

执行该原子功能，需要具有root 用户权限，并能以root权限远程登录到目标机器上。如果因为安全加固，不能以root权限登录， 需要手动创建opuser用户。

### 开放能力接口
PUT /command/cloud
```json

{
  "params": {
     "SSH_HOST": "{{ssh_host}}",
     "LAB_NAME": "{{lab_name}}",
     "GIT_LOCAL": "/largeDisk/xiazw/deploymd/cloudtool",
     "GIT_URI": "http://192.168.0.32:8080/gitlab-instance-b9319445/cloudtool.git""
  },
  "COMMAND": "deploy",
  "workflow": "/logic/mop/deploy/cloneGit.md"
}
```

#### @由数智云图-自动化云平台构建工具支持