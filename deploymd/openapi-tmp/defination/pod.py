from pydantic import BaseModel


class NodeInfo(BaseModel):
    node: list | None = None


class PodInfo(BaseModel):
    replica: int = 1


class ServiceResource(BaseModel):
    req_mem: str
    req_cpu: str
    limit_mem: str
    limit_cpu: str


class ServiceInfo(BaseModel):
    image_info: ImageInfo
    node_info: NodeInfo
    pod_info: PodInfo
    resource_info: ServiceResource | None = None
