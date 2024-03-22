from pydantic import BaseModel


class SaveRpm(BaseModel):
    command = "build"
    md_file = "logic/mop/build/getRpmPackage.md"
    lab_name: str
    host_ip: str
