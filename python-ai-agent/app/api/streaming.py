# app/api/streaming.py
"""流式输出API"""
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from openai import OpenAI
from app.config import config
import json
import asyncio

router = APIRouter(prefix="/api/stream", tags=["流式输出"])

class StreamRequest(BaseModel):
    question: str
    context: str = ""

@router.post("/chat")
async def stream_chat(request: StreamRequest):
    """流式返回AI回答"""
    
    async def generate():
        client = OpenAI(
            api_key=config.DASHSCOPE_API_KEY,
            base_url=config.DASHSCOPE_BASE_URL
        )
        
        response = client.chat.completions.create(
            model=config.DEFAULT_MODEL,
            messages=[
                {"role": "system", "content": "你是秒杀系统AI助手，请简洁回答。"},
                {"role": "user", "content": request.question}
            ],
            stream=True  # 开启流式
        )
        
        for chunk in response:
            if chunk.choices[0].delta.content:
                content = chunk.choices[0].delta.content
                # SSE格式
                yield f"data: {json.dumps({'content': content, 'done': False})}\n\n"
            await asyncio.sleep(0.01)
        
        yield f"data: {json.dumps({'done': True})}\n\n"
    
    return StreamingResponse(generate(), media_type="text/event-stream")