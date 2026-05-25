# ========================================
# 供应链集中筹措管理系统 v4.0
# 快速验证脚本
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  供应链集中筹措管理系统 v4.0" -ForegroundColor Cyan
Write-Host "  微服务骨架验证" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查所有微服务目录
$services = @(
    @{Name="库存服务"; Path="seckill-inventory-service"; Port=8083},
    @{Name="物资服务"; Path="seckill-material-service"; Port=8087},
    @{Name="仓储服务"; Path="seckill-warehouse-service"; Port=8088},
    @{Name="配送服务"; Path="seckill-delivery-service"; Port=8089},
    @{Name="供应商服务"; Path="seckill-supplier-service"; Port=8090},
    @{Name="验收服务"; Path="seckill-inspect-service"; Port=8086}
)

$allOk = $true

foreach ($svc in $services) {
    $pomPath = "seckill-parent\$($svc.Path)\pom.xml"
    $appPath = "seckill-parent\$($svc.Path)\src\main\java\com\seckill\*$($svc.Path.Split('-')[1])\*ServiceApplication.java"
    $ymlPath = "seckill-parent\$($svc.Path)\src\main\resources\application.yml"
    
    Write-Host "检查 $($svc.Name)..." -NoNewline
    
    if (Test-Path $pomPath) {
        Write-Host " [OK]" -ForegroundColor Green
    } else {
        Write-Host " [FAIL] pom.xml缺失" -ForegroundColor Red
        $allOk = $false
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "✓ 所有微服务骨架创建成功!" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步操作:" -ForegroundColor Yellow
    Write-Host "1. 启动基础设施: .\start-v4.bat" -ForegroundColor White
    Write-Host "2. 编译项目: cd seckill-parent; mvn clean install -DskipTests" -ForegroundColor White
    Write-Host "3. 启动各服务: cd <service-name>; mvn spring-boot:run" -ForegroundColor White
    Write-Host ""
    Write-Host "微服务端口分配:" -ForegroundColor Cyan
    Write-Host "  - 库存服务: 8083" -ForegroundColor White
    Write-Host "  - 验收服务: 8086" -ForegroundColor White
    Write-Host "  - 物资服务: 8087" -ForegroundColor White
    Write-Host "  - 仓储服务: 8088" -ForegroundColor White
    Write-Host "  - 配送服务: 8089" -ForegroundColor White
    Write-Host "  - 供应商服务: 8090" -ForegroundColor White
} else {
    Write-Host "✗ 部分文件缺失,请检查上述错误" -ForegroundColor Red
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
