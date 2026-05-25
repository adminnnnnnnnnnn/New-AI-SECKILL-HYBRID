param(
    [switch]$Clean = $false
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🚀 AI-Seckill-Hybrid 完整启动脚本" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 设置 Java 环境
$env:JAVA_HOME="D:\Java"
$env:Path="D:\Java\bin;$env:Path"

# 1. 停止所有旧进程（如果需要清理）
Write-Host "📍 第1步：清理旧进程..." -ForegroundColor Yellow

# 停止所有 Java 进程
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# 停止所有前端 Node 进程
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "✅ 已清理旧进程" -ForegroundColor Green
Write-Host ""

# 2. Docker 容器启动
Write-Host "📍 第2步：启动 Docker 容器..." -ForegroundColor Yellow

Set-Location "c:\Users\dell\Desktop\ai-seckill-hybrid"

# 停止并删除旧容器（如果 Clean 标志被设置）
if ($Clean) {
    docker-compose down -v
    Start-Sleep -Seconds 3
}

# 启动 Docker 容器
docker-compose up -d

Write-Host "✅ Docker 容器已启动，等待初始化..." -ForegroundColor Green
Start-Sleep -Seconds 15

# 验证关键容器
$requiredContainers = @("seckill-mysql", "seckill-redis")
foreach ($container in $requiredContainers) {
    $status = docker ps | Select-String $container
    if ($status) {
        Write-Host "  ✓ $container 运行中" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $container 未运行！" -ForegroundColor Red
    }
}

Write-Host ""

# 3. 检查 MySQL 是否就绪
Write-Host "📍 第3步：等待 MySQL 就绪..." -ForegroundColor Yellow
$maxRetries = 30
$retries = 0
while ($retries -lt $maxRetries) {
    try {
        $result = docker exec seckill-mysql mysql -uroot -proot123456 -e "SELECT 1" 2>&1
        if ($result -match "ERROR" -or $result -match "Can't") {
            Write-Host "  等待中... ($retries/$maxRetries)" -ForegroundColor Gray
            Start-Sleep -Seconds 2
            $retries++
        } else {
            Write-Host "✅ MySQL 已就绪" -ForegroundColor Green
            break
        }
    } catch {
        Write-Host "  等待中... ($retries/$maxRetries)" -ForegroundColor Gray
        Start-Sleep -Seconds 2
        $retries++
    }
}

Write-Host ""

# 4. 启动后端微服务
Write-Host "📍 第4步：启动后端微服务..." -ForegroundColor Yellow
Write-Host "  提示：每个服务将在新窗口启动，请稍候..." -ForegroundColor Gray

Set-Location "c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-parent"

# 定义要启动的服务
$services = @(
    @{ name="Gateway"; port=8080; jar="seckill-gateway/target/seckill-gateway-2.0.0.jar" },
    @{ name="User Service"; port=8081; jar="seckill-user-service/target/seckill-user-service-2.0.0.jar" },
    @{ name="Product Service"; port=8082; jar="seckill-product-service/target/seckill-product-service-2.0.0.jar" },
    @{ name="Order Service"; port=8083; jar="seckill-order-service/target/seckill-order-service-2.0.0.jar" },
    @{ name="Seckill Service"; port=8084; jar="seckill-seckill-service/target/seckill-seckill-service-2.0.0.jar" }
)

foreach ($service in $services) {
    $jarPath = $service.jar
    $serviceName = $service.name

    if (Test-Path $jarPath) {
        Write-Host "  启动 $serviceName (端口 $($service.port))..." -ForegroundColor Cyan
        Start-Process powershell -ArgumentList @"
            `$env:JAVA_HOME='D:\Java'
            `$env:Path='D:\Java\bin;`$env:Path'
            cd 'c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-parent'
            Write-Host '启动 $serviceName...' -ForegroundColor Green
            java -Xms256m -Xmx512m -jar $jarPath
"@
        Start-Sleep -Seconds 5
    } else {
        Write-Host "  ⚠️  $serviceName JAR 未找到: $jarPath" -ForegroundColor Yellow
    }
}

Write-Host "✅ 后端服务正在启动..." -ForegroundColor Green
Write-Host ""

# 5. 启动前端
Write-Host "📍 第5步：启动前端服务..." -ForegroundColor Yellow

Set-Location "c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-frontend"

# 检查 node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "  安装依赖..." -ForegroundColor Gray
    npm install
}

Write-Host "  在新窗口启动前端..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList @"
    cd 'c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-frontend'
    Write-Host '启动前端服务 (http://localhost:3000)...' -ForegroundColor Green
    npm run dev
"@

Write-Host "✅ 前端启动中..." -ForegroundColor Green
Write-Host ""

# 6. 总结
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ 所有服务启动完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 服务访问地址：" -ForegroundColor Cyan
Write-Host "  🌐 前端页面：http://localhost:3000" -ForegroundColor Green
Write-Host "  🔌 API 网关：http://localhost:8080" -ForegroundColor Green
Write-Host "  📚 API 文档：http://localhost:8080/swagger-ui.html" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 微服务端口：" -ForegroundColor Cyan
Write-Host "  - Gateway:        8080" -ForegroundColor Gray
Write-Host "  - User Service:   8081" -ForegroundColor Gray
Write-Host "  - Product Service: 8082" -ForegroundColor Gray
Write-Host "  - Order Service:  8083" -ForegroundColor Gray
Write-Host "  - Seckill Service: 8084" -ForegroundColor Gray
Write-Host ""
Write-Host "💾 数据库连接：" -ForegroundColor Cyan
Write-Host "  - MySQL: localhost:3307 (root/root123456)" -ForegroundColor Gray
Write-Host "  - Redis: localhost:6379" -ForegroundColor Gray
Write-Host ""
Write-Host "⏳ 第一次启动会比较慢，请等待 2-3 分钟..." -ForegroundColor Yellow
Write-Host "💡 可以在浏览器中打开 http://localhost:3000 查看前端" -ForegroundColor Cyan
Write-Host ""
