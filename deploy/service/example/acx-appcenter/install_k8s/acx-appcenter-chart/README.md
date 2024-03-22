1. move conf/* to /public/acx/acx-appcenter/conf/ --- share strage
2. replace env properties in bootstrap.yaml and other yaml files
3. install: helm -n k8s-test install acx-appcenter acx-appcenter-chart/ --create-namespace
   uninstall: helm -n k8s-test uninstall acx-appcenter
