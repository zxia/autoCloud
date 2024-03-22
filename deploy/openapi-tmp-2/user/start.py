import uvicorn

if __name__ == "__main__":
    uvicorn.run("user:app", host="0.0.0.0", port=8001, log_level="info")
