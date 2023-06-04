from pydantic import BaseModel


class ServicePackage(BaseModel):
    name: str
    description: str
    version: str
    app_version: str


class ServiceWorkload(BaseModel):
    workload: str


class ServiceMesh(BaseModel):
    type: str
    gateway: str = "disable"
    destination_rule: str = "enable"
    virtual_service: str = "disable"
    fault_injection: str = "disable"
    service_entry: str = "disable"


class Service(BaseModel):
    service_package: ServicePackage
    service_workload: ServiceWorkload
    k8sService: str = "internal"
    serviceMesh: ServiceMesh
