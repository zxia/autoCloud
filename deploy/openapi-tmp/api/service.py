from fastapi import FastAPI, Form, File, UploadFile

app = FastAPI()


@app.post("/service")
def deploy_service(service: str, item: ServiceInfo):
    res = lcm.create_service(service, item)
    print(res)
    return {"ser": service, "item": item}


@app.put("/service")
def update_service(service: str, item: ServiceInfo):
    res = lcm.create_service(service, item)
    print(res)
    return {"ser": service, "item": item}


@app.delete("/service")
def update_service(service: str):
    return {"ser": service}


@app.get("/service")
def get_service(service: str):
    return {"ser": service}


@app.post("/login/")
async def login(username: str = Form(), password: str = Form()):
    return {"username": username}


@app.post("/files/")
async def create_file(file: bytes = File()):
    return {"file_size": len(file)}


@app.post("/uploadfile/")
async def create_upload_file(file: UploadFile):
    return {"filename": file.filename}
