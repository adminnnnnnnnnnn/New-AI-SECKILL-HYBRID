# app/agent/observability.py
"""
可观测性 - LangFuse追踪
"""
from langfuse import Langfuse
from app.config import config

# 初始化LangFuse
langfuse = Langfuse(
    secret_key=config.LANGFUSE_SECRET_KEY,
    public_key=config.LANGFUSE_PUBLIC_KEY,
    host=config.LANGFUSE_HOST  # 自建或使用云端
)

def trace_agent_call(trace_name: str):
    """装饰器：追踪Agent调用"""
    def decorator(func):
        
        async def wrapper(*args, **kwargs):
            trace = langfuse.trace(name=trace_name)
            
            # 记录输入
            span = trace.span(name=f"{trace_name}_execution")
            span.update(input=kwargs)
            
            try:
                result = await func(*args, **kwargs)
                span.update(output=result)
                trace.update(output=result)
                return result
            except Exception as e:
                trace.update(level="ERROR", status_message=str(e))
                raise
            finally:
                span.end()
                langfuse.flush()
        
        return wrapper
    return decorator


# 使用示例
@trace_agent_call("agent_think")
async def agent_think(question: str, context: str):
    # AI思考逻辑...
    pass


# 高级：LangSmith替代方案（如果不想用LangFuse）
# pip install langsmith
# from langsmith import traceable
# @traceable(run_type="chain")