from pydantic import BaseModel


class Disk(BaseModel):
    erased = "true"
    disk = "/dev/vdb"
    vg = "vg01"


class Docker(BaseModel):
    path = "/largeDisk"
    volume = "60Gi"
    lv = "lv01"
    pause = "3.8"


class Containerd(BaseModel):
    path = "/largeDisk"
    volume = "60Gi"
    lv = "lv01"
    pause = "3.8"


class Volume(BaseModel):
    path: str
    size: str
    type: str


class Container(BaseModel):
    type: str
    path: str


class GitInfo(BaseModel):
    user: str
    password: str
    uri: str
    local: str


class RPMRepo(BaseModel):
    host: str
    path: str
    version: str


class SSHInfo(BaseModel):
    user = "opuser"
    user_password: str
    root_password: str


class NodeInfo(BaseModel):
    name: str
    type: str
    zone: str
    private_ip: str


class Node(BaseModel):
    info: NodeInfo
    disk: Disk
    docker: Docker | None = None
    containerd: Containerd | None = None


class GitLab(BaseModel):
    token: str
    url: str
    groupid = "1"


class Harbor(BaseModel):
    name: str
    ip: str
    uri: str
    user: str
    password: str
    library = "library"
    crt_root = "/etc/docker/certs.d/"

class GitlabBase(BaseModel):
    gitlab_ip: str
    gitlab_port: str
    gitlab_webport: str
    gitlab_ssh_port: str

class ClusterInfo(BaseModel):
    nodes: list[Node]
    harbor: Harbor
    repo: RPMRepo
    gitops: GitInfo
    ssh: SSHInfo
    gitlab: GitLab | None = None
    gitlabBase: GitlabBase | None = None


