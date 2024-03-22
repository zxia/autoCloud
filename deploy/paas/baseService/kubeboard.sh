function setupKubeboard(){
   kubectl apply -f ${cnfRoot}/k8s/hosts/kube-dashboard/kube-dashboard.yaml
   kubectl apply -f ${cnfRoot}/k8s/hosts/kube-dashboard/kube-admin.yaml
}
function removeKubeboard(){
   kubectl delete -f ${cnfRoot}/k8s/hosts/kube-dashboard/kube-dashboard.yaml
   kubectl delete -f ${cnfRoot}/k8s/hosts/kube-dashboard/kube-admin.yaml
}

