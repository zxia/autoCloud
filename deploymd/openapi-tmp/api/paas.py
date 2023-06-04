from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class Component: (BaseModel)


pass


@app.post("/paas/deploy/{component}")
def deploy_paas(service: str, item: Component):
    res = lcm.create_service(service, item)
    print(res)
    return {"ser": service, "item": item}
