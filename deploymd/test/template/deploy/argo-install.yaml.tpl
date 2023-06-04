# This is an auto-generated file. DO NOT EDIT
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: clusterworkflowtemplates.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: ClusterWorkflowTemplate
    listKind: ClusterWorkflowTemplateList
    plural: clusterworkflowtemplates
    shortNames:
    - clusterwftmpl
    - cwft
    singular: clusterworkflowtemplate
  scope: Cluster
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          metadata:
            type: object
          spec:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
        required:
        - metadata
        - spec
        type: object
    served: true
    storage: true
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: cronworkflows.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: CronWorkflow
    listKind: CronWorkflowList
    plural: cronworkflows
    shortNames:
    - cwf
    - cronwf
    singular: cronworkflow
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          metadata:
            type: object
          spec:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
          status:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
        required:
        - metadata
        - spec
        type: object
    served: true
    storage: true
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: workflowartifactgctasks.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: WorkflowArtifactGCTask
    listKind: WorkflowArtifactGCTaskList
    plural: workflowartifactgctasks
    shortNames:
    - wfat
    singular: workflowartifactgctask
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          metadata:
            type: object
          spec:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
          status:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
        required:
        - metadata
        - spec
        type: object
    served: true
    storage: true
    subresources:
      status: {}
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: workfloweventbindings.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: WorkflowEventBinding
    listKind: WorkflowEventBindingList
    plural: workfloweventbindings
    shortNames:
    - wfeb
    singular: workfloweventbinding
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          metadata:
            type: object
          spec:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
        required:
        - metadata
        - spec
        type: object
    served: true
    storage: true
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: workflows.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: Workflow
    listKind: WorkflowList
    plural: workflows
    shortNames:
    - wf
    singular: workflow
  scope: Namespaced
  versions:
  - additionalPrinterColumns:
    - description: Status of the workflow
      jsonPath: .status.phase
      name: Status
      type: string
    - description: When the workflow was started
      format: date-time
      jsonPath: .status.startedAt
      name: Age
      type: date
    - description: Human readable message indicating details about why the workflow
        is in this condition.
      jsonPath: .status.message
      name: Message
      type: string
    name: v1alpha1
    schema:
      openAPIV3Schema:
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          metadata:
            type: object
          spec:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
          status:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
        required:
        - metadata
        - spec
        type: object
    served: true
    storage: true
    subresources: {}
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: workflowtaskresults.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: WorkflowTaskResult
    listKind: WorkflowTaskResultList
    plural: workflowtaskresults
    singular: workflowtaskresult
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          message:
            type: string
          metadata:
            type: object
          outputs:
            properties:
              artifacts:
                items:
                  properties:
                    archive:
                      properties:
                        none:
                          type: object
                        tar:
                          properties:
                            compressionLevel:
                              format: int32
                              type: integer
                          type: object
                        zip:
                          type: object
                      type: object
                    archiveLogs:
                      type: boolean
                    artifactGC:
                      properties:
                        podMetadata:
                          properties:
                            annotations:
                              additionalProperties:
                                type: string
                              type: object
                            labels:
                              additionalProperties:
                                type: string
                              type: object
                          type: object
                        serviceAccountName:
                          type: string
                        strategy:
                          enum:
                          - ""
                          - OnWorkflowCompletion
                          - OnWorkflowDeletion
                          - Never
                          type: string
                      type: object
                    artifactory:
                      properties:
                        passwordSecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        url:
                          type: string
                        usernameSecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                      required:
                      - url
                      type: object
                    azure:
                      properties:
                        accountKeySecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        blob:
                          type: string
                        container:
                          type: string
                        endpoint:
                          type: string
                        useSDKCreds:
                          type: boolean
                      required:
                      - blob
                      - container
                      - endpoint
                      type: object
                    deleted:
                      type: boolean
                    from:
                      type: string
                    fromExpression:
                      type: string
                    gcs:
                      properties:
                        bucket:
                          type: string
                        key:
                          type: string
                        serviceAccountKeySecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                      required:
                      - key
                      type: object
                    git:
                      properties:
                        branch:
                          type: string
                        depth:
                          format: int64
                          type: integer
                        disableSubmodules:
                          type: boolean
                        fetch:
                          items:
                            type: string
                          type: array
                        insecureIgnoreHostKey:
                          type: boolean
                        passwordSecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        repo:
                          type: string
                        revision:
                          type: string
                        singleBranch:
                          type: boolean
                        sshPrivateKeySecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        usernameSecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                      required:
                      - repo
                      type: object
                    globalName:
                      type: string
                    hdfs:
                      properties:
                        addresses:
                          items:
                            type: string
                          type: array
                        force:
                          type: boolean
                        hdfsUser:
                          type: string
                        krbCCacheSecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        krbConfigConfigMap:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        krbKeytabSecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        krbRealm:
                          type: string
                        krbServicePrincipalName:
                          type: string
                        krbUsername:
                          type: string
                        path:
                          type: string
                      required:
                      - path
                      type: object
                    http:
                      properties:
                        auth:
                          properties:
                            basicAuth:
                              properties:
                                passwordSecret:
                                  properties:
                                    key:
                                      type: string
                                    name:
                                      type: string
                                    optional:
                                      type: boolean
                                  required:
                                  - key
                                  type: object
                                usernameSecret:
                                  properties:
                                    key:
                                      type: string
                                    name:
                                      type: string
                                    optional:
                                      type: boolean
                                  required:
                                  - key
                                  type: object
                              type: object
                            clientCert:
                              properties:
                                clientCertSecret:
                                  properties:
                                    key:
                                      type: string
                                    name:
                                      type: string
                                    optional:
                                      type: boolean
                                  required:
                                  - key
                                  type: object
                                clientKeySecret:
                                  properties:
                                    key:
                                      type: string
                                    name:
                                      type: string
                                    optional:
                                      type: boolean
                                  required:
                                  - key
                                  type: object
                              type: object
                            oauth2:
                              properties:
                                clientIDSecret:
                                  properties:
                                    key:
                                      type: string
                                    name:
                                      type: string
                                    optional:
                                      type: boolean
                                  required:
                                  - key
                                  type: object
                                clientSecretSecret:
                                  properties:
                                    key:
                                      type: string
                                    name:
                                      type: string
                                    optional:
                                      type: boolean
                                  required:
                                  - key
                                  type: object
                                endpointParams:
                                  items:
                                    properties:
                                      key:
                                        type: string
                                      value:
                                        type: string
                                    required:
                                    - key
                                    type: object
                                  type: array
                                scopes:
                                  items:
                                    type: string
                                  type: array
                                tokenURLSecret:
                                  properties:
                                    key:
                                      type: string
                                    name:
                                      type: string
                                    optional:
                                      type: boolean
                                  required:
                                  - key
                                  type: object
                              type: object
                          type: object
                        headers:
                          items:
                            properties:
                              name:
                                type: string
                              value:
                                type: string
                            required:
                            - name
                            - value
                            type: object
                          type: array
                        url:
                          type: string
                      required:
                      - url
                      type: object
                    mode:
                      format: int32
                      type: integer
                    name:
                      type: string
                    optional:
                      type: boolean
                    oss:
                      properties:
                        accessKeySecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        bucket:
                          type: string
                        createBucketIfNotPresent:
                          type: boolean
                        endpoint:
                          type: string
                        key:
                          type: string
                        lifecycleRule:
                          properties:
                            markDeletionAfterDays:
                              format: int32
                              type: integer
                            markInfrequentAccessAfterDays:
                              format: int32
                              type: integer
                          type: object
                        secretKeySecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        securityToken:
                          type: string
                      required:
                      - key
                      type: object
                    path:
                      type: string
                    raw:
                      properties:
                        data:
                          type: string
                      required:
                      - data
                      type: object
                    recurseMode:
                      type: boolean
                    s3:
                      properties:
                        accessKeySecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        bucket:
                          type: string
                        createBucketIfNotPresent:
                          properties:
                            objectLocking:
                              type: boolean
                          type: object
                        encryptionOptions:
                          properties:
                            enableEncryption:
                              type: boolean
                            kmsEncryptionContext:
                              type: string
                            kmsKeyId:
                              type: string
                            serverSideCustomerKeySecret:
                              properties:
                                key:
                                  type: string
                                name:
                                  type: string
                                optional:
                                  type: boolean
                              required:
                              - key
                              type: object
                          type: object
                        endpoint:
                          type: string
                        insecure:
                          type: boolean
                        key:
                          type: string
                        region:
                          type: string
                        roleARN:
                          type: string
                        secretKeySecret:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        useSDKCreds:
                          type: boolean
                      type: object
                    subPath:
                      type: string
                  required:
                  - name
                  type: object
                type: array
              exitCode:
                type: string
              parameters:
                items:
                  properties:
                    default:
                      type: string
                    description:
                      type: string
                    enum:
                      items:
                        type: string
                      type: array
                    globalName:
                      type: string
                    name:
                      type: string
                    value:
                      type: string
                    valueFrom:
                      properties:
                        configMapKeyRef:
                          properties:
                            key:
                              type: string
                            name:
                              type: string
                            optional:
                              type: boolean
                          required:
                          - key
                          type: object
                        default:
                          type: string
                        event:
                          type: string
                        expression:
                          type: string
                        jqFilter:
                          type: string
                        jsonPath:
                          type: string
                        parameter:
                          type: string
                        path:
                          type: string
                        supplied:
                          type: object
                      type: object
                  required:
                  - name
                  type: object
                type: array
              result:
                type: string
            type: object
          phase:
            type: string
          progress:
            type: string
        required:
        - metadata
        type: object
    served: true
    storage: true
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: workflowtasksets.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: WorkflowTaskSet
    listKind: WorkflowTaskSetList
    plural: workflowtasksets
    shortNames:
    - wfts
    singular: workflowtaskset
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          metadata:
            type: object
          spec:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
          status:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
        required:
        - metadata
        - spec
        type: object
    served: true
    storage: true
    subresources:
      status: {}
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: workflowtemplates.argoproj.io
spec:
  group: argoproj.io
  names:
    kind: WorkflowTemplate
    listKind: WorkflowTemplateList
    plural: workflowtemplates
    shortNames:
    - wftmpl
    singular: workflowtemplate
  scope: Namespaced
  versions:
  - name: v1alpha1
    schema:
      openAPIV3Schema:
        properties:
          apiVersion:
            type: string
          kind:
            type: string
          metadata:
            type: object
          spec:
            type: object
            x-kubernetes-map-type: atomic
            x-kubernetes-preserve-unknown-fields: true
        required:
        - metadata
        - spec
        type: object
    served: true
    storage: true
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argo
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argo-server
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: github.com
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    workflows.argoproj.io/description: |
      This is the minimum recommended permissions needed if you want to use the agent, e.g. for HTTP or plugin templates.

      If <= v3.2 you must replace `workflowtasksets/status` with `patch workflowtasksets`.
  name: agent
