# 原子功能

## 资源网关管理--patch 

在资源网关服务上，应用patch

### 输入参数

* LAB_NAME:  目标机器所属集群名字

### 执行命令

1. 备份

```bash
cp -r ${workDir}/logic  ${workDir}/backup
cp -r ${workDir}/openapi  ${workDir}/backup
cp -r ${workDir}/lab ${workDir}/backup
```

2. 在资源网关上进行patch

```bash
cp -r ${workDir}/resource_gw_manager/custom/  ${workDir}
mkdir -p ${workDir}/deploy || return 0
rsync -ar ${workDir}/resource_gw_manager/patch/   ${workDir}/deploy

```

#### 命令解释


#### 开放能力接口
PUT /command/cloud

```json

{
  "params": {
        "LAB_NAME": "{{lab_name}}"
  },
  "COMMAND": "deploy",
  "workflow": "/cloudtool/logic/mop/deploy/patchResourceGateway.md"
}
```

#### @由数智云图-自动化云平台构建工具支持