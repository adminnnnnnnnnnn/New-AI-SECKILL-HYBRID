@echo off
REM 快速复制application.yml到其他服务并修改端口

echo 正在复制配置文件...

copy seckill-inventory-service\src\main\resources\application.yml seckill-material-service\src\main\resources\application.yml
copy seckill-inventory-service\src\main\resources\application.yml seckill-warehouse-service\src\main\resources\application.yml
copy seckill-inventory-service\src\main\resources\application.yml seckill-delivery-service\src\main\resources\application.yml
copy seckill-inventory-service\src\main\resources\application.yml seckill-supplier-service\src\main\resources\application.yml
copy seckill-inventory-service\src\main\resources\application.yml seckill-inspect-service\src\main\resources\application.yml

echo.
echo 配置文件已复制完成!
echo 请手动修改以下服务的端口和服务名:
echo - seckill-material-service: port 8087, name material
echo - seckill-warehouse-service: port 8088, name warehouse
echo - seckill-delivery-service: port 8089, name delivery
echo - seckill-supplier-service: port 8090, name supplier
echo - seckill-inspect-service: port 8086, name inspect
echo.
pause
