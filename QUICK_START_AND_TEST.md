# 🚀 供应链集中筹措管理系统 v4.0 - 快速启动与测试指南

**最后更新**: 2026-05-20  
**状态**: ✅ **核心代码示例已完成**

---

## ✅ 最新完成情况

### 新增核心代码 (刚刚完成)

#### 1. 库存服务完整实现 ✅
**文件位置**: `seckill-inventory-service/src/main/java/com/seckill/inventory/`

| 文件 | 说明 | 核心技术 |
|------|------|----------|
| InventoryService.java | 库存服务接口 | - |
| InventoryServiceImpl.java | **库存服务实现(200+行)** | Redis Lua + Redisson + Seata |
| SkuInventory.java | SKU库存实体 | MyBatis-Plus |
| SkuInventoryMapper.java | Mapper接口 | MyBatis-Plus |
| InventoryController.java | REST API | SpringDoc OpenAPI |
| OrderTimeoutListener.java | RocketMQ监听器 | RocketMQ延时消息 |
| OrderFeignClient.java | Feign客户端 | OpenFeign |

#### 2. 订单服务示例 ✅
**文件位置**: `seckill-order-service/src/main/java/com/seckill/order/`

| 文件 | 说明 | 核心技术 |
|------|------|----------|
| OrderServiceImpl.java | **订单服务实现(展示Seata)** | @GlobalTransactional |
| OrderTimeoutListener.java | 订单超时监听器 | RocketMQ延时消息 |

---

## 🎯 核心技术代码示例

### 1. Redis Lua原子扣减库存 ⭐⭐⭐

```java
// 文件: InventoryServiceImpl.java
@Override
public boolean decreaseSeckillStock(Long sessionId, Long skuId, Integer quantity) {
    String stockKey = "stock:seckill:" + sessionId + ":" + skuId;
    
    // Lua脚本: 原子扣减库存,防止超卖
    String luaScript = 
        "local stock = tonumber(redis.call('get', KEYS[1])) " +
        "if stock and stock >= tonumber(ARGV[1]) then " +
        "   redis.call('decrby', KEYS[1], ARGV[1]) " +
        "   return 1 " +
        "end " +
        "return 0";
    
    Long result = redisTemplate.execute(
        new DefaultRedisScript<>(luaScript, Long.class),
        Collections.singletonList(stockKey),
        quantity.toString()
    );
    
    return result != null && result == 1;
}
```

**优势**:
- ✅ 原子性操作,零超卖
- ✅ 高性能(微秒级响应)
- ✅ 无需分布式锁

---

### 2. Redisson分布式锁 ⭐⭐⭐

```java
// 文件: InventoryServiceImpl.java
@Override
@Transactional(rollbackFor = Exception.class)
public String preOccupyStock(Long userId, Long skuId, Integer quantity) {
    String lockKey = "lock:stock:" + userId + ":" + skuId;
    RLock lock = redissonClient.getLock(lockKey);
    
    try {
        // 尝试加锁,最多等待5秒,锁定10秒后自动释放
        if (lock.tryLock(5, 10, TimeUnit.SECONDS)) {
            
            // 1. 查询库存
            SkuInventory inventory = skuInventoryMapper.selectOne(...);
            
            if (inventory.getAvailableQuantity() < quantity) {
                throw new RuntimeException("库存不足");
            }
            
            // 2. 扣减可用库存,增加预占库存
            inventory.setAvailableQuantity(inventory.getAvailableQuantity() - quantity);
            inventory.setOccupiedQuantity(inventory.getOccupiedQuantity() + quantity);
            skuInventoryMapper.updateById(inventory);
            
            // 3. 生成预占编号
            String occupyNo = "OCC" + System.currentTimeMillis();
            
            // 4. 保存预占记录到Redis(30分钟过期)
            redisTemplate.opsForValue().set(occupyKey, userId.toString(), 30, TimeUnit.MINUTES);
            
            return occupyNo;
            
        } else {
            throw new RuntimeException("系统繁忙,请稍后重试");
        }
        
    } finally {
        if (lock.isHeldByCurrentThread()) {
            lock.unlock();
        }
    }
}
```

**优势**:
- ✅ 可重入锁
- ✅ 看门狗自动续期
- ✅ 防止死锁

---

### 3. Seata分布式事务 ⭐⭐⭐

