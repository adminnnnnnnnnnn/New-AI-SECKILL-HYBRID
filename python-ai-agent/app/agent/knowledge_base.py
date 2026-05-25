"""
知识库管理 - RAG检索
"""
import json
import os
from typing import List
from difflib import get_close_matches


class KnowledgeBase:
    def __init__(self, data_path: str = None):
        if data_path is None:
            data_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "data", "knowledge.json")
        self.data_path = data_path
        self.knowledge = self._load_knowledge()
    
    def _load_knowledge(self):
        default = {
            "seckill_intro": {
                "keywords": ["秒杀", "秒杀系统", "高并发"],
                "content": "秒杀系统是高并发场景下的典型应用，核心策略包括：Redis预减库存、消息队列削峰、限流防刷、异步下单。"
            },
            "redis_stock": {
                "keywords": ["库存", "Redis", "预减"],
                "content": "Redis预减库存：秒杀前将库存加载到Redis，使用DECR原子操作扣减，避免数据库压力。"
            }
        }
        if os.path.exists(self.data_path):
            with open(self.data_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        os.makedirs(os.path.dirname(self.data_path), exist_ok=True)
        with open(self.data_path, 'w', encoding='utf-8') as f:
            json.dump(default, f, ensure_ascii=False, indent=2)
        return default
    
    def search(self, query: str, top_k: int = 3) -> List[str]:
        query_lower = query.lower()
        matched = []
        for key, item in self.knowledge.items():
            relevance = sum(1 for kw in item.get("keywords", []) if kw in query_lower)
            if relevance > 0:
                matched.append({"relevance": relevance, "content": item.get("content", "")})
        matched.sort(key=lambda x: x["relevance"], reverse=True)
        return [m["content"] for m in matched[:top_k]]


_default_kb = None
def get_knowledge_base():
    global _default_kb
    if _default_kb is None:
        _default_kb = KnowledgeBase()
    return _default_kb