"""
秒杀分析API - 被Java服务调用
"""
from fastapi import APIRouter
from pydantic import BaseModel
from typing import Dict, Any
from datetime import datetime
from app.services.redis_client import redis_client
from app.agent.brain import agent_brain

router = APIRouter(prefix="/api/seckill", tags=["秒杀分析"])

class QuestionRequest(BaseModel):
    question: str
    enable_reflection: bool = True

@router.post("/analyze")
async def analyze_seckill(request: QuestionRequest):
    """AI分析秒杀问题 - Java秒杀服务调用此接口"""
    await redis_client.connect()
    
    # 获取实时数据
    stock1 = await redis_client.get_seckill_stock(1)
    stock2 = await redis_client.get_seckill_stock(2)
    stats = await redis_client.get_seckill_stats()
    
    # 构建上下文
    context = f"""
    当前秒杀实时数据：
    - iPhone15库存: {stock1}
    - 华为Mate60库存: {stock2}
    - 秒杀成功数: {stats['success']}
    - 秒杀失败数: {stats['fail']}
    - 成功率: {(stats['success']/stats['total']*100) if stats['total']>0 else 0:.1f}%
    """
    
    # AI思考
    answer, confidence = agent_brain.think(request.question, context)
    
    # 低置信度时自我反思
    if request.enable_reflection and confidence < 0.7:
        answer = agent_brain.self_reflect(request.question, answer)
        confidence = min(confidence + 0.2, 0.95)
    
    return {
        "code": 200,
        "data": {
            "answer": answer,
            "confidence": confidence,
            "data_snapshot": {
                "stock": {"product_1": stock1, "product_2": stock2},
                "statistics": stats,
                "timestamp": datetime.now().isoformat()
            },
            "reflection_applied": confidence > 0.7 and request.enable_reflection
        }
    }

@router.get("/stats")
async def get_stats():
    """获取统计数据"""
    await redis_client.connect()
    stats = await redis_client.get_seckill_stats()
    stock1 = await redis_client.get_seckill_stock(1)
    stock2 = await redis_client.get_seckill_stock(2)
    return {"code": 200, "data": {"inventory": {"product_1": stock1, "product_2": stock2}, "statistics": stats}}