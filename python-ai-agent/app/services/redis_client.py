"""
Redis客户端 - 与Java服务共享数据
"""
import redis.asyncio as redis
from app.config import config

class RedisClient:
    _instance = None
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    async def connect(self):
        self.redis = redis.Redis(
            host=config.REDIS_HOST,
            port=config.REDIS_PORT,
            db=config.REDIS_DB,
            decode_responses=True
        )
        return self
    
    async def get_seckill_stock(self, product_id: int) -> int:
        val = await self.redis.get(f"seckill:stock:{product_id}")
        return int(val) if val else 0
    
    async def get_seckill_stats(self) -> dict:
        success = await self.redis.get("seckill:success:count") or 0
        fail = await self.redis.get("seckill:fail:count") or 0
        return {"success": int(success), "fail": int(fail), "total": int(success)+int(fail)}
    
    async def close(self):
        await self.redis.close()

redis_client = RedisClient()