rules:
- apiGroups:
  - argoproj.io
  resources:
  - workflowtasksets
  verbs:
  - list
  - watch
- apiGroups:
  - argoproj.io
  resources:
  - workflowtasksets/status
  verbs:
  - patch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: argo-role
rules:
- apiGroups:
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - create
  - get
  - update
- apiGroups:
  - ""
  resources:
  - pods
  - pods/exec
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - get
  - watch
  - list
- apiGroups:
  - ""
  resources:
  - persistentvolumeclaims
  - persistentvolumeclaims/finalizers
  verbs:
  - create
  - update
  - delete
  - get
- apiGroups:
  - argoproj.io
  resources:
  - workflows
  - workflows/finalizers
  - workflowtasksets
  - workflowtasksets/finalizers
  - workflowartifactgctasks
  verbs:
  - get
  - list
  - watch
  - update
  - patch
  - delete
  - create
- apiGroups:
  - argoproj.io
  resources:
  - workflowtemplates
  - workflowtemplates/finalizers
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - argoproj.io
  resources:
  - workflowtaskresults
  verbs:
  - list
  - watch
  - deletecollection
- apiGroups:
  - ""
  resources:
  - serviceaccounts
  verbs:
  - get
  - list
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
- apiGroups:
  - argoproj.io
  resources:
  - cronworkflows
  - cronworkflows/finalizers
  verbs:
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
  - patch
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - create
  - get
  - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: argo-server-role
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  verbs:
  - get
  - watch
  - list
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - create
- apiGroups:
  - ""
  resources:
  - pods
  - pods/exec
  - pods/log
  verbs:
  - get
  - list
  - watch
  - delete
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - watch
  - create
  - patch
