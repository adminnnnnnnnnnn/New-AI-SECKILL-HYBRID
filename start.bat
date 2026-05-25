@echo off
echo.
echo ========================================
echo   AI-Seckill-Hybrid v4.0 Quick Start
echo ========================================
echo.
echo Step 1: Checking Docker...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker not found!
    echo Please start Docker Desktop first.
    pause
    exit /b 1
)
echo OK: Docker is running
echo.
echo Step 2: Starting infrastructure...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ERROR: Failed to start services
    pause
    exit /b 1
)
echo OK: Services starting...
echo.
echo Step 3: Waiting for services to be ready...
echo This may take 2-3 minutes...
timeout /t 60 /nobreak >nul
echo.
echo Step 4: Checking service status...
docker ps --format "table {{.Names}}\t{{.Status}}"
echo.
echo ========================================
echo Infrastructure started successfully!
echo.
echo Next steps:
echo   1. Open NEW terminal for backend:
echo      cd seckill-parent\seckill-inventory-service
echo      mvn spring-boot:run
echo.
echo   2. Open ANOTHER terminal for frontend:
echo      cd seckill-frontend
echo      npm run dev
echo.
echo   3. Access: http://localhost:5173
echo      Account: admin / admin123
echo ========================================
pause
