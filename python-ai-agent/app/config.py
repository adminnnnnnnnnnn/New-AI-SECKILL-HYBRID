import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # 通义千问API配置
    DASHSCOPE_API_KEY = os.getenv("DASHSCOPE_API_KEY", "your-api-key")
    DASHSCOPE_BASE_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1"
    
    # Redis配置（与Java服务共用）
    REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
    REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
    REDIS_DB = int(os.getenv("REDIS_DB", 0))
    
    # Agent配置
    DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "qwen-plus")
    ENABLE_RAG = os.getenv("ENABLE_RAG", "true").lower() == "true"

config = Config()