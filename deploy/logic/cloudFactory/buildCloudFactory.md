# 数智容器化-创建云图镜像

## 配置数据

````bash

# default HOST 
HOSTS=${SSH_HOST}
VERSION=$(cat ${workDir}/version/base.ini | grep middleplatform | awk '{print $2}')
COMPONENT=CloudFactory
````

### 调用通用镜像构建工具

[构建镜像](../mop/build/buildImages.md)

#### @由数智云图-自动化云平台构建工具支持