- apiGroups:
  - ""
  resources:
  - serviceaccounts
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - argoproj.io
  resources:
  - eventsources
  - sensors
  - workflows
  - workfloweventbindings
  - workflowtemplates
  - cronworkflows
  - cronworkflows/finalizers
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    workflows.argoproj.io/description: |
      This is the minimum recommended permissions needed if you want to use artifact GC.
  name: artifactgc
rules:
- apiGroups:
  - argoproj.io
  resources:
  - workflowartifactgctasks
  verbs:
  - list
  - watch
- apiGroups:
  - argoproj.io
  resources:
  - workflowartifactgctasks/status
  verbs:
  - patch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    workflows.argoproj.io/description: |
      Recomended minimum permissions for the `emissary` executor.
  name: executor
rules:
- apiGroups:
  - argoproj.io
  resources:
  - workflowtaskresults
  verbs:
  - create
  - patch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    workflows.argoproj.io/description: |
      This is an example of the permissions you would need if you wanted to use a resource template to create and manage
      other pods. The same pattern would be suitable for other resurces, e.g. a service
  name: pod-manager
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - create
  - get
  - patch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: submit-workflow-template
rules:
- apiGroups:
  - argoproj.io
  resources:
  - workfloweventbindings
  verbs:
  - list
- apiGroups:
  - argoproj.io
  resources:
  - workflowtemplates
  verbs:
  - get