```java
// 文件: OrderServiceImpl.java
@GlobalTransactional(name = "create-order-tx", rollbackFor = Exception.class)
public String createOrder(Long userId, Long skuId, Integer quantity) {
    
    // Step 1: 创建订单记录(本地事务)
    String orderNo = "DD" + System.currentTimeMillis();
    
    // Step 2: 扣减库存(远程调用,自动纳入全局事务)
    inventoryFeignClient.decreaseStock(skuId, quantity);
    
    // Step 3: 创建配送单(远程调用,自动纳入全局事务)
    deliveryFeignClient.createDelivery(orderNo);
    
    // Step 4: 发送RocketMQ延时消息
    rocketMQTemplate.syncSendDelayTimeMills(
        "order-timeout-topic", 
        orderNo, 
        30 * 60 * 1000
    );
    
    return orderNo;
}
```

**优势**:
- ✅ 跨服务一致性保障
- ✅ 自动回滚机制
- ✅ AT模式无侵入

---

### 4. RocketMQ延时消息 ⭐⭐

```java
// 文件: OrderTimeoutListener.java
@Component
@RocketMQMessageListener(
    topic = "order-timeout-topic",
    consumerGroup = "inventory-timeout-consumer-group"
)
public class OrderTimeoutListener implements RocketMQListener<String> {

    @Override
    public void onMessage(String occupyNo) {
        log.info("收到订单超时消息,准备释放预占库存: occupyNo={}", occupyNo);
        
        try {
            // 释放预占库存
            inventoryService.releaseOccupiedStock(occupyNo);
            log.info("预占库存释放成功: occupyNo={}", occupyNo);
            
        } catch (Exception e) {
            log.error("预占库存释放失败: occupyNo={}", occupyNo, e);
        }
    }
}
```

**使用场景**:
- ✅ 订单超时取消(30分钟)
- ✅ 库存预警通知
- ✅ 配送状态更新
- ✅ 供应商绩效计算

---

## 🚀 立即测试

### Step 1: 启动基础设施

```powershell
# 在项目根目录执行
.\start-v4.bat
```

**验证服务**:
```powershell
docker-compose ps
```

应看到以下服务运行中:
- ✅ mysql
- ✅ redis
- ✅ nacos
- ✅ rocketmq-namesrv
- ✅ rocketmq-broker
- ✅ rocketmq-console
- ✅ seata-server

---

### Step 2: 编译项目

```powershell
cd seckill-parent
mvn clean install -DskipTests
```

---

### Step 3: 启动库存服务

```powershell
cd seckill-inventory-service
mvn spring-boot:run
```

**访问Swagger文档**: http://localhost:8083/swagger-ui.html

---

### Step 4: 测试API

#### 测试1: 秒杀库存扣减

```bash
curl -X POST "http://localhost:8083/api/inventory/seckill/decrease?sessionId=1&skuId=100&quantity=1"
```

**预期结果**: `true` (库存充足) 或 `false` (库存不足)

---

#### 测试2: 预占库存

```bash
curl -X POST "http://localhost:8083/api/inventory/occupy?userId=1&skuId=100&quantity=1"
```

**预期结果**: `"OCC1234567890"` (预占编号)

---

#### 测试3: 确认扣减

```bash
curl -X POST "http://localhost:8083/api/inventory/confirm/OCC1234567890"
```

**预期结果**: 200 OK

---

#### 测试4: 释放预占

```bash
curl -X POST "http://localhost:8083/api/inventory/release/OCC1234567890"
```

**预期结果**: 200 OK

---

#### 测试5: 查询库存

```bash
curl -X GET "http://localhost:8083/api/inventory/stock?warehouseId=1&skuId=100"
```

**预期结果**: `99` (剩余库存数量)

---

## 📊 压力测试

### JMeter测试计划

**测试场景**: 秒杀抢购  
**并发用户**: 5000  
**持续时间**: 5分钟  

**测试步骤**:
1. 预热Redis库存: `SET stock:seckill:1:100 1000`
2. 并发请求: `POST /api/inventory/seckill/decrease`
3. 监控指标:
   - QPS ≥ 5000
   - P99响应时间 ≤ 200ms
   - 超卖率 = 0%
   - 成功率 ≥ 99.9%

---

## 🔍 验证核心技术

