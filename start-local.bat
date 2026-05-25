@echo off
chcp 65001 >nul
echo =========================================
echo   AI Seckill System - Local Mode (No Docker)
echo =========================================
echo.
echo This script will guide you to start services manually.
echo Please ensure you have installed:
echo   - JDK 17+
echo   - Python 3.11+
echo   - Node.js 18+
echo   - Maven 3.9+
echo   - MySQL 8.0
echo   - Redis 7.x
echo   - Nacos 2.3.0
echo.
pause

echo.
echo [STEP 1] Please start MySQL, Redis, and Nacos manually
echo.
echo If using Docker, run these commands:
echo   docker run -d --name seckill-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root123456 -e MYSQL_DATABASE=seckill mysql:8.0
echo   docker run -d --name seckill-redis -p 6379:6379 redis:7-alpine
echo   docker run -d --name seckill-nacos -p 8848:8848 -e MODE=standalone nacos/nacos-server:v2.3.0
echo.
pause

echo.
echo [STEP 2] Initialize database
echo Run this command in terminal:
echo   mysql -h localhost -u root -proot123456 seckill ^< seckill-parent\schema.sql
echo.
pause

echo.
echo [STEP 3] Build Java project
cd seckill-parent
call mvn clean install -DskipTests
if errorlevel 1 (
    echo [ERROR] Maven build failed!
    pause
    exit /b 1
)
cd ..

echo.
echo [STEP 4] Start Java microservices
echo Please open 5 separate terminals and run:
echo.
echo Terminal 1 - User Service:
echo   cd seckill-user-service
echo   mvn spring-boot:run
echo.
echo Terminal 2 - Product Service:
echo   cd seckill-product-service
echo   mvn spring-boot:run
echo.
echo Terminal 3 - Order Service:
echo   cd seckill-order-service
echo   mvn spring-boot:run
echo.
echo Terminal 4 - Seckill Service:
echo   cd seckill-seckill-service
echo   mvn spring-boot:run
echo.
echo Terminal 5 - Gateway:
echo   cd seckill-gateway
echo   mvn spring-boot:run
echo.
pause

echo.
echo [STEP 5] Start Python AI Agent
echo Open a new terminal and run:
echo   cd python-ai-agent
echo   python -m venv venv
echo   venv\Scripts\activate
echo   pip install -r requirements.txt
echo   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
echo.
pause

echo.
echo [STEP 6] Start Vue Frontend
echo Open a new terminal and run:
echo   cd seckill-frontend
echo   npm install
echo   npm run dev
echo.
pause

echo.
echo =========================================
echo   All services should be running now!
echo =========================================
echo.
echo Access URLs:
echo   - Frontend:     http://localhost:3000
echo   - API Gateway:  http://localhost:8080
echo   - Python AI:    http://localhost:8000
echo   - Nacos Admin:  http://localhost:8848/nacos
echo   - API Docs:     http://localhost:8080/swagger-ui.html
echo.
pause
