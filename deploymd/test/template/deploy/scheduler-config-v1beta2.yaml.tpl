apiVersion: kubescheduler.config.k8s.io/v1beta2
kind: KubeSchedulerConfiguration
leaderElection:
  leaderElect: true
clientConnection:
  kubeconfig: /etc/kubernetes/scheduler.conf
extenders:
  - urlPrefix: "http://127.0.0.1:9251"
    filterVerb: "predicate"
    prioritizeVerb: "prioritize"
    nodeCacheCapable: false
    weight: 1
    managedResources:
      - name: "topolvm.cybozu.com/capacity"
        ignoredByScheduler: true