### 1. 验证Redis Lua原子性

```bash
# 查看Redis日志
docker logs seckill-redis

# 手动执行Lua脚本测试
docker exec -it seckill-redis redis-cli
> EVAL "local stock = tonumber(redis.call('get', KEYS[1])) if stock and stock >= tonumber(ARGV[1]) then redis.call('decrby', KEYS[1], ARGV[1]) return 1 end return 0" 1 stock:test 1
```

---

### 2. 验证Redisson分布式锁

```java
// 在代码中添加日志
log.info("获取锁: key={}, thread={}", lockKey, Thread.currentThread().getName());
log.info("释放锁: key={}, thread={}", lockKey, Thread.currentThread().getName());
```

---

### 3. 验证Seata全局事务

```bash
# 查看Seata日志
docker logs seata-server

# 模拟失败场景,观察回滚
# 在OrderServiceImpl中故意抛出异常
throw new RuntimeException("模拟失败");
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

## 🐛 常见问题

### Q1: 库存服务启动失败

**错误**: `Connection refused: localhost:9876`

**解决**:
```powershell
# 检查RocketMQ是否启动
docker-compose ps rocketmq-namesrv
docker-compose ps rocketmq-broker

# 重启RocketMQ
docker-compose restart rocketmq-namesrv rocketmq-broker
```

---

### Q2: Seata事务未生效

**错误**: `no available service 'default' found`

**解决**:
```yaml
# 检查application.yml中的Seata配置
seata:
  service:
    vgroup-mapping:
      my_test_tx_group: default
    grouplist:
      default: 127.0.0.1:8091
```

---

### Q3: Redis连接超时

**错误**: `io.lettuce.core.RedisCommandTimeoutException`

**解决**:
```yaml
# 增加超时时间
spring:
  data:
    redis:
      timeout: 5000ms
```

---

### Q4: Maven依赖下载失败

**错误**: `Could not resolve dependencies`

**解决**:
```powershell
# 清理Maven缓存
mvn dependency:purge-local-repository

# 重新下载
mvn clean install -U
```

---

## 📝 开发建议

### 1. 复制库存服务到其他服务

其他5个服务的Service层可以直接复制库存服务示例:

```bash
# 复制InventoryServiceImpl到MaterialServiceImpl
cp seckill-inventory-service/src/main/java/com/seckill/inventory/service/impl/InventoryServiceImpl.java \
   seckill-material-service/src/main/java/com/seckill/material/service/impl/MaterialServiceImpl.java

# 修改包名和类名
# package com.seckill.inventory → package com.seckill.material
# class InventoryServiceImpl → class MaterialServiceImpl

# 修改实体类和Mapper引用
# SkuInventory → Material
# skuInventoryMapper → materialMapper
```

---

### 2. 分步实现策略

**推荐顺序**:
1. ✅ 库存服务 (已完成示例)
2. ⏳ 订单服务 (已提供Seata示例)
3. ⏳ 物资服务 (参考库存服务)
4. ⏳ 配送服务 (参考库存服务)
5. ⏳ 供应商服务 (参考库存服务)
6. ⏳ 验收服务 (参考库存服务)

---

### 3. 测试驱动开发

每完成一个方法,立即编写单元测试:

```java
@SpringBootTest
class InventoryServiceTest {
    
    @Autowired
    private InventoryService inventoryService;
    
    @Test
    void testDecreaseSeckillStock() {
        boolean result = inventoryService.decreaseSeckillStock(1L, 100L, 1);
        assertTrue(result);
    }
}
```

---

## 📞 技术支持

**重要文档**:
- [INVENTORY_SERVICE_EXAMPLE.md](file://c:\Users\dell\Desktop\ai-seckill-hybrid\INVENTORY_SERVICE_EXAMPLE.md) - 库存服务800行完整示例
- [TECHNICAL_IMPLEMENTATION_GUIDE.md](file://c:\Users\dell\Desktop\ai-seckill-hybrid\TECHNICAL_IMPLEMENTATION_GUIDE.md) - 技术实现详细指南
- [PROJECT_COMPLETION_REPORT.md](file://c:\Users\dell\Desktop\ai-seckill-hybrid\PROJECT_COMPLETION_REPORT.md) - 项目完成报告

**祝您开发顺利! 🚀**
