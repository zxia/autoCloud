from pydantic import BaseModel


class taskInfo(BaseModel):
    task_id: str | None = None


class PodInfo(BaseModel):
    replica: int = 1


class ImageResource(BaseModel):
    req_mem: str
    req_cpu: str
    limit_mem: str
    limit_cpu: str


class ImageInfo(BaseModel):
    image: str
    repos: str


class ServiceInfo(BaseModel):
    image_info: ImageInfo
    node_info: NodeInfo
    pod_info: PodInfo
    resource_info: ImageResource | None = None
