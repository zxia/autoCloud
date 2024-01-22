# 数智云平台-PaaS安装（基于数智中台-云图套件）

## 通用配置参数

```bash
HOSTS=${HOSTS:=${SSH_HOST}}
````

## 安装istio base

### 配置参数

```bash
COMPONENT="istio-base"
helmPackage=base-1.14.3.tgz
NAMESPACE="istio-system"
```

### 部署组件

[通用argocd部署](deploypaas.md)

## 安装istiod

### 配置参数

```bash
COMPONENT="istio-istiod"
helmPackage=istiod-1.14.3.tgz
NAMESPACE="istio-system"
```

### 部署组件

[通用argocd部署](deploypaas.md)

## 安装istio ingress gateway

### 配置参数

```bash
COMPONENT="istio-ingress"
helmPackage=istio-ingress-1.0.0.tgz
NAMESPACE="istio-system"
```

### 部署组件

[通用argocd部署](deploypaas.md)

### 设置 istio-injection

````bash
sleep 60
executeExpect SSH "kubectl label namespace default istio-injection=enabled --overwrite" 
executeExpect SSH "setupIstioDashboard"
````

#### @由数智云图-自动化云平台构建工具支持