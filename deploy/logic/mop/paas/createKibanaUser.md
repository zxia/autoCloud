# 数智云平台-创建Kibana user

## 通用配置参数

```bash
setConfig elasticsearch
EXECUTED_PERMISSION="suroot"
executeExpect SSH "addKibanaUser:elk-system ${ELASTICSEARCH_KIBANA_USER} ${ELASTICSEARCH_KIBANA_PASSWORD}"
unsetConfig elasticsearch
```

## 利用通用部署模板进行部署

[通用部署模板](deployYamlService.md)

#### @由数智云图-自动化云平台构建工具支持