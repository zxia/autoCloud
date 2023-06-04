# 原子功能

## 任务管理--调度任务

在目标集群上， 调度任务执行

### 输入参数

* LAB_NAME:  目标机器所属集群名字

### 执行命令

1. 同步任务描述文件

```bash
EXECUTED_PERMISSION="opuser"
cat ${GLOBAL_PARAMS_JSON}  | jq ."TASK_PARAMS" > ${workDir}/workflow/${TASK_NAME}_$$
executeExpect SSH createFold:/home/opuser/workflow
executeExpect Bash "rsyncFoldExp:${workDir}/workflow  /home/opuser/workflow"
```

2. 在目标集群上执行调度

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH scheduleCronTask:"${TASK_NAME} \'${CRON_TIME}\' /home/opuser/workflow/${TASK_NAME}_$$"
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
        "CRON_TIME": "1 2 3 4 5",
        "TASK_PARAMS": {}
  },
  "COMMAND": "deploy",
  "workflow": "/cloudtool/logic/mop/deploy/scheduleTask.md"
}
```

#### @由数智云图-自动化云平台构建工具支持