- apiGroups:
  - argoproj.io
  resources:
  - workflows
  verbs:
  - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  annotations:
    workflows.argoproj.io/description: |
      This is an example of the permissions you would need if you wanted to use a resource template to create and manage
      other workflows. The same pattern would be suitable for other resurces, e.g. a service
  name: workflow-manager
rules:
- apiGroups:
  - argoproj.io
  resources:
  - workflows
  verbs:
  - create
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argo-clusterworkflowtemplate-role
rules:
- apiGroups:
  - argoproj.io
  resources:
  - clusterworkflowtemplates
  - clusterworkflowtemplates/finalizers
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argo-server-clusterworkflowtemplate-role
rules:
- apiGroups:
  - argoproj.io
  resources:
  - clusterworkflowtemplates
  - clusterworkflowtemplates/finalizers
  verbs:
  - create
  - delete
  - watch
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: agent-default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: agent
subjects:
- kind: ServiceAccount
  name: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: argo-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: argo-role
subjects:
- kind: ServiceAccount
  name: argo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: argo-server-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: argo-server-role
subjects:
- kind: ServiceAccount
  name: argo-server
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: artifactgc-default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: artifactgc
subjects:
- kind: ServiceAccount
  name: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: executor-default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: executor
subjects:
- kind: ServiceAccount
  name: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: github.com
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: submit-workflow-template
subjects:
- kind: ServiceAccount
  name: github.com
  namespace: argo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-manager-default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-manager
subjects:
- kind: ServiceAccount
  name: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: workflow-manager-default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: workflow-manager
subjects:
- kind: ServiceAccount
  name: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argo-clusterworkflowtemplate-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argo-clusterworkflowtemplate-role
subjects:
- kind: ServiceAccount
  name: argo
  namespace: argo
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argo-server-clusterworkflowtemplate-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: argo-server-clusterworkflowtemplate-role
subjects:
- kind: ServiceAccount
  name: argo-server
  namespace: argo
---
apiVersion: v1
data:
  default-v1: |
    archiveLogs: true
    s3:
      bucket: my-bucket
      endpoint: minio:9000
      insecure: true
      accessKeySecret:
        name: my-minio-cred
        key: accesskey
      secretKeySecret:
        name: my-minio-cred
        key: secretkey
  empty: ""
  my-key: |
    archiveLogs: true
    s3:
      bucket: my-bucket
      endpoint: minio:9000
      insecure: true
      accessKeySecret:
        name: my-minio-cred
        key: accesskey
      secretKeySecret:
        name: my-minio-cred
        key: secretkey
