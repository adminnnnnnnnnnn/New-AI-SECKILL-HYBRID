#!/bin/bash
# ========================================
# AI-Seckill-Hybrid 停止服务脚本
# ========================================

echo "========================================="
echo "  停止所有服务..."
echo "========================================="

# 停止screen会话
for session in gateway user-service product-service order-service seckill-service inventory-service ai-agent frontend; do
    screen -S $session -X quit 2>/dev/null || true
done

# 停止Docker容器
docker-compose down

echo ""
echo "所有服务已停止！"
echo "========================================="
