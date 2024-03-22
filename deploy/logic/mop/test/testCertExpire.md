# 测试集群证书刷新
  [流程参见](..https://v1-24.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/)


## 用户管理

- 创建管理用户

````bash
EXECUTED_PERMISSION="root"
executeExpect SSH "kubeadm certs check-expiration"
executeExpect SSH "changeUserPasswordExp:${SSH_USER} ${SSH_USER_PASSWORD}"
````

#### @由数智云图-自动化云平台构建工具支持