"""完整测试AI服务链路"""
import time
import requests

print("=" * 60)
print(" 测试Python AI Agent服务...")
print("=" * 60)

# 测试1: 检查服务是否运行
try:
    r = requests.get('http://localhost:8000/health', timeout=5)
    print(f"\n✅ Python AI服务运行中 (状态码: {r.status_code})")
except Exception as e:
    print(f"\n❌ Python AI服务未启动: {e}")
    exit(1)

# 测试2: 测试AI分析接口
try:
    start = time.time()
    r = requests.post(
        'http://localhost:8000/api/seckill/analyze',
        json={'question': '你好', 'enable_reflection': False},
        timeout=30
    )
    elapsed = time.time() - start
    
    print(f"\n✅ AI分析接口响应成功")
    print(f"⏱️  响应时间: {elapsed:.2f}秒")
    print(f"📊 状态码: {r.status_code}")
    
    data = r.json()
    if data.get('code') == 200:
        answer = data['data']['answer']
        confidence = data['data']['confidence']
        print(f"🤖 AI回答: {answer[:100]}{'...' if len(answer) > 100 else ''}")
        print(f" 置信度: {confidence}")
    else:
        print(f"❌ API返回错误: {data}")
        
except requests.exceptions.Timeout:
    print(f"\n❌ AI分析超时（超过30秒）")
except Exception as e:
    print(f"\n❌ AI分析失败: {type(e).__name__}: {e}")

print("=" * 60)
