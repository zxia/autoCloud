function genDnsValues(){
cat << EOF > ${workDir}/output/dns/dns-install.yaml
apiVersion: v1
kind: Pod
metadata:
  name: dnsutils
spec:
  containers:
  - name: dnsutils
    image: ${HARBOR_URI}/${HARBOR_LIBRARY}/e2e-test-images/jessie-dnsutils:1.3
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOF
}

