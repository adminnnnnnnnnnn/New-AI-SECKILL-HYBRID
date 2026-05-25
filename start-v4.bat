@echo off
REM ========================================
REM 供应链集中筹措管理系统 - 快速启动脚本
REM 版本: v4.0
REM 日期: 2026-05-20
REM ========================================

echo.
echo ========================================
echo   供应链集中筹措管理系统 v4.0
echo   快速启动脚本
echo ========================================
echo.

REM 检查Docker是否运行
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker未运行,请先启动Docker Desktop
    pause
    exit /b 1
)

echo [1/5] 启动基础设施(MySQL、Redis、Nacos、RocketMQ、Seata)...
docker-compose up -d mysql redis nacos rocketmq-namesrv rocketmq-broker seata-server

if %errorlevel% neq 0 (
    echo [错误] 基础设施启动失败
    pause
    exit /b 1
)

echo [2/5] 等待服务就绪(30秒)...
timeout /t 30 /nobreak >nul

echo [3/5] 验证服务状态...
docker-compose ps

echo.
echo [4/5] 初始化数据库...
docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < seckill-parent\schema.sql

if %errorlevel% neq 0 (
    echo [警告] 数据库初始化可能已执行过
)

echo.
echo [5/5] 启动Java微服务(需要手动执行)...
echo.
echo 请在新窗口中依次执行以下命令:
echo.
echo   cd seckill-parent\seckill-user-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-product-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-inventory-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-order-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-seckill-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-material-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-warehouse-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-delivery-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-supplier-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-inspect-service ^&^& mvn spring-boot:run
echo   cd seckill-parent\seckill-gateway ^&^& mvn spring-boot:run
echo.

echo ========================================
echo   基础设施启动完成!
echo.
echo   访问地址:
echo   - Nacos控制台: http://localhost:8848/nacos
echo   - RocketMQ控制台: http://localhost:8081
echo   - MySQL: localhost:3306 (root/root123456)
echo   - Redis: localhost:6379
echo ========================================
echo.

pause
