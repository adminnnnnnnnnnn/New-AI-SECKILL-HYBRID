"""
AI智能体大脑 - 支持RAG检索、工具调用、自我反思
"""
import json
from typing import Tuple, List, Dict, Any
from openai import OpenAI
from app.config import config
from app.agent.knowledge_base import get_knowledge_base
from app.agent.tools import execute_tool, AVAILABLE_TOOLS


class AgentBrain:
    """增强版AI智能体大脑"""
    
    def __init__(self):
        self.client = OpenAI(
            api_key=config.DASHSCOPE_API_KEY,
            base_url=config.DASHSCOPE_BASE_URL
        )
        self.model = config.DEFAULT_MODEL
        self.enable_rag = config.ENABLE_RAG
        self.knowledge_base = get_knowledge_base() if self.enable_rag else None
    
    def _retrieve_context(self, query: str) -> str:
        """RAG检索"""
        if not self.enable_rag or not self.knowledge_base:
            return ""
        try:
            results = self.knowledge_base.search(query, top_k=3)
            if results:
                return "\n\n【参考知识】\n" + "\n---\n".join(results)
        except Exception as e:
            print(f"RAG检索失败: {e}")
        return ""
    
    def think(self, prompt: str, context_data: str = "") -> Tuple[str, float]:
        """
        核心思考函数
        返回 (回答内容, 置信度)
        """
        # 1. RAG检索
        rag_context = self._retrieve_context(prompt)
        
        # 2. 构建系统提示词
        system_prompt = f"""你是一个专业的秒杀系统AI助手。你必须严格按照JSON格式回答：
{{"answer": "你的详细回答", "confidence": 0.0-1.0}}

【置信度规则】
- 0.9-1.0：基于实时数据的确切回答
- 0.7-0.9：基于常见经验的回答
- 0.5-0.7：有一定依据但不完全确定
- 0.0-0.5：推测性回答或不确定

【实时数据】
{context_data if context_data else "（无实时数据）"}

{rag_context}

【核心原则】
- 宁可说"不确定"，也不要编造信息
- 对于无法确认的内容，confidence设为0.3以下
"""
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ]
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                temperature=0.2,
                response_format={"type": "json_object"}
            )
            result = json.loads(response.choices[0].message.content)
            return result.get("answer", ""), result.get("confidence", 0.5)
        except Exception as e:
            return f"AI思考出错: {str(e)}", 0.0
    
    def self_reflect(self, original_prompt: str, original_answer: str) -> str:
        """自我反思修正"""
        prompt = f"""
【原始问题】{original_prompt}
【我的回答】{original_answer}

请检查回答是否存在：
1. 编造不存在的信息
2. 逻辑矛盾
3. 与已知事实不符

如果正确回复"正确"，否则给出修正版本。
"""
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.1
            )
            reflection = response.choices[0].message.content
            if "正确" in reflection:
                return original_answer
            return f"{reflection}\n\n*（经过AI自我反思修正）*"
        except:
            return original_answer


# 全局实例
agent_brain = AgentBrain()