# app/agent/semantic_cache.py
"""
语义缓存 - 减少API调用，降低成本
"""
import hashlib
from typing import Optional, Tuple
from app.services.redis_client import redis_client
from app.agent.vector_store import get_vector_store


class SemanticCache:
    """
    语义缓存：相似问题直接返回缓存答案
    """
    
    def __init__(self, similarity_threshold: float = 0.85):
        self.threshold = similarity_threshold
        self.vector_store = get_vector_store()
    
    async def get(self, query: str) -> Optional[str]:
        """获取缓存答案"""
        # 先查精确缓存（MD5）
        cache_key = f"cache:exact:{hashlib.md5(query.encode()).hexdigest()}"
        exact = await redis_client.redis.get(cache_key)
        if exact:
            return exact
        
        # 语义相似度检索
        similar = self.vector_store.search(query, top_k=1)
        if similar and similar[0]['score'] >= self.threshold:
            return similar[0]['content']
        
        return None
    
    async def set(self, query: str, answer: str):
        """设置缓存"""
        # 精确缓存（TTL 1小时）
        exact_key = f"cache:exact:{hashlib.md5(query.encode()).hexdigest()}"
        await redis_client.redis.setex(exact_key, 3600, answer)
        
        # 语义缓存（存储embedding）
        self.vector_store.add_documents(
            documents=[answer],
            metadatas=[{"query": query, "source": "cache"}]
        )


semantic_cache = SemanticCache()


# 使用示例（在brain.py中添加）
async def think_with_cache(self, prompt: str) -> Tuple[str, float]:
    # 1. 查缓存
    cached = await semantic_cache.get(prompt)
    if cached:
        return cached, 0.95
    
    # 2. 调用模型
    answer, confidence = self.think(prompt)
    
    # 3. 存入缓存（高置信度答案才缓存）
    if confidence > 0.8:
        await semantic_cache.set(prompt, answer)
    
    return answer, confidence