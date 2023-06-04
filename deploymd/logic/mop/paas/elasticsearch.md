# 数智云平台-PaaS[ElasticSearch]安装（基于数智中台-云图套件）

## genCA

#### 通过ES工具elasticsearch-certutil生成ca相关证书

```bash
genESCA 8.4.0
```

#### 将证书组装进Kubernetes Secert中

```bash
EXECUTED_PERMISSION="opuser"
setConfig ssh
setConfig harbor
executeExpect SSH "createFold:/home/opuser/elasticsearch"
executeExpect Bash "rsyncFoldExp:${workDir}/output/es /home/opuser/elasticsearch"
EXECUTED_PERMISSION="suroot"
executeExpect SSH "genESCASecrets:/home/opuser/elasticsearch elk-system"
```

## Step.1

#### 通用配置参数

```bash
COMPONENT="elasticsearch-master"
helmPackage=elasticsearch-8.1.0.tgz
NAMESPACE="elk-system"
HOSTS=${HOSTS:=${SSH_HOST}}
```

#### 调度管理

```bash
labelPaasNodes "app" "elasticsearch-master"
```

#### 部署PaaS组件

[通用argocd部署](deploypaas.md)

## Step.2

#### 通用配置参数

```bash
COMPONENT="elasticsearch-data"
helmPackage=elasticsearch-8.1.0.tgz
NAMESPACE="elk-system"

HOSTS=${HOSTS:=${SSH_HOST}}
```

#### 调度管理

```bash
labelPaasNodes "app" "elasticsearch-data"
```

#### 部署PaaS组件

[通用argocd部署](deploypaas.md)

## Step.2

#### 通用配置参数

```bash
COMPONENT="elasticsearch-ingest"
helmPackage=elasticsearch-8.1.0.tgz
NAMESPACE="elk-system"

HOSTS=${HOSTS:=${SSH_HOST}}
```

#### 调度管理

```bash
labelPaasNodes "app" "elasticsearch-ingest"
```

#### 部署PaaS组件

[通用argocd部署](deploypaas.md)

#### 创建kibana账号

```bash
setConfig elasticsearch
EXECUTED_PERMISSION="suroot"
executeExpect SSH "addKibanaUser:elk-system ${ELASTICSEARCH_KIBANA_USER} ${ELASTICSEARCH_KIBANA_PASSWORD}"
unsetConfig elasticsearch
```