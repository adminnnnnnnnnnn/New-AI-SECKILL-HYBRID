@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ================================================================
echo   供应链系统 - 后端服务启动菜单
echo ================================================================
echo.
echo 请选择要启动的服务:
echo.
echo   [1] 商品服务 (product:8081)
echo   [2] 秒杀服务 (seckill:8082)
echo   [3] 库存服务 (inventory:8083)
echo   [4] 订单服务 (order:8084)
echo   [5] 用户服务 (user:8085)
echo   [6] 验收服务 (inspect:8086)
echo   [7] 物资服务 (material:8087)
echo   [8] 仓储服务 (warehouse:8088)
echo   [9] 配送服务 (delivery:8089)
echo   [10] 供应商服务 (supplier:8090)
echo   [A] 启动所有服务(后台运行)
echo   [Q] 退出
echo.
echo ================================================================
set /p choice="请输入选择 (1-10/A/Q): "

if /i "%choice%"=="Q" exit /b 0

if /i "%choice%"=="A" (
    echo.
    echo 正在启动所有服务(后台运行)...
    start "商品服务" cmd /c "cd seckill-product-service && mvn spring-boot:run"
    timeout /t 3 /nobreak >nul
    start "秒杀服务" cmd /c "cd seckill-seckill-service && mvn spring-boot:run"
    timeout /t 3 /nobreak >nul
    start "库存服务" cmd /c "cd seckill-inventory-service && mvn spring-boot:run"
    timeout /t 3 /nobreak >nul
    start "订单服务" cmd /c "cd seckill-order-service && mvn spring-boot:run"
    timeout /t 3 /nobreak >nul
    start "物资服务" cmd /c "cd seckill-material-service && mvn spring-boot:run"
    timeout /t 3 /nobreak >nul
    start "仓储服务" cmd /c "cd seckill-warehouse-service && mvn spring-boot:run"
    timeout /t 3 /nobreak >nul
    start "配送服务" cmd /c "cd seckill-delivery-service && mvn spring-boot:run"
    timeout /t 3 /nobreak >nul
    start "供应商服务" cmd /c "cd seckill-supplier-service && mvn spring-boot:run"
    timeout /t 3 /nobreak >nul
    start "验收服务" cmd /c "cd seckill-inspect-service && mvn spring-boot:run"
    
    echo.
    echo ✅ 所有服务已启动!
    echo 请查看各个窗口了解启动状态
    pause
    exit /b 0
)

set service_name=""
set service_port=""

if "%choice%"=="1" set service_name=seckill-product-service& set service_port=8081
if "%choice%"=="2" set service_name=seckill-seckill-service& set service_port=8082
if "%choice%"=="3" set service_name=seckill-inventory-service& set service_port=8083
if "%choice%"=="4" set service_name=seckill-order-service& set service_port=8084
if "%choice%"=="5" set service_name=seckill-user-service& set service_port=8085
if "%choice%"=="6" set service_name=seckill-inspect-service& set service_port=8086
if "%choice%"=="7" set service_name=seckill-material-service& set service_port=8087
if "%choice%"=="8" set service_name=seckill-warehouse-service& set service_port=8088
if "%choice%"=="9" set service_name=seckill-delivery-service& set service_port=8089
if "%choice%"=="10" set service_name=seckill-supplier-service& set service_port=8090

if "%service_name%"=="" (
    echo ❌ 无效的选择
    pause
    exit /b 1
)

echo.
echo 正在启动 %service_name% (端口: %service_port%)...
echo Swagger文档: http://localhost:%service_port%/swagger-ui.html
echo.
cd %service_name%
call mvn spring-boot:run
