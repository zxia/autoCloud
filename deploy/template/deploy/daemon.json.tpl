{
 "exec-opts": ["native.cgroupdriver=systemd"],
 "log-driver": "json-file",
 "log-opts": {
 "max-size": "50m",
 "max-file": "20"},
 "data-root": "HARBORBASE_DATA_VOLUME",
 "storage-driver": "overlay2",
  "insecure-registries": [
 "HARBORBASE_HOST_NAME"
  ]

}
