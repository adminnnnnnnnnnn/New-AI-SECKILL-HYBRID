# AI-Seckill-Hybrid Quick Start Guide

## IMPORTANT: Docker Desktop must be running first!

### Step 1: Start Docker Desktop
1. Open Docker Desktop application
2. Wait until it shows "Docker Desktop is running"
3. Verify: docker --version

### Step 2: Start Infrastructure
```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid
docker-compose up -d
```

### Step 3: Wait for services (2-3 minutes)
```powershell
timeout /t 120
docker ps
```

### Step 4: Start Backend Service
Open NEW terminal window:
```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-parent\seckill-inventory-service
mvn spring-boot:run
```

### Step 5: Start Frontend
Open ANOTHER terminal window:
```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-frontend
npm install
npm run dev
```

### Step 6: Access System
Browser: http://localhost:5173
Account: admin / admin123

## Common Issues:

### Issue 1: Docker not running
Solution: Start Docker Desktop application first

### Issue 2: Maven build failed
Solution: Make sure you are in the correct service directory
WRONG: cd seckill-parent && mvn spring-boot:run
RIGHT: cd seckill-parent\seckill-inventory-service && mvn spring-boot:run

### Issue 3: Chinese characters garbled in .bat files
Solution: Use CMD instead of PowerShell, or use the commands directly

## Quick Commands:

Check Docker: docker ps
Check MySQL: docker exec seckill-mysql mysql -uroot -proot123456 -e "SELECT 1"
Check Redis: docker exec seckill-redis redis-cli ping
Restart all: docker-compose restart
Stop all: docker-compose down
