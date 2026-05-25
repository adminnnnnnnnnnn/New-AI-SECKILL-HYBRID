# app/agent/react_agent.py
"""
ReAct Agent - 真正的思考+行动循环
"""
import json
from typing import Dict, Any, List, Tuple
from openai import OpenAI
from app.config import config
from app.agent.tools import AVAILABLE_TOOLS, execute_tool


class ReActAgent:
    """
    ReAct模式Agent：思考 -> 行动 -> 观察 -> 思考 -> ... -> 最终答案
    """
    
    def __init__(self, max_iterations: int = 5):
        self.client = OpenAI(
            api_key=config.DASHSCOPE_API_KEY,
            base_url=config.DASHSCOPE_BASE_URL
        )
        self.model = config.DEFAULT_MODEL
        self.max_iterations = max_iterations
    
    def run(self, question: str, context: str = "") -> Tuple[str, List[Dict]]:
        """
        执行ReAct循环
        返回 (最终答案, 完整轨迹)
        """
        # 系统提示词
        system_prompt = f"""你是一个可以调用工具的AI助手。请使用ReAct格式回答：
        
思考: 分析当前状态，决定下一步行动
行动: 选择要调用的工具，格式：工具名(参数)
观察: 记录工具返回结果

可用工具：
{json.dumps(AVAILABLE_TOOLS, ensure_ascii=False, indent=2)}

【实时数据】
{context}

当收集到足够信息后，输出FINISH并给出最终答案。
"""
        
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": question}
        ]
        
        trajectory = []
        iteration = 0
        
        while iteration < self.max_iterations:
            # 调用LLM
            response = self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                temperature=0.3
            )
            
            thought = response.choices[0].message.content
            messages.append({"role": "assistant", "content": thought})
            trajectory.append({"iteration": iteration + 1, "thought": thought})
            
            # 检查是否完成
            if "FINISH" in thought:
                # 提取最终答案
                final_answer = self._extract_final_answer(thought)
                return final_answer, trajectory
            
            # 解析并执行工具调用
            action = self._parse_action(thought)
            if action:
                tool_name, tool_args = action
                observation = self._execute_tool(tool_name, tool_args)
                messages.append({"role": "user", "content": f"观察结果: {observation}"})
                trajectory[-1]["action"] = tool_name
                trajectory[-1]["observation"] = observation
            
            iteration += 1
        
        # 达到最大迭代次数
        return "抱歉，我无法在限定步骤内完成这个任务。", trajectory
    
    def _parse_action(self, thought: str) -> Tuple[str, Dict] | None:
        """从思考内容中解析行动"""
        import re
        # 匹配 工具名(参数) 格式
        pattern = r'行动:\s*(\w+)\((.*?)\)'
        match = re.search(pattern, thought, re.DOTALL)
        
        if match:
            tool_name = match.group(1)
            args_str = match.group(2)
            try:
                # 尝试解析JSON参数
                arguments = json.loads(args_str)
            except:
                # 简单字符串参数
                arguments = {"query": args_str.strip('"\'')}
            return tool_name, arguments
        return None
    
    def _execute_tool(self, tool_name: str, arguments: Dict) -> str:
        """执行工具（异步转同步）"""
        import asyncio
        try:
            loop = asyncio.get_event_loop()
        except RuntimeError:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
        return loop.run_until_complete(execute_tool(tool_name, arguments))
    
    def _extract_final_answer(self, thought: str) -> str:
        """提取最终答案"""
        import re
        # 匹配 FINISH 后的内容
        pattern = r'FINISH:?\s*(.+?)$'
        match = re.search(pattern, thought, re.DOTALL | re.IGNORECASE)
        if match:
            return match.group(1).strip()
        
        # 如果没有FINISH标志，返回整个思考内容
        # 移除行动相关行
        lines = thought.split('\n')
        filtered = [l for l in lines if not l.startswith('行动:')]
        return '\n'.join(filtered)