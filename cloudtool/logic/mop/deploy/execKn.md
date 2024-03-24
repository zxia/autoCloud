# 原子功能

## 无服务--调度

在目标集群上， 调度任务执行

### 输入参数

* LAB_NAME:  目标机器所属集群名字

### 执行命令

1. 同步任务描述文件

```bash
EXECUTED_PERMISSION="opuser"
genServerlessData  
executeExpect SSH createFold:/home/opuser/service/${TASK_NAME}
executeExpect Bash "rsyncFoldExp:${workDir}/output/service  /home/opuser/service"
```

2. 在目标集群上执行调度

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH scheduleServerless:"${TASK_NAME}  /home/opuser/service/${TASK_NAME}/task_params_$$"
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
      "env":{
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