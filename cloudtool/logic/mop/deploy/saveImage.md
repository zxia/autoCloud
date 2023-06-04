# 原子功能

## 镜像管理--下载镜像

在目标机器上， 下载一个外部镜像，并传入内部镜像仓库
目标机器必须有外网链接。


### 执行命令

1. 同步任务描述文件

```bash
EXECUTED_PERMISSION="suroot"
setConfig harbor
executeExpect SSH "saveOneImage:${HARBOR_URI} ${HARBOR_USER} ${HARBOR_PASSWORD} ${IMAGE_URI}"
unsetConfig harbor
```


#### 命令解释

执行该原子功能，需要通过

#### 开放能力接口
PUT /command/cloud
```json

{
  "params": {
        "LAB_NAME": "{{lab_name}}",
        "IMAGE_URI": ""
  },
  "COMMAND": "build",
  "workflow": "/cloudtool/logic/mop/deploy/saveImage.md"
}
```

#### @由数智云图-自动化云平台构建工具支持