#!/bin/bash
# ========================================
# 停止轻量级部署的所有服务
# ========================================

echo "========================================="
echo "  停止所有轻量级服务..."
echo "========================================="

# 停止Java进程
if [ -f /tmp/gateway.pid ]; then
    kill $(cat /tmp/gateway.pid) 2>/dev/null || true
    rm /tmp/gateway.pid
    echo "✓ Gateway已停止"
fi

if [ -f /tmp/user-service.pid ]; then
    kill $(cat /tmp/user-service.pid) 2>/dev/null || true
    rm /tmp/user-service.pid
    echo "✓ User Service已停止"
fi

if [ -f /tmp/product-service.pid ]; then
    kill $(cat /tmp/product-service.pid) 2>/dev/null || true
    rm /tmp/product-service.pid
    echo "✓ Product Service已停止"
fi

if [ -f /tmp/order-service.pid ]; then
    kill $(cat /tmp/order-service.pid) 2>/dev/null || true
    rm /tmp/order-service.pid
    echo "✓ Order Service已停止"
fi

if [ -f /tmp/seckill-service.pid ]; then
    kill $(cat /tmp/seckill-service.pid) 2>/dev/null || true
    rm /tmp/seckill-service.pid
    echo "✓ Seckill Service已停止"
fi

if [ -f /tmp/frontend.pid ]; then
    kill $(cat /tmp/frontend.pid) 2>/dev/null || true
    rm /tmp/frontend.pid
    echo "✓ Frontend已停止"
fi

# 停止Docker容器
docker-compose down 2>/dev/null || true

echo ""
echo "所有服务已停止！"
echo "========================================="
