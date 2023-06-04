# 数智云平台-主机安装分册（基于数智中台-云图套件）

## 主机配置

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH changeHostNameExp 
```

## 工具集安装

```bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "yum install -y jq"
```

#### @由数智云图-自动化云平台构建工具支持