# app/agent/vector_store.py
"""真实向量检索 - 使用ChromaDB + Embedding"""
import os
import chromadb
from chromadb.utils import embedding_functions
from typing import List, Dict, Any
from app.config import config

class VectorStore:
    """基于ChromaDB的向量知识库"""
    
    def __init__(self, collection_name: str = "seckill_knowledge"):
        # 持久化目录
        self.client = chromadb.PersistentClient(
            path=os.path.join(os.path.dirname(__file__), "../../data/chroma")
        )
        
        # 使用通义千问的Embedding模型
        self.embedding_fn = embedding_functions.OpenAIEmbeddingFunction(
            api_key=config.DASHSCOPE_API_KEY,
            model_name="text-embedding-v3",
            api_base=config.DASHSCOPE_BASE_URL
        )
        
        # 获取或创建集合
        self.collection = self.client.get_or_create_collection(
            name=collection_name,
            embedding_function=self.embedding_fn,
            metadata={"hnsw:space": "cosine"}
        )
    
    def add_documents(self, documents: List[str], metadatas: List[Dict] = None, ids: List[str] = None):
        """添加文档到向量库"""
        if ids is None:
            ids = [f"doc_{i}" for i in range(len(documents))]
        
        self.collection.add(
            documents=documents,
            metadatas=metadatas or [{}] * len(documents),
            ids=ids
        )
        print(f"✅ 添加 {len(documents)} 条知识到向量库")
    
    def search(self, query: str, top_k: int = 3) -> List[Dict]:
        """语义检索"""
        results = self.collection.query(
            query_texts=[query],
            n_results=top_k
        )
        
        docs = []
        if results['documents'] and results['documents'][0]:
            for i, doc in enumerate(results['documents'][0]):
                docs.append({
                    "content": doc,
                    "score": 1 - results['distances'][0][i] if results['distances'] else 1.0,
                    "metadata": results['metadatas'][0][i] if results['metadatas'] else {}
                })
        return docs
    
    def delete_collection(self):
        self.client.delete_collection(self.collection.name)


# 初始化时导入秒杀系统的文档
def init_seckill_vector_store():
    """初始化秒杀知识库"""
    vs = VectorStore()
    
    # 秒杀系统的核心知识文档
    documents = [
        """秒杀系统架构：采用Spring Cloud微服务架构，包含网关、用户服务、商品服务、订单服务、秒杀服务。使用Nacos作为服务注册中心，Redis缓存库存，RocketMQ异步削峰。""",
        
        """防超卖三层保障：第一层，Redis Lua脚本原子扣减库存；第二层，数据库乐观锁（通过version字段）兜底；第三层，本地消息表保证最终一致性。""",
        
        """订单超时处理：用户下单后30分钟未支付，使用RocketMQ延迟消息自动取消订单，并恢复库存。""",
        
        """限流熔断策略：使用Sentinel配置QPS限流（单机2000 QPS），以及慢调用熔断（RT > 500ms触发）。""",
        
        """热点商品处理：采用多级缓存（Caffeine本地缓存 + Redis分布式缓存），使用一致性哈希进行负载均衡。""",
    ]
    
    ids = [f"seckill_doc_{i}" for i in range(len(documents))]
    vs.add_documents(documents, ids=ids)
    return vs


# 全局实例
_vector_store = None

def get_vector_store():
    global _vector_store
    if _vector_store is None:
        _vector_store = VectorStore()
    return _vector_store