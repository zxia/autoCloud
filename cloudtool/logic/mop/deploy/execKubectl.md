# 原子功能

## kubernetes--命令行

在目标集群上，执行Kubernetes 命令


### 执行命令

1. 同步任务描述文件

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH "kubectl ${K8S_COMMAND}"
```



#### 开放能力接口
PUT /command/cloud
```json

{
  "params": {
        "LAB_NAME": "{{lab_name}}",
        "K8S_COMMAND": ""
  },
  "COMMAND": "build",
  "workflow": "/cloudtool/logic/mop/deploy/execKubectl.md"
}
```

#### @由数智云图-自动化云平台构建工具支持