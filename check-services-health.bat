@echo off
chcp 65001 >nul
echo ========================================
echo   AI-Seckill-Hybrid 服务健康检查
echo ========================================
echo.

:: 检查Docker容器
echo [1/4] 检查Docker容器状态...
docker ps --format "table {{.Names}}\t{{.Status}}" | findstr /C:"seckill-mysql" /C:"seckill-redis" >nul
if %errorlevel% equ 0 (
    echo ✓ MySQL和Redis容器运行正常
    docker ps --format "  - {{.Names}}: {{.Status}}" | findstr /C:"seckill-mysql" /C:"seckill-redis"
) else (
    echo ✗ Docker容器未运行，请先启动Docker Desktop
    goto :error
)
echo.

:: 检查后端端口
echo [2/4] 检查后端微服务端口...
set "ports=8080 8081 8082 8083 8084"
set "services=Gateway User Product Order Seckill"
set "all_ok=true"

for %%p in (%ports%) do (
    netstat -ano | findstr ":%%p " >nul
    if !errorlevel! equ 0 (
        echo ✓ 端口 %%p 正在监听
    ) else (
        echo ✗ 端口 %%p 未启动
        set "all_ok=false"
    )
)
echo.

:: 检查前端端口
echo [3/4] 检查前端服务...
netstat -ano | findstr ":3000 " >nul
if %errorlevel% equ 0 (
    echo ✓ 前端服务运行在 http://localhost:3000
) else (
    echo ✗ 前端服务未启动
    set "all_ok=false"
)
echo.

:: 测试API连通性
echo [4/4] 测试API连通性...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/actuator/health' -TimeoutSec 3 -ErrorAction Stop; Write-Host '✓ Gateway健康检查通过' } catch { Write-Host '✗ Gateway无法访问' }"
echo.

:: 总结
echo ========================================
if "%all_ok%"=="true" (
    echo ✓ 所有服务运行正常！
    echo.
    echo 🌐 立即访问: http://localhost:3000
    echo 📚 API文档: http://localhost:8080/swagger-ui.html
) else (
    echo ✗ 部分服务异常，请检查日志
    echo.
    echo 💡 提示: 参考 LOCAL_RUN_GUIDE.md 进行故障排查
)
echo ========================================

pause
exit /b 0

:error
echo.
echo 错误: 基础环境未就绪
echo 请确保:
echo   1. Docker Desktop 已启动
echo   2. MySQL和Redis容器已创建
echo.
pause
exit /b 1
