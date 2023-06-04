# 原子功能

## 任务管理--调度任务

在目标集群上， 调度任务执行

### 输入参数

* LAB_NAME:  目标机器所属集群名字

### 执行命令

1. 同步任务描述文件

```bash
EXECUTED_PERMISSION="opuser"
executeExpect SSH createFold:/home/opuser/workflow
executeExpect Bash "rsyncFoldExp:${workDir}/workflow  /home/opuser/workflow"
```

2. 在目标集群上执行调度

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH scheduleTask:"${TASK_NAME} ${TASK_PARAM}"
```

#### 命令解释

执行该原子功能，需要通过

#### 开放能力接口
PUT /command/cloud
```json

{
  "params": {
        "LAB_NAME": "{{lab_name}}",
        "TASK_NAME": "cron_test",
        "TASK_PARAM": "1 2 3 4 5"
  },
  "COMMAND": "deploy",
  "workflow": "/cloudtool/logic/mop/deploy/scheduleTask.md"
}
```

#### @由数智云图-自动化云平台构建工具支持