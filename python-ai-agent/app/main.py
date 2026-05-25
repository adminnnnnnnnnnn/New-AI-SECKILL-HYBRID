from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.api import seckill
from app.services.redis_client import redis_client

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Python AI Agent 启动中...")
    await redis_client.connect()
    print("✅ Redis连接成功")
    yield
    await redis_client.close()
    print("👋 服务关闭")

app = FastAPI(title="Seckill AI Agent", version="2.0.0", lifespan=lifespan)

app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True,
                   allow_methods=["*"], allow_headers=["*"])

app.include_router(seckill.router)

@app.get("/health")
async def health():
    return {"status": "healthy", "service": "python-ai-agent"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)