import uvicorn

if __name__ == "__main__":
    uvicorn.run("service:app", host="0.0.0.0", port=8002, log_level="info")
