# 自动化功能

## 镜像管理--镜像仓库镜像同步

**前提条件**： 在指定主机上配置源Harbor, 目的Harbor的访问权限已经配置。

**自动化场景**： 

在指定主机上，将内部Harbor中经过测试的镜像，提交到研发云中

### 输入参数

- LAB_NAME: 目标机器所属集群名字
- SSH_HOST:  目标机器IP
- SOURCE_HARBOR:  源Harbor 
- SOURCE_HARBOR_USER:  源Harbor USER 
- SOURCE_HARBOR_PASSWORD: 源Harbor USER
- TARGET_HARBOR: 目的Harbor
- TARGET_HARBOR_USER: 目的Harbor USER
- TARGET_HARBOR_PASSWORD: 目的Harbor USER
- IMAGE_LIST: 镜像列表

### 执行命令

1. 在目标机器上执行操作

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH syncHarborImage:"${TASK_NAME} ${TASK_PARAM}"
```

#### 命令解释

执行该原子功能，需要通过

#### 开放能力接口
PUT /command/cloud
```json
{
    "params": {
        "LAB_NAME": "{{lab_name}}",
        "SSH_HOST": "{{ssh_host}}",
        "SOURCE_HARBOR": 
        "SOURCE_HARBOR_USER":
        "SOURCE_HARBOR_PASSWORD":
        "TARGET_HARBOR": 
        "TARGET_HARBOR_USER":
        "TARGET_HARBOR_PASSWORD":  

        "IAMGE_LIST": {
            
        }
    },
    "COMMAND": "deploy",
    "workflow": "/cloudtool/logic/mop/deploy/commitContainerImage.md"
}
```

#### @由数智云图-自动化云平台构建工具支持
