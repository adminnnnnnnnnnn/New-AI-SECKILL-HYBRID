@echo off
echo.
echo ================================================================
echo   AI-Seckill-Hybrid v4.0 - Quick Start
echo ================================================================
echo.
echo [1/3] Starting Docker infrastructure...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ERROR: Docker Compose failed
    pause
    exit /b 1
)
echo OK: Infrastructure starting...
echo.
echo [2/3] Waiting for services...
timeout /t 30 /nobreak >nul
echo OK: Services ready
echo.
echo [3/3] Warming up Redis...
docker exec seckill-redis redis-cli SET "stock:seckill:1:100" "10000" >nul 2>&1
echo OK: Redis warmed up
echo.
echo ================================================================
echo Infrastructure started successfully!
echo.
echo Next steps:
echo   1. Start backend: cd seckill-parent\seckill-inventory-service ^&^& mvn spring-boot:run
echo   2. Start frontend: cd seckill-frontend ^&^& npm run dev
echo   3. Access: http://localhost:5173 (admin/admin123)
echo.
echo Service URLs:
echo   Nacos: http://localhost:8848/nacos
echo   MySQL: localhost:3306
echo   Redis: localhost:6379
echo ================================================================
pause
