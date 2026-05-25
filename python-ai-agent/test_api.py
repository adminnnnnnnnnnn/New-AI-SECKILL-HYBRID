"""测试通义千问API是否可用"""
import os
from openai import OpenAI

# 加载环境变量
os.environ['DASHSCOPE_API_KEY'] = 'sk-a7db72f5eb2d45e8ba1692da12728c06'

client = OpenAI(
    api_key=os.getenv("DASHSCOPE_API_KEY"),
    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"
)

print("=" * 60)
print("🔍 测试通义千问API连接...")
print("=" * 60)

try:
    response = client.chat.completions.create(
        model="qwen-plus",
        messages=[{"role": "user", "content": "你好，请简单回复"}],
        temperature=0.7,
        max_tokens=50
    )
    
    print("\n✅ API调用成功！")
    print(f"模型: {response.model}")
    print(f"回答: {response.choices[0].message.content}")
    print("=" * 60)
    
except Exception as e:
    print(f"\n❌ API调用失败！")
    print(f"错误类型: {type(e).__name__}")
    print(f"错误信息: {str(e)}")
    print("=" * 60)
    print("\n可能的原因：")
    print("1. API Key无效或已过期")
    print("2. 账户欠费或额度用完")
    print("3. 网络连接问题")
    print("4. API服务暂时不可用")