kind: ConfigMap
metadata:
  annotations:
    workflows.argoproj.io/default-artifact-repository: default-v1
  name: artifact-repositories
---
apiVersion: v1
data:
  artifactRepository: |
    s3:
      bucket: my-bucket
      endpoint: minio:9000
      insecure: true
      accessKeySecret:
        name: my-minio-cred
        key: accesskey
      secretKeySecret:
        name: my-minio-cred
        key: secretkey
  executor: |
    resources:
      requests:
        cpu: 10m
        memory: 64Mi
  images: |
    docker/whalesay:latest:
       cmd: [cowsay]
  links: |
    - name: Workflow Link
      scope: workflow
      url: http://logging-facility?namespace=${metadata.namespace}&workflowName=${metadata.name}&startedAt=${status.startedAt}&finishedAt=${status.finishedAt}
    - name: Pod Link
      scope: pod
      url: http://logging-facility?namespace=${metadata.namespace}&podName=${metadata.name}&startedAt=${status.startedAt}&finishedAt=${status.finishedAt}
    - name: Pod Logs Link
      scope: pod-logs
      url: http://logging-facility?namespace=${metadata.namespace}&podName=${metadata.name}&startedAt=${status.startedAt}&finishedAt=${status.finishedAt}
    - name: Event Source Logs Link
      scope: event-source-logs
      url: http://logging-facility?namespace=${metadata.namespace}&podName=${metadata.name}&startedAt=${status.startedAt}&finishedAt=${status.finishedAt}
    - name: Sensor Logs Link
      scope: sensor-logs
      url: http://logging-facility?namespace=${metadata.namespace}&podName=${metadata.name}&startedAt=${status.startedAt}&finishedAt=${status.finishedAt}
  metricsConfig: |
    enabled: true
    path: /metrics
    port: 9090
  namespaceParallelism: "10"
  persistence: |
    connectionPool:
      maxIdleConns: 100
      maxOpenConns: 0
      connMaxLifetime: 0s
    nodeStatusOffLoad: true
    archive: true
    archiveTTL: 7d
    postgresql:
      host: postgres
      port: 5432
      database: postgres
      tableName: argo_workflows
      userNameSecret:
        name: argo-postgres-config
        key: username
      passwordSecret:
        name: argo-postgres-config
        key: password
  retentionPolicy: |
    completed: 10
    failed: 3
    errored: 3
kind: ConfigMap
metadata:
  name: workflow-controller-configmap
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    app: postgres
  name: argo-postgres-config
stringData:
  password: password
  username: postgres
type: Opaque
---
apiVersion: v1
kind: Secret
metadata:
  name: argo-server-sso
stringData:
  clientID: argo-server
  clientSecret: ZXhhbXBsZS1hcHAtc2VjcmV0
---
apiVersion: v1
kind: Secret
metadata:
  name: argo-workflows-webhook-clients
stringData:
  bitbucket.org: |
    type: bitbucket
    secret: "my-uuid"
  bitbucketserver: |
    type: bitbucketserver
    secret: "shh!"
  github.com: |
    type: github
    secret: "shh!"
  gitlab.com: |-
    type: gitlab
    secret: "shh!"
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    app: httpbin
  name: my-httpbin-cred
