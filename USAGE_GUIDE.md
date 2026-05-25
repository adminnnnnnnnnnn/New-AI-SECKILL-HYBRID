# 📖 供应链集中筹措管理系统 v4.0 - 完整使用指南

**版本**: v4.0  
**最后更新**: 2026-05-20  
**状态**: ✅ **100%完成 - 可直接编译运行**

---

## 🎯 快速开始(5分钟)

### 前置要求

确保已安装以下软件:
- ✅ JDK 17+
- ✅ Maven 3.9+
- ✅ Docker & Docker Compose
- ✅ MySQL 8.0 (可选,可用Docker)
- ✅ Redis 7.x (可选,可用Docker)

### Step 1: 克隆项目

```powershell
git clone <repository-url>
cd ai-seckill-hybrid
```

### Step 2: 启动基础设施

```powershell
# 一键启动所有基础设施(MySQL、Redis、Nacos、RocketMQ、Seata)
.\start-v4.bat
```

**验证服务状态**:
```powershell
docker-compose ps
```

应看到以下服务运行中:
- ✅ mysql (3306端口)
- ✅ redis (6379端口)
- ✅ nacos (8848端口)
- ✅ rocketmq-namesrv (9876端口)
- ✅ rocketmq-broker (10911端口)
- ✅ rocketmq-console (8081端口)
- ✅ seata-server (8091端口)

### Step 3: 初始化数据库

```powershell
# 方式一: 使用Docker中的MySQL
docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < seckill-parent/schema.sql

# 方式二: 使用本地MySQL
mysql -h localhost -u root -proot123456 seckill < seckill-parent/schema.sql
```

### Step 4: 编译项目

```powershell
# 方式一: 使用Maven命令
cd seckill-parent
mvn clean install -DskipTests

# 方式二: 使用快捷脚本
.\build-and-test.bat
```

### Step 5: 启动微服务

#### 启动库存服务(示例)

```powershell
cd seckill-parent\seckill-inventory-service
mvn spring-boot:run
```

**访问Swagger文档**: http://localhost:8083/swagger-ui.html

#### 启动其他服务

```powershell
# 物资服务
cd ..\seckill-material-service
mvn spring-boot:run
# 访问: http://localhost:8087/swagger-ui.html

# 仓储服务
cd ..\seckill-warehouse-service
mvn spring-boot:run
# 访问: http://localhost:8088/swagger-ui.html

# 配送服务
cd ..\seckill-delivery-service
mvn spring-boot:run
# 访问: http://localhost:8089/swagger-ui.html

# 供应商服务
cd ..\seckill-supplier-service
mvn spring-boot:run
# 访问: http://localhost:8090/swagger-ui.html

# 验收服务
cd ..\seckill-inspect-service
mvn spring-boot:run
# 访问: http://localhost:8086/swagger-ui.html
```

---

## 🧪 API测试

### 库存服务API测试

#### 1. 秒杀库存扣减

```bash
curl -X POST "http://localhost:8083/api/inventory/seckill/decrease?sessionId=1&skuId=100&quantity=1"
```

**预期响应**: `true` (库存充足) 或 `false` (库存不足)

---

#### 2. 预占库存

```bash
curl -X POST "http://localhost:8083/api/inventory/occupy?userId=1&skuId=100&quantity=1"
```

**预期响应**: `"OCC1234567890"` (预占编号)

---

#### 3. 确认扣减

```bash
curl -X POST "http://localhost:8083/api/inventory/confirm/OCC1234567890"
```

**预期响应**: 200 OK

---

#### 4. 释放预占

```bash
curl -X POST "http://localhost:8083/api/inventory/release/OCC1234567890"
```

**预期响应**: 200 OK

---

#### 5. 查询库存

```bash
curl -X GET "http://localhost:8083/api/inventory/stock?warehouseId=1&skuId=100"
```

**预期响应**: `99` (剩余库存数量)

---

### 物资服务API测试

#### 1. 创建采购计划

```bash
curl -X POST "http://localhost:8087/api/material/purchase-plan" \
  -H "Content-Type: application/json" \
  -d '{
    "applicantId": 1,
    "items": [
      {"materialId": 100, "quantity": 50}
    ]
  }'
```

**预期响应**: `"PP1234567890"` (采购计划编号)

---

#### 2. 审批采购计划

```bash
curl -X POST "http://localhost:8087/api/material/purchase-plan/PP1234567890/approve?approverId=1&approved=true&remark=同意"
```

**预期响应**: 200 OK

---

### 配送服务API测试

#### 1. 创建配送单

```bash
curl -X POST "http://localhost:8089/api/delivery/order" \
  -H "Content-Type: application/json" \
  -d '{
    "orderNo": "DD1234567890",
    "address": "北京市朝阳区xxx"
  }'
```

**预期响应**: `"DO1234567890"` (配送单号)

---

#### 2. 更新配送状态

```bash
curl -X POST "http://localhost:8089/api/delivery/DO1234567890/status?status=1&remark=已发货"
```

**预期响应**: 200 OK

---

### 供应商服务API测试

#### 1. 供应商入驻申请

```bash
curl -X POST "http://localhost:8090/api/supplier/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试供应商",
    "creditCode": "91110000XXXXXXXXXX",
    "contactPhone": "13800138000"
  }'
```

**预期响应**: `"SUP1234567890"` (供应商编码)

---

#### 2. 审核供应商资质

```bash
curl -X POST "http://localhost:8090/api/supplier/SUP1234567890/audit?auditorId=1&approved=true&remark=审核通过"
```

**预期响应**: 200 OK

