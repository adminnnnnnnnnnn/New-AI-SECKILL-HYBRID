m#!/bin/bash
# ========================================
# AI-Seckill-Hybrid 轻量级部署脚本 (2核2G专用)
# 针对低配置服务器优化
# ========================================

set -e

PROJECT_DIR="/opt/ai-seckill"
SERVER_IP="182.254.244.202"

echo "========================================="
echo "  AI-Seckill-Hybrid 轻量级部署 (2核2G)"
echo "  服务器: $SERVER_IP"
echo "========================================="

cd $PROJECT_DIR

# 0. 增加Swap空间（重要！2G内存必须）
echo "[0/7] 配置Swap空间..."
if [ ! -f /swapfile ]; then
    echo "创建4GB Swap空间..."
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    # 设置开机自动挂载
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    
    # 调整Swappiness参数
    sysctl vm.swappiness=10
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
fi
echo "✓ Swap空间已配置"
free -h

# 1. 拉取最新代码
echo "[1/7] 拉取最新代码..."
git pull origin main || echo "警告: Git拉取失败，使用现有代码"

# 2. 停止旧服务
echo "[2/7] 停止旧服务..."
docker-compose down || true

# 清理未使用的Docker资源释放空间
docker system prune -f

# 3. 启动基础设施（仅MySQL和Redis）
echo "[3/7] 启动基础设施(MySQL/Redis)..."
docker-compose up -d mysql redis

# Nacos太耗内存，暂时不启动，使用本地配置
echo "注意: 为节省内存，暂不启动Nacos，服务将使用本地配置"

# 等待MySQL就绪
echo "等待MySQL就绪..."
for i in {1..30}; do
    if docker exec seckill-mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo "✓ MySQL已就绪"
        break
    fi
    echo "等待中... ($i/30)"
    sleep 2
done

# 4. 初始化数据库
echo "[4/7] 检查并初始化数据库..."
if ! docker exec seckill-mysql mysql -uroot -proot123456 -e "USE seckill;" 2>/dev/null; then
    echo "初始化数据库..."
    docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < schema.sql
    echo "✓ 数据库初始化完成"
else
    echo "✓ 数据库已存在，跳过初始化"
fi

# 5. 编译Java项目（轻量级编译）
echo "[5/7] 编译Java项目..."
cd seckill-parent

# 清理之前的编译结果释放空间
mvn clean -q

# 仅编译必要的模块（网关+核心服务）
echo "编译核心服务模块..."
mvn install -pl seckill-common,seckill-gateway,seckill-user-service,seckill-product-service,seckill-order-service,seckill-seckill-service -am -DskipTests -q

echo "✓ Java项目编译完成"
cd ..

# 6. 启动核心微服务（限制JVM内存）
echo "[6/7] 启动核心微服务（优化内存配置）..."

# 定义JVM参数（限制每个服务最大256MB堆内存）
JVM_OPTS="-Xms128m -Xmx256m -XX:+UseSerialGC -XX:TieredStopAtLevel=1"

# 创建日志目录
mkdir -p logs

# Gateway (8080)
echo "启动 API Gateway..."
nohup java $JVM_OPTS \
  -jar seckill-parent/seckill-gateway/target/seckill-gateway-2.0.0.jar \
  > logs/gateway.log 2>&1 &
echo $! > /tmp/gateway.pid
sleep 5

# User Service (8085)
echo "启动 User Service..."
nohup java $JVM_OPTS \
  -Dserver.port=8085 \
  -jar seckill-parent/seckill-user-service/target/seckill-user-service-2.0.0.jar \
  > logs/user-service.log 2>&1 &
echo $! > /tmp/user-service.pid
sleep 3

# Product Service (8081)
echo "启动 Product Service..."
nohup java $JVM_OPTS \
  -Dserver.port=8081 \
  -jar seckill-parent/seckill-product-service/target/seckill-product-service-2.0.0.jar \
  > logs/product-service.log 2>&1 &
echo $! > /tmp/product-service.pid
sleep 3

# Order Service (8084)
echo "启动 Order Service..."
nohup java $JVM_OPTS \
  -Dserver.port=8084 \
  -jar seckill-parent/seckill-order-service/target/seckill-order-service-2.0.0.jar \
  > logs/order-service.log 2>&1 &
echo $! > /tmp/order-service.pid
sleep 3

# Seckill Service (8082)
echo "启动 Seckill Service..."
nohup java $JVM_OPTS \
  -Dserver.port=8082 \
  -jar seckill-parent/seckill-seckill-service/target/seckill-seckill-service-2.0.0.jar \
  > logs/seckill-service.log 2>&1 &
echo $! > /tmp/seckill-service.pid
sleep 3

echo "✓ 核心微服务已启动"

# 7. 启动前端（生产模式）
echo "[7/7] 构建并启动前端..."
cd seckill-frontend

# 安装依赖（如果未安装）
if [ ! -d "node_modules" ]; then
    npm install --production
fi

# 构建生产版本
npm run build

# 使用serve提供静态文件（轻量级）
npm install -g serve
nohup serve -s dist -l 5173 > ../logs/frontend.log 2>&1 &
echo $! > /tmp/frontend.pid

cd ..

echo ""
echo "========================================="
echo "  轻量级部署完成！"
echo "========================================="
echo ""
echo "访问地址："
echo "  前端界面: http://$SERVER_IP:5173"
echo "  API网关:  http://$SERVER_IP:8080"
echo ""
echo "服务状态："
echo "  查看进程: ps aux | grep java"
echo "  查看日志: tail -f logs/gateway.log"
echo ""
echo "停止服务："
echo "  ./scripts/stop-lightweight.sh"
echo ""
echo "资源使用情况："
free -h
echo ""
echo "========================================="
echo "  注意事项："
echo "  1. 已启用4GB Swap空间缓解内存压力"
echo "  2. JVM堆内存限制为256MB/服务"
echo "  3. 仅启动核心服务，其他服务已禁用"
echo "  4. 如遇到OOM，请考虑升级服务器配置"
echo "========================================="
