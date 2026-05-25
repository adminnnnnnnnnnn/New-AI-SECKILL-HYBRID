@echo off
chcp 65001 >nul
echo ========================================
echo   供应链系统 - JMeter压力测试执行脚本
echo ========================================
echo.

set JMETER_HOME=C:\apache-jmeter-5.6.2
set TEST_PLAN=%~dp0seckill-load-test.jmx
set RESULTS_DIR=%~dp0results
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set RESULT_FILE=%RESULTS_DIR%\test-result-%TIMESTAMP%.jtl
set REPORT_DIR=%RESULTS_DIR%\report-%TIMESTAMP%

echo [Step 1] 检查JMeter安装...
if not exist "%JMETER_HOME%\bin\jmeter.bat" (
    echo [ERROR] JMeter未找到,请设置JMETER_HOME环境变量
    echo 下载地址: https://jmeter.apache.org/download_jmeter.cgi
    pause
    exit /b 1
)
echo [OK] JMeter路径: %JMETER_HOME%
echo.

echo [Step 2] 创建结果目录...
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"
echo [OK] 结果目录: %RESULTS_DIR%
echo.

echo [Step 3] 预热Redis库存...
echo 请在执行前手动执行以下命令:
echo   docker exec -it seckill-redis redis-cli SET stock:seckill:1:100 10000
echo.
pause
echo.

echo [Step 4] 开始压力测试...
echo 测试配置:
echo   - 并发用户: 5000
echo   - 启动时间: 10秒
echo   - 持续时间: 5分钟(300秒)
echo   - 目标接口: POST /api/inventory/seckill/decrease
echo.
echo 预计完成时间: %time% (5分钟后)
echo.

"%JMETER_HOME%\bin\jmeter.bat" -n -t "%TEST_PLAN%" -l "%RESULT_FILE%" -e -o "%REPORT_DIR%"

if errorlevel 1 (
    echo [ERROR] 压力测试执行失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo   压力测试完成!
echo ========================================
echo.
echo 测试结果文件: %RESULT_FILE%
echo HTML报告目录: %REPORT_DIR%
echo.
echo 查看HTML报告:
echo   start %REPORT_DIR%\index.html
echo.
echo 关键指标:
echo   - QPS (吞吐量)
echo   - P90/P95/P99响应时间
echo   - 错误率
echo   - 成功率
echo.
pause
