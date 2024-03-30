# 云图

## bug 
###1. 依赖rsync
   新OS必须要用rsync命令,

###2. setupK8s  OK 
   执行失败后，不退出
###3. 日志显示   ok 
   日志显示不友好，

###4. repo image 需要重新生成    ok 

###5. helm 安装失败

###6. topolvm 支持 已经配置的vgs     ok

###7. setArgoCD,  需要透传SSH_HOST   
###8. argocd 
argocd repo add http://10.0.162.247:8090/gitlab-instance-befc5088/dev37-pass.git --username root --password Ctsi5G@2021 --insecure-skip-server-verification
配置文件加上：需要加上.git

###9. install istioDashboard 
     need the unzip
###10. 在 openapi的Debug mode 下，  service/output  指向的是deploymd/service/output , 但是生成的在service/output下。

###11， getReadyHost,  should firstly use the opuser ,then use the root .     ok
       need to consider  case: ready K8s Host , ready Host,  not Ready Host conditions 
###12. 构建rpm时，需要配置正常的代理和Domain name   pok
###13. 获取容器云拓扑，需要考虑新装系统和已经安装系统的情况
###14. get k8s info时，如果controlPannel 未可达，会报错
###15.  getstate 花费太多时间
###16. argocd 不能自动退出
###17， 需要手动创建argocd repo .
###18. 安装host 失败， 再次安装跳过。
###19. 安装K8s 失败，再次安装跳过
