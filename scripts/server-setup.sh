#!/bin/bash
# ========================================
# AI-Seckill-Hybrid 服务器初始化脚本
# 在腾讯云服务器上执行此脚本
# ========================================

set -e

echo "========================================="
echo "  AI-Seckill-Hybrid 服务器环境初始化"
echo "========================================="

# 1. 更新系统
echo "[1/8] 更新系统..."
apt update && apt upgrade -y

# 2. 安装基础工具
echo "[2/8] 安装基础工具..."
apt install -y git curl wget vim net-tools htop

# 3. 安装Docker
echo "[3/8] 安装Docker..."
apt install -y docker.io docker-compose

# 启动Docker服务
systemctl start docker
systemctl enable docker

# 将当前用户加入docker组
usermod -aG docker $USER

# 4. 安装Java 17
echo "[4/8] 安装Java 17..."
apt install -y openjdk-17-jdk maven

# 5. 安装Node.js 18
echo "[5/8] 安装Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# 6. 安装Python 3.11
echo "[6/8] 安装Python 3.11..."
apt install -y python3.11 python3.11-venv python3-pip

# 7. 创建项目目录
echo "[7/8] 创建项目目录..."
mkdir -p /opt/ai-seckill
cd /opt/ai-seckill

# 8. 配置Git（如果尚未配置）
echo "[8/8] 配置Git..."
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

echo ""
echo "========================================="
echo "  环境初始化完成！"
echo "========================================="
echo ""
echo "下一步操作："
echo "1. 克隆代码: git clone <你的仓库地址> ."
echo "2. 启动基础设施: docker-compose up -d mysql redis nacos"
echo "3. 初始化数据库: docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < schema.sql"
echo "4. 编译项目: cd seckill-parent && mvn clean install -DskipTests"
echo "5. 启动服务: 参考 DEPLOYMENT_GUIDE.md"
echo ""
echo "========================================="
