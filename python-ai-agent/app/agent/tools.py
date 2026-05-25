"""
工具函数
"""
import math
from datetime import datetime
import pytz

async def search_knowledge_base(query: str) -> str:
    from app.agent.knowledge_base import get_knowledge_base
    kb = get_knowledge_base()
    results = kb.search(query, top_k=3)
    return "\n".join(results) if results else f"未找到关于'{query}'的信息"

async def calculate(expression: str) -> str:
    try:
        safe_dict = {"abs": abs, "round": round, "min": min, "max": max,
                     "sum": sum, "pow": pow, "sqrt": math.sqrt, "pi": math.pi}
        result = eval(expression, {"__builtins__": {}}, safe_dict)
        return f"计算结果: {expression} = {result}"
    except Exception as e:
        return f"计算错误: {str(e)}"

async def get_current_time(timezone: str = "Asia/Shanghai") -> str:
    try:
        tz = pytz.timezone(timezone)
        current_time = datetime.now(tz)
        return f"当前时间: {current_time.strftime('%Y-%m-%d %H:%M:%S')}"
    except:
        return f"当前时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"

AVAILABLE_TOOLS = [...]  # 工具定义（与之前相同）
TOOL_MAP = {
    "search_knowledge_base": search_knowledge_base,
    "calculate": calculate,
    "get_current_time": get_current_time,
}

async def execute_tool(tool_name: str, arguments: dict) -> str:
    if tool_name in TOOL_MAP:
        return await TOOL_MAP[tool_name](**arguments)
    return f"未知工具: {tool_name}"