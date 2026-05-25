# AI-Seckill-Hybrid 服务健康检查脚本
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI-Seckill-Hybrid 服务健康检查" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查Docker容器
Write-Host "[1/4] 检查Docker容器状态..." -ForegroundColor Yellow
$containers = docker ps --format "{{.Names}}" 2>$null
if ($containers -match "seckill-mysql" -and $containers -match "seckill-redis") {
    Write-Host "✓ MySQL和Redis容器运行正常" -ForegroundColor Green
    docker ps --format "  - {{.Names}}: {{.Status}}" | Where-Object { $_ -match "seckill-(mysql|redis)" }
} else {
    Write-Host "✗ Docker容器未运行，请先启动Docker Desktop" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 检查后端端口
Write-Host "[2/4] 检查后端微服务端口..." -ForegroundColor Yellow
$services = @{
    "8080" = "Gateway"
    "8081" = "User Service"
    "8082" = "Product Service"
    "8083" = "Order Service"
    "8084" = "Seckill Service"
}

$all_ok = $true
foreach ($port in $services.Keys) {
    $result = netstat -ano | Select-String ":${port} " | Select-Object -First 1
    if ($result) {
        Write-Host "✓ 端口 ${port} (${services[$port]}) 正在监听" -ForegroundColor Green
    } else {
        Write-Host "✗ 端口 ${port} (${services[$port]}) 未启动" -ForegroundColor Red
        $all_ok = $false
    }
}
Write-Host ""

# 检查前端端口
Write-Host "[3/4] 检查前端服务..." -ForegroundColor Yellow
$result = netstat -ano | Select-String ":3000 " | Select-Object -First 1
if ($result) {
    Write-Host "✓ 前端服务运行在 http://localhost:3000" -ForegroundColor Green
} else {
    Write-Host "✗ 前端服务未启动" -ForegroundColor Red
    $all_ok = $false
}
Write-Host ""

# 测试API连通性
Write-Host "[4/4] 测试API连通性..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -TimeoutSec 3 -ErrorAction Stop
    Write-Host "✓ Gateway健康检查通过 (HTTP $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Gateway无法访问" -ForegroundColor Red
    $all_ok = $false
}
Write-Host ""

# 总结
Write-Host "========================================" -ForegroundColor Cyan
if ($all_ok) {
    Write-Host "✓ 所有服务运行正常！" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 立即访问: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "📚 API文档: http://localhost:8080/swagger-ui.html" -ForegroundColor Cyan
} else {
    Write-Host "✗ 部分服务异常，请检查日志" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 提示: 参考 LOCAL_RUN_GUIDE.md 进行故障排查" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor Cyan
