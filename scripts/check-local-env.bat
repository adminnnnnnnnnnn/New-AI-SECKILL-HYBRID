@echo off
chcp 65001 >nul
REM ========================================
REM AI-Seckill-Hybrid 本地开发环境检查脚本
REM 在Windows本地执行
REM ========================================

echo.
echo =========================================
echo   AI-Seckill-Hybrid 环境检查
echo =========================================
echo.

REM 检查Java
echo [1/7] 检查Java...
where java >nul 2>&1
if %errorlevel% equ 0 (
    java -version
    echo ✓ Java已安装
) else (
    echo ✗ Java未安装，请安装JDK 17+
    echo 下载地址: https://adoptium.net/
)
echo.

REM 检查Maven
echo [2/7] 检查Maven...
where mvn >nul 2>&1
if %errorlevel% equ 0 (
    mvn -version
    echo ✓ Maven已安装
) else (
    echo ✗ Maven未安装
    echo 下载地址: https://maven.apache.org/download.cgi
)
echo.

REM 检查Node.js
echo [3/7] 检查Node.js...
where node >nul 2>&1
if %errorlevel% equ 0 (
    node --version
    echo ✓ Node.js已安装
) else (
    echo ✗ Node.js未安装，请安装Node.js 18+
    echo 下载地址: https://nodejs.org/
)
echo.

REM 检查Python
echo [4/7] 检查Python...
where python >nul 2>&1
if %errorlevel% equ 0 (
    python --version
    echo ✓ Python已安装
) else (
    echo ✗ Python未安装，请安装Python 3.11+
    echo 下载地址: https://www.python.org/
)
echo.

REM 检查Docker
echo [5/7] 检查Docker...
where docker >nul 2>&1
if %errorlevel% equ 0 (
    docker --version
    echo ✓ Docker已安装
) else (
    echo ✗ Docker未安装
    echo 下载地址: https://www.docker.com/products/docker-desktop
)
echo.

REM 检查Git
echo [6/7] 检查Git...
where git >nul 2>&1
if %errorlevel% equ 0 (
    git --version
    echo ✓ Git已安装
) else (
    echo ✗ Git未安装
    echo 下载地址: https://git-scm.com/
)
echo.

REM 检查VSCode
echo [7/7] 检查VSCode...
where code >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ VSCode已安装
) else (
    echo ✗ VSCode未安装
    echo 下载地址: https://code.visualstudio.com/
)
echo.

echo =========================================
echo   环境检查完成！
echo =========================================
echo.
echo 推荐安装的VSCode扩展：
echo   - Remote - SSH
echo   - Vue Language Features (Volar)
echo   - Spring Boot Extension Pack
echo   - Python
echo   - Docker
echo   - GitLens
echo.
pause
