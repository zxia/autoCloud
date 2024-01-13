# 原子功能

## 用户管理--创建用户

在目标机器上，创建指定的用户，或者更改用户密码。

### 输入参数

* SSH_HOST :  指定的目标机器， 缺省为集群主结点

* SSH_USER:  指定创建的用户名， 缺省为opuser

* SSH_USER_PASSWORD: 用户的密码, 缺省为配置的opuser的密码

* LAB_NAME:  目标机器所属集群名字

### 执行命令

```bash
EXECUTED_PERMISSION="root"
executeExpect SSH "createUser:${SSH_USER}"
executeExpect SSH "changeUserPasswordExp:${SSH_USER} ${SSH_USER_PASSWORD}"
```

#### 命令解释

执行该原子功能，需要具有root 用户权限，并能以root权限远程登录到目标机器上。如果因为安全加固，不能以root权限登录， 需要手动创建opuser用户。

#### 开放能力接口

```json
{
  "params": {
     "SSH_HOST": "{{ssh_host}}",
     "LAB_NAME": "{{lab_name}}"
  },
  "COMMAND": "deploy",
  "workflow": "/logic/mop/deploy/createUser.md"
}
```

#### @由数智云图-自动化云平台构建工具支持