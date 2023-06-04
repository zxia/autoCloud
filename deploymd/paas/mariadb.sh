function genMariadbValue(){
  local userValue=$1/userValues.yaml
  local dockerRegistry=${HARBOR_URI}/${HARBOR_LIBRARY}
  local volume["mariadb"]=${MARIADB_VOLUME}
  local paasword=${MARIANACOS_DB_PASSWORD}
    cat << EOF > ${userValue}

global:
  imageRegistry: ${dockerRegistry}
  storageClass: topolvm-provisioner
architecture: replication
auth:
  rootPassword: ${paasword}
primary:
  persistence:
    ## If true, use a Persistent Volume Claim, If false, use emptyDir
    ##
    enabled: true
    size: ${volume["mariadb"]}
  nodeAffinityPreset:
    type: "hard"
    key: "mariadb"
    values:
      - "mariadb"
secondary:
  persistence:
    ## If true, use a Persistent Volume Claim, If false, use emptyDir
    ##
    enabled: true
    size: ${volume["mariadb"]}
  nodeAffinityPreset:
    type: "hard"
    key: "mariadb"
    values:
      - "mariadb"
metrics:
  enabled: true

EOF
}

function executeMariadbClient(){
  local msg="$1"
  kubectl get namespaces | grep auto-operate
  [ $? -eq 0 ]  || kubectl create namespace auto-operate

  kubectl get pods -n auto-operate | grep mariadb
  if [ $? -ne 0 ] ; then
   kubectl run mariadb-client --rm --tty -i --restart='Never' --image  ${dockerRegistry}/mariadb:10.5.10-debian-10-r0 --namespace  auto-operate --command -- ${msg}
  else
    kubectl exec -it  mariadb-client --namespace auto-operate  -- ${msg}
  fi
}

function startSQL(){
   echo "mysql -h mariadb.default.svc.cluster.local -uroot -p my_database"
   echo "execute SQL command as below ..... "
   echo "use opensips;"
   echo "delete from load_balancer;"
   echo "delete from dispatcher;"
   cat ${cnfRoot}/ct-scripts/ld.sql
   echo "redeploy opensips to take effective: "
   echo "helm uninstall opensips; setupK8s -b deployOpensips"
   passwd=$(kubectl get secret --namespace default mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)
   echo $passwd
   #kubectl exec -it mariadb-client --  mysql -h mariadb.default.svc.cluster.local -uroot -p${passwd}
   kubectl run mariadb-client --rm --tty -i --restart='Never' --image  ${dockerRegistry}/mariadb:10.5.10-debian-10-r0 --namespace default --command -- bash
}

function getMariadbPassword(){
  local password=$(kubectl get secret --namespace mariadb-system mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)
  echo "mariadbPassword   ${password}   end"
}