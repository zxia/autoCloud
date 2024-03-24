# 原子功能

## 部署容器

在目标机器上，部署容器

### 执行命令

1. 同步任务描述文件

```bash
EXECUTED_PERMISSION="opuser"
genServerlessData  
executeExpect SSH createFold:/home/opuser/service/${TASK_NAME}

executeExpect Bash "rsyncFoldExp:${workDir}/output/service/${TASK_NAME}  /home/opuser/service/${TASK_NAME} "
```

2. 在目标集群上执行调度

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH scheduleDocker:"${TASK_NAME}  /home/opuser/service/${TASK_NAME}/task_params_$$"
```

#### 命令解释

执行该原子功能，需要通过

#### 开放能力接口

PUT /command/cloud

```json
{
  "params": {
    "LAB_NAME": "{{lab_name}}",
    "TASK_NAME": "hello-jackey-1",
    "TASK_PARAM": {
      "image": "gmct.storage.com/library/knative-samples/helloworld-go",
      "port": 8080,
      "env": {
        "TARGET": "how are you",
        "NAME": "Jackey"
      }
    }
  },
  "COMMAND": "deploy",
  "workflow": "/cloudtool/logic/mop/deploy/execKn.md"
}
```

#### @由数智云图-自动化云平台构建工具支持