---

## 🔍 核心技术验证

### 1. 验证Redis Lua原子性

```bash
# 连接到Redis
docker exec -it seckill-redis redis-cli

# 设置测试库存
> SET stock:test:1:100 100

# 执行Lua脚本扣减库存
> EVAL "local stock = tonumber(redis.call('get', KEYS[1])) if stock and stock >= tonumber(ARGV[1]) then redis.call('decrby', KEYS[1], ARGV[1]) return 1 end return 0" 1 stock:test:1:100 1

# 查看剩余库存
> GET stock:test:1:100
```

**预期结果**: 返回 `1` (成功),库存变为 `99`

---

### 2. 验证Redisson分布式锁

在代码中添加日志观察锁的获取和释放:

```java
log.info("获取锁: key={}, thread={}", lockKey, Thread.currentThread().getName());
// ... 业务逻辑
log.info("释放锁: key={}, thread={}", lockKey, Thread.currentThread().getName());
```

---

### 3. 验证Seata全局事务

```bash
# 查看Seata日志
docker logs seata-server

# 模拟失败场景
# 在OrderServiceImpl中故意抛出异常
throw new RuntimeException("模拟失败");

# 观察回滚日志
```

---

### 4. 验证RocketMQ延时消息

```bash
# 访问RocketMQ Console
http://localhost:8081

# 查看消息轨迹
# 1. 点击"消息"标签
# 2. 搜索topic: order-timeout-topic
# 3. 查看消息详情和消费状态
```

---

## 🐛 常见问题排查

### Q1: 服务启动失败 - Connection refused

**错误信息**: `Connection refused: localhost:9876`

**原因**: RocketMQ未启动

**解决方案**:
```powershell
# 检查RocketMQ状态
docker-compose ps rocketmq-namesrv
docker-compose ps rocketmq-broker

# 重启RocketMQ
docker-compose restart rocketmq-namesrv rocketmq-broker

# 等待30秒后重试
Start-Sleep -Seconds 30
```

---

### Q2: Maven依赖下载失败

**错误信息**: `Could not resolve dependencies`

**解决方案**:
```powershell
# 清理Maven缓存
mvn dependency:purge-local-repository

# 重新下载
mvn clean install -U

# 如果仍然失败,检查网络连接和阿里云镜像配置
```

---

### Q3: Seata事务未生效

**错误信息**: `no available service 'default' found`

**解决方案**:
```yaml
# 检查application.yml中的Seata配置
seata:
  enabled: true
  application-id: ${spring.application.name}
  tx-service-group: my_test_tx_group
  service:
    vgroup-mapping:
      my_test_tx_group: default
    grouplist:
      default: 127.0.0.1:8091
```

---

### Q4: Redis连接超时

**错误信息**: `io.lettuce.core.RedisCommandTimeoutException`

**解决方案**:
```yaml
# 增加超时时间
spring:
  data:
    redis:
      timeout: 5000ms
      host: localhost
      port: 6379
```

---

### Q5: 数据库连接失败

**错误信息**: `Communications link failure`

**解决方案**:
```powershell
# 检查MySQL是否启动
docker-compose ps mysql

# 查看MySQL日志
docker logs seckill-mysql

# 重启MySQL
docker-compose restart mysql

# 等待30秒后重试
Start-Sleep -Seconds 30
```

---

## 📊 压力测试

### JMeter测试计划

**测试场景**: 秒杀抢购  
**并发用户**: 5000  
**持续时间**: 5分钟  

**测试步骤**:

1. **预热Redis库存**:
```bash
docker exec -it seckill-redis redis-cli
> SET stock:seckill:1:100 1000
```

2. **配置JMeter**:
   - Thread Group: 5000 threads
   - Ramp-Up Period: 10 seconds
   - Loop Count: Forever
   - Duration: 300 seconds

3. **HTTP请求**:
```
POST http://localhost:8083/api/inventory/seckill/decrease
Parameters:
  sessionId=1
  skuId=100
  quantity=1
```

4. **监控指标**:
   - QPS ≥ 5000
   - P99响应时间 ≤ 200ms
   - 超卖率 = 0%
   - 成功率 ≥ 99.9%

---

## 📝 开发建议

### 1. 代码规范

- ✅ 使用Lombok简化代码
- ✅ 统一使用Result封装响应
- ✅ 使用BusinessException抛出业务异常
- ✅ 添加完整的JavaDoc注释

### 2. 测试策略

- ✅ 单元测试: 每个Service方法
- ✅ 集成测试: RocketMQ + Seata
- ✅ 压力测试: JMeter 5000 QPS

### 3. 性能优化

- ✅ Redis缓存热点数据
- ✅ 数据库索引优化
- ✅ 异步处理非核心逻辑
- ✅ 限流保护关键接口

---

## 📞 技术支持

### 重要文档

1. **[README_FINAL.md](README_FINAL.md)** - 最终项目README
2. **[QUICK_START_AND_TEST.md](QUICK_START_AND_TEST.md)** - 快速启动与测试
3. **[FINAL_PROJECT_COMPLETION.md](FINAL_PROJECT_COMPLETION.md)** - 项目完成报告
4. **[INVENTORY_SERVICE_EXAMPLE.md](INVENTORY_SERVICE_EXAMPLE.md)** - 库存服务800行示例
5. **[TECHNICAL_IMPLEMENTATION_GUIDE.md](TECHNICAL_IMPLEMENTATION_GUIDE.md)** - 技术实现指南

### 联系方式

如有问题,请查阅以上文档或提交Issue。

**祝您使用愉快! 🚀**
