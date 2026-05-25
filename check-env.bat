@echo off
echo.
echo ========================================
echo   Environment Check
echo ========================================
echo.
echo [1] Java Version:
java -version 2>&1 | findstr "version"
echo.
echo [2] Maven Version:
mvn -version 2>&1 | findstr "Apache Maven"
echo.
echo [3] Node.js Version:
node --version 2>nul
if %errorlevel% neq 0 echo Node.js not installed
echo.
echo [4] Docker Version:
docker --version 2>nul
if %errorlevel% neq 0 echo Docker not installed or not running
echo.
echo ========================================
echo IMPORTANT: This project requires:
echo   - Java 17+ (You have Java 8)
echo   - Maven 3.8+
echo   - Node.js 18+
echo   - Docker Desktop (running)
echo.
echo Please install JDK 17 before continuing!
echo Download from: https://adoptium.net/
echo ========================================
pause
