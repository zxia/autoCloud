# 原子功能

## 任务管理--自动复制远端文件

### 执行命令

1. 同步任务描述文件

```bash
EXECUTED_PERMISSION="suroot"
executeExpect Bash "rsyncFileExp:${GLOBAL_PARAMS_JSON} /home/opuser/"
fileName=$(basename ${GLOBAL_PARAMS_JSON})
executeExpect SSH "buildImage:/home/opuser/${fileName}"
```

#### 命令解释

执行该原子功能，需要通过

#### 开放能力接口

PUT /command/cloud

```json

{
  "params": {
    "SSH_HOST": "{{ssh_host}}",
    "LAB_NAME": "{{lab_name}}",
    "USER": "root",
    "PASSWORD": "sugon@2023###",
    "REMOTE_PATH": "10.0.35.112:/opt/acx/acx-market/bin/acx-market.jar",
    "LOCAL_PATH": "/home/opuser/docker/acx-market/"
  },
  "COMMAND": "deploy",
  "workflow": "cloudtool/logic/mop/deploy/scpFile.md"
}
```

#### @由数智云图-自动化云平台构建工具支持