from fastapi import FastAPI

import logic.cmd as CMD
from schema import Service

app = FastAPI()


@app.post("/create/user")
def create_service(user: str, item: Service):
    # check user if valid
    # create_service
    CMD.create_service(item)
    return {"user": user, "item": item}
