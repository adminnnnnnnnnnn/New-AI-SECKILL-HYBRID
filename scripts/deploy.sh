#!/bin/bash
# ========================================
# AI-Seckill-Hybrid 一键部署脚本
# 在腾讯云服务器上执行
# ========================================

set -e

PROJECT_DIR="/opt/ai-seckill"
SERVER_IP=$(curl -s ifconfig.me)

echo "========================================="
echo "  AI-Seckill-Hybrid 一键部署"
echo "========================================="
echo "服务器IP: $SERVER_IP"
echo ""

cd $PROJECT_DIR

# 1. 拉取最新代码
echo "[1/6] 拉取最新代码..."
git pull origin main || echo "警告: Git拉取失败，使用现有代码"

# 2. 停止旧服务
echo "[2/6] 停止旧服务..."
docker-compose down || true

# 3. 启动基础设施
echo "[3/6] 启动基础设施(MySQL/Redis/Nacos)..."
docker-compose up -d mysql redis nacos

# 等待服务就绪
echo "等待MySQL就绪..."
sleep 10

# 4. 初始化数据库（如果尚未初始化）
echo "[4/6] 检查数据库..."
if ! docker exec seckill-mysql mysql -uroot -proot123456 -e "USE seckill;" 2>/dev/null; then
    echo "初始化数据库..."
    docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < schema.sql
else
    echo "数据库已存在，跳过初始化"
fi

# 5. 编译Java项目
echo "[5/6] 编译Java项目..."
cd seckill-parent
mvn clean install -DskipTests -q

# 6. 启动所有微服务
echo "[6/6] 启动微服务..."
cd ..

# 创建screen会话运行各个服务
# Gateway
screen -dmS gateway bash -c "cd $PROJECT_DIR/seckill-parent/seckill-gateway && mvn spring-boot:run"

# User Service
screen -dmS user-service bash -c "cd $PROJECT_DIR/seckill-parent/seckill-user-service && mvn spring-boot:run"

# Product Service
screen -dmS product-service bash -c "cd $PROJECT_DIR/seckill-parent/seckill-product-service && mvn spring-boot:run"

# Order Service
screen -dmS order-service bash -c "cd $PROJECT_DIR/seckill-parent/seckill-order-service && mvn spring-boot:run"

# Seckill Service
screen -dmS seckill-service bash -c "cd $PROJECT_DIR/seckill-parent/seckill-seckill-service && mvn spring-boot:run"

# Inventory Service
screen -dmS inventory-service bash -c "cd $PROJECT_DIR/seckill-parent/seckill-inventory-service && mvn spring-boot:run"

# Python AI Agent
cd python-ai-agent
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install -r requirements.txt -q
screen -dmS ai-agent bash -c "cd $PROJECT_DIR/python-ai-agent && source venv/bin/activate && uvicorn app.main:app --host 0.0.0.0 --port 8000"

# Frontend
cd ../seckill-frontend
if [ ! -d "node_modules" ]; then
    npm install
fi
screen -dmS frontend bash -c "cd $PROJECT_DIR/seckill-frontend && npm run dev -- --host 0.0.0.0"

echo ""
echo "========================================="
echo "  部署完成！"
echo "========================================="
echo ""
echo "访问地址："
echo "  前端界面: http://$SERVER_IP:5173"
echo "  API网关:  http://$SERVER_IP:8080"
echo "  Nacos:    http://$SERVER_IP:8848/nacos (nacos/nacos)"
echo "  Python AI: http://$SERVER_IP:8000"
echo ""
echo "查看服务状态："
echo "  screen -ls  # 查看所有会话"
echo "  screen -r gateway  # 连接到Gateway日志"
echo ""
echo "停止服务："
echo "  cd $PROJECT_DIR && ./stop.sh"
echo ""
echo "========================================="
