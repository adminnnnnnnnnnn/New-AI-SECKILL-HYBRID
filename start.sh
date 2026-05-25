#!/bin/bash

echo "========================================="
echo "  AI智能秒杀系统 - 一键启动脚本"
echo "========================================="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装,请先安装Docker"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose未安装,请先安装Docker Compose"
    exit 1
fi

# 检查.env文件
if [ ! -f .env ]; then
    echo "⚠️  未找到.env文件,使用默认配置"
    echo "DASHSCOPE_API_KEY=your-api-key" > .env
fi

echo ""
echo "📦 正在启动基础设施(MySQL, Redis, Nacos)..."
docker-compose up -d mysql redis nacos

echo ""
echo "⏳ 等待服务就绪..."
sleep 10

echo ""
echo "🗄️  初始化数据库..."
docker exec seckill-mysql mysql -uroot -proot123456 seckill < seckill-parent/schema.sql 2>/dev/null || echo "数据库可能已初始化"

echo ""
echo "🐍 构建Python AI Agent..."
docker-compose build python-ai-agent

echo ""
echo "☕ 构建Java Gateway..."
docker-compose build gateway

echo ""
echo "🚀 启动所有服务..."
docker-compose up -d

echo ""
echo "✅ 所有服务已启动!"
echo ""
echo "📊 服务访问地址:"
echo "  - 前端界面:     http://localhost:3000"
echo "  - API网关:      http://localhost:8080"
echo "  - Python AI:    http://localhost:8000"
echo "  - Nacos控制台:  http://localhost:8848/nacos (nacos/nacos)"
echo "  - API文档:      http://localhost:8080/swagger-ui.html"
echo ""
echo "📝 查看日志: docker-compose logs -f"
echo "🛑 停止服务: docker-compose down"
echo ""
