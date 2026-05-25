# app/agent/prompt_manager.py
"""
Prompt版本管理 - 支持A/B测试
"""
import json
import os
from typing import Dict, Optional
from datetime import datetime


class PromptManager:
    """Prompt模板管理器"""
    
    def __init__(self, storage_path: str = "data/prompts.json"):
        self.storage_path = storage_path
        self.prompts = self._load()
    
    def _load(self) -> Dict:
        if os.path.exists(self.storage_path):
            with open(self.storage_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        
        # 默认模板
        default = {
            "system_default": {
                "version": "1.0.0",
                "template": "你是{role}，请根据{context}回答问题。{rag_content}",
                "created_at": datetime.now().isoformat()
            },
            "system_strict": {
                "version": "1.0.0", 
                "template": """你是一个专业的{role}。你必须严格按照JSON格式回答：{"answer": "...", "confidence": 0.0-1.0}

{rag_content}

置信度规则：0.9-1.0确定/0.7-0.9比较确定/0.5-0.7一般/0.0-0.5不确定

实时数据：{context}""",
                "created_at": datetime.now().isoformat()
            }
        }
        self._save(default)
        return default
    
    def _save(self, data: Dict = None):
        with open(self.storage_path, 'w', encoding='utf-8') as f:
            json.dump(data or self.prompts, f, ensure_ascii=False, indent=2)
    
    def get_prompt(self, name: str, version: Optional[str] = None) -> str:
        """获取指定版本的Prompt模板"""
        prompt_data = self.prompts.get(name)
        if not prompt_data:
            return ""
        
        if version and prompt_data['version'] != version:
            # 查找指定版本
            version_key = f"{name}_v{version}"
            if version_key in self.prompts:
                return self.prompts[version_key]['template']
        
        return prompt_data['template']
    
    def add_prompt(self, name: str, template: str, version: str = "1.0.0"):
        """添加新Prompt版本"""
        self.prompts[name] = {
            "version": version,
            "template": template,
            "created_at": datetime.now().isoformat()
        }
        self._save()
    
    def render(self, template: str, **kwargs) -> str:
        """渲染模板：支持{变量名}语法"""
        return template.format(**kwargs)


prompt_manager = PromptManager()