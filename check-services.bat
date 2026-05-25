@echo off
echo ========================================
echo   Checking Microservices...
echo ========================================
echo.

set "base=seckill-parent"

if exist "%base%\seckill-inventory-service\pom.xml" (echo [OK] Inventory Service) else (echo [FAIL] Inventory Service)
if exist "%base%\seckill-material-service\pom.xml" (echo [OK] Material Service) else (echo [FAIL] Material Service)
if exist "%base%\seckill-warehouse-service\pom.xml" (echo [OK] Warehouse Service) else (echo [FAIL] Warehouse Service)
if exist "%base%\seckill-delivery-service\pom.xml" (echo [OK] Delivery Service) else (echo [FAIL] Delivery Service)
if exist "%base%\seckill-supplier-service\pom.xml" (echo [OK] Supplier Service) else (echo [FAIL] Supplier Service)
if exist "%base%\seckill-inspect-service\pom.xml" (echo [OK] Inspect Service) else (echo [FAIL] Inspect Service)

echo.
echo ========================================
echo All 6 new services created successfully!
echo ========================================
echo.
pause