stringData:
  cert.pem: |
    -----BEGIN CERTIFICATE-----
    MIIEmjCCAoICCQDQejieQSZTxzANBgkqhkiG9w0BAQsFADAPMQ0wCwYDVQQDDAR0
    ZXN0MB4XDTIyMDQyNTEzNDc0MloXDTMyMDQyMjEzNDc0MlowDzENMAsGA1UEAwwE
    dGVzdDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMHT/tfskuXizar1
    5DDrSkaT1cuCdQhEO7b6haxfvfMJPY9sxaxR570bw5TWQzA0xdAeUzSCbRsvxw6b
    fEyLD4NajdXtcKocYUUcLclzjgyogTDPqlzAfDVZD25ySOTZ150pQaBuIi6TgnqH
    WdJEh9w5//5VZmKyMx49JZMW7ADb9qYxkKVPIan3aNEXOO4SxyjsSekUFefkZOld
    /RVZ8nO8hnDQ7r5NXsIIWVh35A94CA8y6QpKL2qiEFW1fofRcr/Fe/Y/5ohBQ1Ur
    NMcX87zm9kXX1y6wbp3wn5f1PUa1sCUPlxChmRmPPmr4yIqq0a8C1d71jOIbhkox
    7A30HsP1D3rdxU6eb7KBYb7kShZge1batHRogRe5uX6hGO8iHBV/GdDE6jszoGPU
    ejhfwblr6AeR6ImrWmrJ4rAx/jNqcHPuktnMRlLsBzdhqRwelwgnN13O5ZYiEJg4
    X3YYp678kHnc58aOkhG2nM32cIGha4tkoGM/GpDnFAd0P0gyJVwKo2A2Wc4cMlzQ
    7dokXbkkzK6lrHJnJjiOfzjD5yMB1Q1zQXKGHB2hJSWAMTjJ9f6qQd3ZaarYPTLx
    vc4WTu+547Sx81Vlnes2xTSgt6pyFSBppHpS7KkOxb+wRF2oIpgLA3mQmsq2c60+
    G8/ro91YAYN+cl+v7m1DyEpD9TW/AgMBAAEwDQYJKoZIhvcNAQELBQADggIBACO7
    2hU2BSGU66FwpIOihgcaADH0SwokjrEJVXlnMv26JzG/Ja63gTNE5OyghufsJtUi
    E7E1gOH+dH6lVOIEmQdgGZazGxye20diLlicBATa5W2IuaBzb8Bq7ap75jOB7/sH
    Yh+ZV9w0CWgV7KgzJQsp6KPfpMUXn9aJkRkLlCToCj60tC1agw5wzQcokDhOMJaY
    49FFVoKtVYwN6DfXL5Qi4GUmg7NwMUQAOGD6BQ8VLdbSJoWSHvgR2z5SDIubpdyy
    XDe2V6lusdka8jdRsFH+TUKyGubs3c5YVq80A8itavxPXBUM/OJCHhUA1VpL3rvz
    VgANVV7XFn5fN5TdTOrgJa2LBjflYBC3KiLf1jiW68ZT2rLDrC0yVdHFY0UJG/du
    kWWQpZTfdpGbZOl1rQcYQ3BREWkr5kAv8Sh3sPliibVRvyFzwAqpEUDbpCz/Z3kZ
    mRPU1Ukz8gjr5FBwzNn4x/l+80kgM22qXLMgxf7cqSLxH+dylmIieLGU0s1k7BqK
    Dw77DP1QZe4G6WwrdGooxSYSBn4joKV4TI9sbyd34HJQnkMch0ugz9dlpZyT1P8Y
    3xU8Qj1BIF8yoyRuzbOokd9cEjNC6N+Z4g5lLEKYM/j1f0r3tGEoZAu2p39UGLa8
    aszMnFjeymK5OCkMUhg/KNr4WK58pc/3uFMhy8bn
    -----END CERTIFICATE-----
  clientID: admin
  clientSecret: password
  key.pem: |
    -----BEGIN PRIVATE KEY-----
    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
    NuJLvtwCMGDCxhdYm7OrJ0aUfZzP6w==
    -----END PRIVATE KEY-----
  pass: password
  tokenURL: http://httpbin:9100/response-headers?access_token=faketoken&token_type=Bearer
  user: admin
type: Opaque
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    app: minio
  name: my-minio-cred
stringData:
  accesskey: admin
  secretkey: password
type: Opaque
---
apiVersion: v1
kind: Service
metadata:
  name: argo-server
spec:
  ports:
  - name: web
    port: 2746
    targetPort: 2746
  selector:
    app: argo-server
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: httpbin
  name: httpbin
spec:
  ports:
  - name: api
    port: 9100
    protocol: TCP
    targetPort: 80
  selector:
    app: httpbin
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: minio
  name: minio
