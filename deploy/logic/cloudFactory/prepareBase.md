# 数智容器化云平台构建
---

## 配置数据

````bash
# default HOST 
HOSTS=${SSH_HOST}
````

## 主机准备

1.   ### [创建用户](../mop/deploy/createUser.md)
1.   ### [安装准备](../mop/deploy/configRepo.md)
1.   ### 安装主机组件

````bash
EXECUTED_PERMISSION="suroot"
executeExpect SSH  "yum install jq -y"
````

## gitops 准备（手动步骤）

1.  ### 在gitserver上创建项目
1.  ### 创建项目后，配置gitops.ini

比如

* GITOPS_URI=http://192.168.0.32:8080/gitlab-instance-b9319445/dev100.git
* GITOPS_LOCAL=/dev100

## argocd 准备（手动步骤）

登录到argocd server上， 添加repositories,
Manage your repositories->Repositories->Connect REPO using HTTPS->
输入：

* Project: default
* Repository URL: (比如)
  [your repository url]

#### @由数智云图-自动化云平台构建工具支持