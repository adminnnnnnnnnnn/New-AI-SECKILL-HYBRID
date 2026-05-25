@echo off
chcp 65001 >nul
echo.
echo ================================================================
echo   供应链系统 - 前端应用启动脚本
echo ================================================================
echo.

echo [检查] Node.js环境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   ❌ Node.js未安装
    echo   请先安装Node.js 18+
    pause
    exit /b 1
)
echo   ✅ Node.js版本: 
node --version

echo.
echo [检查] npm依赖...
if not exist "node_modules" (
    echo   ⚠️  检测到未安装依赖,开始安装...
    echo   这可能需要几分钟时间,请耐心等待...
    call npm install
    if %errorlevel% neq 0 (
        echo   ❌ 依赖安装失败
        pause
        exit /b 1
    )
    echo   ✅ 依赖安装完成
) else (
    echo   ✅ 依赖已存在
)

echo.
echo [启动] 前端开发服务器...
echo   访问地址: http://localhost:5173
echo   登录账号: admin / admin123
echo.
echo   按 Ctrl+C 停止服务器
echo.
echo ================================================================
call npm run dev