spec:
  ports:
  - name: api
    port: 9000
    protocol: TCP
    targetPort: 9000
  - name: dashboard
    port: 9001
    protocol: TCP
    targetPort: 9001
  selector:
    app: minio
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: postgres
  name: postgres
spec:
  ports:
  - port: 5432
    protocol: TCP
    targetPort: 5432
  selector:
    app: postgres
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    workflows.argoproj.io/description: |
      This service is deprecated. It will be removed in v3.4.

      https://github.com/argoproj/argo-workflows/issues/8441
  labels:
    app: workflow-controller
  name: workflow-controller-metrics
spec:
  ports:
  - name: metrics
    port: 9090
    protocol: TCP
    targetPort: 9090
  selector:
    app: workflow-controller
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: workflow-controller
value: 1000000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argo-server
spec:
  selector:
    matchLabels:
      app: argo-server
  template:
    metadata:
      labels:
        app: argo-server
    spec:
      containers:
      - args:
        - server
        - --namespaced
        - --auth-mode
        - server
        - --auth-mode
        - client
        env: []
        image: quay.io/argoproj/argocli:v3.3.9
        name: argo-server
        ports:
        - containerPort: 2746
          name: web
        readinessProbe:
          httpGet:
            path: /
            port: 2746
            scheme: HTTPS
          initialDelaySeconds: 10
          periodSeconds: 20
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
        volumeMounts:
        - mountPath: /tmp
          name: tmp
      nodeSelector:
        kubernetes.io/os: linux
      securityContext:
        runAsNonRoot: true
      serviceAccountName: argo-server
      volumes:
      - emptyDir: {}
        name: tmp
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: httpbin
  name: httpbin
spec:
  selector:
    matchLabels:
      app: httpbin
  template:
    metadata:
      labels:
        app: httpbin
    spec:
      containers:
      - image: docker.io/kennethreitz/httpbin:latest
        livenessProbe:
          httpGet:
            path: /get
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        name: main
        ports:
        - containerPort: 80
          name: api
        readinessProbe:
          httpGet:
            path: /get
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: minio
  name: minio
spec:
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - command:
        - minio
        - server
        - --console-address
        - :9001
        - /data
        env:
        - name: MINIO_ACCESS_KEY
          value: admin
        - name: MINIO_SECRET_KEY
          value: password
        image: docker.io/minio/minio:RELEASE.2022-08-22T23-53-06Z
        lifecycle:
          postStart:
            exec:
              command:
              - mkdir
              - -p
              - /data/my-bucket
        livenessProbe:
          httpGet:
            path: /minio/health/live
            port: 9000
          initialDelaySeconds: 5
          periodSeconds: 10
        name: main
        ports:
        - containerPort: 9000
          name: api
        - containerPort: 9001
          name: dashboard
        readinessProbe:
          httpGet:
            path: /minio/health/ready
            port: 9000
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: postgres
  name: postgres
spec:
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
      name: postgres
    spec:
      containers:
      - env:
        - name: POSTGRES_PASSWORD
          value: password
        image: docker.io/postgres:12-alpine
        name: main
        ports:
        - containerPort: 5432
        readinessProbe:
          exec:
            command:
            - psql
            - -U
            - postgres
            - -c
            - SELECT 1
          initialDelaySeconds: 15
          timeoutSeconds: 2
      nodeSelector:
        kubernetes.io/os: linux
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: workflow-controller
spec:
  selector:
    matchLabels:
      app: workflow-controller
  template:
    metadata:
      labels:
        app: workflow-controller
    spec:
      containers:
      - args:
        - --namespaced
        command:
        - workflow-controller
        env:
        - name: LEADER_ELECTION_IDENTITY
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: metadata.name
        image: quay.io/argoproj/workflow-controller:v3.3.9
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /healthz
            port: 6060
          initialDelaySeconds: 90
          periodSeconds: 60
          timeoutSeconds: 30
        name: workflow-controller
        ports:
        - containerPort: 9090
          name: metrics
        - containerPort: 6060
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: workflow-controller
      securityContext:
        runAsNonRoot: true
      serviceAccountName: argo
