@echo off
chcp 65001 >nul
echo ========================================
echo   供应链管理系统 v4.0
echo   快速编译与测试脚本
echo ========================================
echo.

echo [Step 1] 检查Java环境...
java -version
if errorlevel 1 (
    echo [ERROR] Java未安装或未配置环境变量
    pause
    exit /b 1
)
echo.

echo [Step 2] 检查Maven环境...
mvn -version
if errorlevel 1 (
    echo [ERROR] Maven未安装或未配置环境变量
    pause
    exit /b 1
)
echo.

echo [Step 3] 清理并编译项目...
cd seckill-parent
call mvn clean install -DskipTests
if errorlevel 1 (
    echo [ERROR] 项目编译失败
    pause
    exit /b 1
)
echo.

echo [Step 4] 验证编译结果...
echo.
echo 已编译的微服务模块:
dir /b seckill-*-service\pom.xml
echo.

echo ========================================
echo   编译成功!
echo ========================================
echo.
echo 下一步操作:
echo 1. 启动基础设施: ..\start-v4.bat
echo 2. 启动微服务: cd seckill-inventory-service ^&^& mvn spring-boot:run
echo 3. 访问Swagger: http://localhost:8083/swagger-ui.html
echo.
pause
