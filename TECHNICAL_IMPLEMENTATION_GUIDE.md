# 🎯 供应链集中筹措管理系统 v4.0 - 技术实现指南

**创建日期**: 2026-05-20  
**版本**: v4.0  
**状态**: ✅ 基础架构100%完成 + Controller模板已就绪

---

## ✅ 当前完成情况

### 1. 基础设施 (100%)
- ✅ MySQL数据库Schema (30+张表)
- ✅ Redis缓存配置
- ✅ RocketMQ消息队列 (NameServer + Broker + Console)
- ✅ Seata分布式事务服务器
- ✅ Nacos服务注册与配置中心

### 2. Maven依赖 (100%)
- ✅ Spring Boot 3.2.3
- ✅ Spring Cloud Alibaba 2023.0.1.0
- ✅ RocketMQ Starter 2.3.0
- ✅ Seata Starter 2.0.0
- ✅ Redisson 3.27.0
- ✅ Resilience4j 2.1.0

### 3. 微服务骨架 (100%)

| 服务 | 端口 | pom.xml | 启动类 | application.yml | Controller |
|------|------|---------|--------|-----------------|------------|
| seckill-inventory-service | 8083 | ✅ | ✅ | ✅ | ⏳ 参考示例 |
| seckill-material-service | 8087 | ✅ | ✅ | ✅ | ✅ MaterialController |
| seckill-warehouse-service | 8088 | ✅ | ✅ | ✅ | ✅ WarehouseController |
| seckill-delivery-service | 8089 | ✅ | ✅ | ✅ | ✅ DeliveryController |
| seckill-supplier-service | 8090 | ✅ | ✅ | ✅ | ✅ SupplierController |
| seckill-inspect-service | 8086 | ✅ | ✅ | ✅ | ✅ InspectController |

---

## 📋 下一步实施步骤

### Step 1: 实现Service层业务逻辑 (优先级最高)

#### 库存服务 (seckill-inventory-service)
**参考文件**: [INVENTORY_SERVICE_EXAMPLE.md](file://c:\Users\dell\Desktop\ai-seckill-hybrid\INVENTORY_SERVICE_EXAMPLE.md)

核心功能:
```java
@Service
public class InventoryServiceImpl implements InventoryService {
    
    @Autowired
    private StringRedisTemplate redisTemplate;
    
    @Autowired
    private RedissonClient redissonClient;
    
    /**
     * 秒杀库存扣减 - 使用Redis Lua脚本原子操作
     */
    @Override
    public boolean decreaseSeckillStock(Long sessionId, Long skuId, Integer quantity) {
        String stockKey = "stock:seckill:" + sessionId + ":" + skuId;
        
        // 执行Lua脚本原子扣减
        String luaScript = 
            "local stock = tonumber(redis.call('get', KEYS[1])) " +
            "if stock and stock >= ARGV[1] then " +
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
    
    /**
     * 预占库存 - 使用Redisson分布式锁
     */
    @Override
    @Transactional
    public String preOccupyStock(Long userId, Long skuId, Integer quantity) {
        RLock lock = redissonClient.getLock("lock:stock:" + userId + ":" + skuId);
        
        try {
            if (lock.tryLock(5, 10, TimeUnit.SECONDS)) {
                // 检查库存
                // 扣减库存
                // 创建预占记录
                return "PRE" + System.currentTimeMillis();
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            lock.unlock();
        }
        return null;
    }
}
```

#### 物资服务 (seckill-material-service)
**核心功能**:
```java
@Service
@RequiredArgsConstructor
public class MaterialServiceImpl implements MaterialService {
    
    private final PurchasePlanMapper purchasePlanMapper;
    private final InboundOrderMapper inboundOrderMapper;
    private final OutboundOrderMapper outboundOrderMapper;
    private final TransferOrderMapper transferOrderMapper;
    private final RocketMQTemplate rocketMQTemplate;
    
    @GlobalTransactional(name = "create-purchase-plan-tx")
    @Override
    public String createPurchasePlan(Long applicantId, List<PurchasePlanItemDTO> items) {
        // 1. 创建采购计划主表
        PurchasePlan plan = new PurchasePlan();
        plan.setPlanNo("PP" + System.currentTimeMillis());
        plan.setApplicantId(applicantId);
        plan.setStatus("DRAFT");
        purchasePlanMapper.insert(plan);
        
        // 2. 创建采购计划明细
        for (PurchasePlanItemDTO item : items) {
            PurchasePlanItem planItem = new PurchasePlanItem();
            planItem.setPlanNo(plan.getPlanNo());
            planItem.setMaterialId(item.getMaterialId());
            planItem.setQuantity(item.getQuantity());
            // ... 设置其他字段
            purchasePlanItemMapper.insert(planItem);
        }
        
        // 3. 发送MQ消息通知审批人
        rocketMQTemplate.convertAndSend("purchase-plan-topic", plan.getPlanNo());
        
        return plan.getPlanNo();
    }
    
    @Override
    public void approvePurchasePlan(String planNo, Long approverId, boolean approved, String remark) {
        // 1. 更新采购计划状态
        PurchasePlan plan = purchasePlanMapper.selectByPlanNo(planNo);
        plan.setStatus(approved ? "APPROVED" : "REJECTED");
        plan.setApproverId(approverId);
        plan.setApproveRemark(remark);
        purchasePlanMapper.updateById(plan);
        
        // 2. 如果审批通过,生成采购单
        if (approved) {
            // 调用供应商服务生成采购单
        }
    }
}
```

#### 配送服务 (seckill-delivery-service)
**核心功能**:
```java
@Service
@RequiredArgsConstructor
public class DeliveryServiceImpl implements DeliveryService {
    
    private final DeliveryOrderMapper deliveryOrderMapper;
    private final DeliveryTrajectoryMapper trajectoryMapper;
    private final RocketMQTemplate rocketMQTemplate;
    
    @Override
    public String createDeliveryOrder(DeliveryOrderCreateDTO dto) {
        // 1. 创建配送单
        DeliveryOrder order = new DeliveryOrder();
        order.setDeliveryNo("DO" + System.currentTimeMillis());
        order.setOrderNo(dto.getOrderNo());
        order.setStatus(0); // 待接单
        deliveryOrderMapper.insert(order);
        
        // 2. 发送MQ消息通知供应商接单
        rocketMQTemplate.convertAndSend("delivery-order-topic", order.getDeliveryNo());
        
        return order.getDeliveryNo();
    }
    
    @Override
    public void updateDeliveryStatus(String deliveryNo, Integer status, String remark) {
        // 1. 更新配送单状态
        DeliveryOrder order = deliveryOrderMapper.selectByDeliveryNo(deliveryNo);
        order.setStatus(status);
        deliveryOrderMapper.updateById(order);
        
        // 2. 记录物流轨迹
        DeliveryTrajectory trajectory = new DeliveryTrajectory();
        trajectory.setDeliveryNo(deliveryNo);
        trajectory.setStatus(status);
        trajectory.setStatusName(getStatusName(status));
        trajectory.setRemark(remark);
        trajectory.setCreateTime(LocalDateTime.now());
        trajectoryMapper.insert(trajectory);
        
        // 3. 发送MQ消息通知前端实时更新
        Map<String, Object> message = new HashMap<>();
        message.put("deliveryNo", deliveryNo);
        message.put("status", status);
        message.put("trajectory", trajectory);
        rocketMQTemplate.convertAndSend("delivery-status-topic", message);
    }
}
```

#### 供应商服务 (seckill-supplier-service)
**核心功能**:
```java
@Service
@RequiredArgsConstructor
public class SupplierServiceImpl implements SupplierService {
    
    private final SupplierMapper supplierMapper;
    private final SupplierQualificationMapper qualificationMapper;
    private final SupplierEvaluationMapper evaluationMapper;
    
    @Override
    public String registerSupplier(SupplierRegisterDTO dto) {
        // 1. 创建供应商档案
        Supplier supplier = new Supplier();
        supplier.setSupplierCode("SUP" + System.currentTimeMillis());
        supplier.setName(dto.getName());
        supplier.setCreditCode(dto.getCreditCode());
        supplier.setStatus("PENDING_AUDIT");
        supplierMapper.insert(supplier);
        
        // 2. 保存资质材料
        for (QualificationDTO qual : dto.getQualifications()) {
            SupplierQualification qualification = new SupplierQualification();
            qualification.setSupplierCode(supplier.getSupplierCode());
            qualification.setType(qual.getType());
            qualification.setFileUrl(qual.getFileUrl());
            qualificationMapper.insert(qualification);
        }
        
        // 3. 自动核验营业执照和食品许可证
        autoVerifyQualifications(supplier.getSupplierCode());
        
        return supplier.getSupplierCode();
    }
    
    @Override
    public void evaluateSupplier(String supplierCode, SupplierEvaluationDTO evaluation) {
        // 1. 保存评价记录
        SupplierEvaluation eval = new SupplierEvaluation();
        eval.setSupplierCode(supplierCode);
        eval.setQualityScore(evaluation.getQualityScore());
        eval.setDeliveryScore(evaluation.getDeliveryScore());
        eval.setServiceScore(evaluation.getServiceScore());
        eval.setComplianceScore(evaluation.getComplianceScore());
        
        // 2. 计算综合评分
        double totalScore = eval.getQualityScore() * 0.4 
                          + eval.getDeliveryScore() * 0.3
                          + eval.getServiceScore() * 0.2
                          + eval.getComplianceScore() * 0.1;
        eval.setTotalScore(totalScore);
        
        // 3. 自动评级
        String rating = calculateRating(totalScore);
        eval.setRating(rating);
        
        evaluationMapper.insert(eval);
        
        // 4. 更新供应商综合评级
        updateSupplierRating(supplierCode, totalScore, rating);
    }
    
    private String calculateRating(double score) {
        if (score >= 90) return "A";
        if (score >= 75) return "B";
        if (score >= 60) return "C";
        return "D";
    }
}
```

#### 验收服务 (seckill-inspect-service)
**核心功能**:
```java
@Service
@RequiredArgsConstructor
public class InspectServiceImpl implements InspectService {
    
    private final InspectTaskMapper taskMapper;
    private final InspectRecordMapper recordMapper;
    private final TraceInfoMapper traceMapper;
    private final RocketMQTemplate rocketMQTemplate;
    
    @Override
    public void completeInspection(String taskNo, InspectionCompleteDTO dto) {
        // 1. 更新验收任务状态
        InspectTask task = taskMapper.selectByTaskNo(taskNo);
        task.setStatus("COMPLETED");
        task.setResult(dto.getResult()); // PASS/REJECT/DOWNGRADE
        taskMapper.updateById(task);
        
        // 2. 保存验收记录
        InspectRecord record = new InspectRecord();
        record.setTaskNo(taskNo);
        record.setInspectorId(dto.getInspectorId());
        record.setResult(dto.getResult());
        record.setImages(dto.getImages()); // 照片URL列表
        record.setRemark(dto.getRemark());
        recordMapper.insert(record);
        
        // 3. 如果合格,更新追溯信息
        if ("PASS".equals(dto.getResult())) {
            updateTraceInfo(task.getOrderNo(), dto.getBatchNo());
        } else {
            // 如果拒收,通知供应商生成售后单
            rocketMQTemplate.convertAndSend("inspection-reject-topic", taskNo);
        }
    }
    
    @Override
    public Object getTraceInfo(String batchNo) {
        // 查询完整追溯链路
        List<TraceNode> nodes = traceMapper.selectByBatchNo(batchNo);
        
        // 组装追溯信息
        TraceInfoVO vo = new TraceInfoVO();
        vo.setBatchNo(batchNo);
        vo.setNodes(nodes);
        vo.setQrCodeUrl(generateQRCodeUrl(batchNo));
        
        return vo;
    }
}
```

#### 仓储服务 (seckill-warehouse-service)
**核心功能**:
```java
@Service
@RequiredArgsConstructor
public class WarehouseServiceImpl implements WarehouseService {
    
    private final WarehouseMapper warehouseMapper;
    private final LocationMapper locationMapper;
    private final CheckTaskMapper checkTaskMapper;
    private final InventoryMapper inventoryMapper;
    
    @Override
    public String createCheckTask(CheckTaskCreateDTO dto) {
        // 1. 创建盘点任务
        CheckTask task = new CheckTask();
        task.setCheckNo("CHK" + System.currentTimeMillis());
        task.setWarehouseId(dto.getWarehouseId());
        task.setType(dto.getType()); // FULL/PARTIAL/MOVEMENT
        task.setStatus("IN_PROGRESS");
        checkTaskMapper.insert(task);
        
        // 2. 生成盘点明细(根据盘点类型)
        List<Inventory> inventories;
        if ("FULL".equals(dto.getType())) {
            // 全盘: 查询仓库所有库存
            inventories = inventoryMapper.selectByWarehouseId(dto.getWarehouseId());
        } else if ("PARTIAL".equals(dto.getType())) {
            // 抽盘: 查询重点物资
            inventories = inventoryMapper.selectKeyMaterials(dto.getWarehouseId());
        } else {
            // 动碰盘点: 查询有出入库记录的物资
            inventories = inventoryMapper.selectMovementMaterials(dto.getWarehouseId());
        }
        
        for (Inventory inv : inventories) {
            CheckItem item = new CheckItem();
            item.setCheckNo(task.getCheckNo());
            item.setMaterialId(inv.getMaterialId());
            item.setLocationId(inv.getLocationId());
            item.setBookQuantity(inv.getQuantity()); // 账面数量
            item.setActualQuantity(null); // 实盘数量待录入
            checkItemMapper.insert(item);
        }
        
        return task.getCheckNo();
    }
    
    @Override
    public void submitCheckResult(String checkNo, List<CheckItemResultDTO> results) {
        // 1. 更新盘点明细的实盘数量
        for (CheckItemResultDTO result : results) {
            CheckItem item = checkItemMapper.selectByCheckNoAndMaterial(checkNo, result.getMaterialId());
            item.setActualQuantity(result.getActualQuantity());
            item.setDifference(result.getActualQuantity() - item.getBookQuantity());
            checkItemMapper.updateById(item);
        }
        
        // 2. 生成盘点差异单
        CheckTask task = checkTaskMapper.selectByCheckNo(checkNo);
        task.setStatus("PENDING_APPROVE");
        checkTaskMapper.updateById(task);
    }
    
    @Override
    public void approveCheckDifference(String checkNo, Long approverId, boolean approved) {
        if (!approved) {
            return;
        }
        
        // 1. 查询所有差异项
        List<CheckItem> items = checkItemMapper.selectByCheckNo(checkNo);
        
        // 2. 处理盘盈盘亏
        for (CheckItem item : items) {
            if (item.getDifference() != 0) {
                // 更新库存
                Inventory inventory = inventoryMapper.selectByMaterialAndLocation(
                    item.getMaterialId(), item.getLocationId()
                );
                inventory.setQuantity(inventory.getQuantity() + item.getDifference());
                inventoryMapper.updateById(inventory);
                
                // 记录盘盈盘亏流水
                InventoryTransaction transaction = new InventoryTransaction();
                transaction.setType(item.getDifference() > 0 ? "SURPLUS" : "LOSS");
                transaction.setQuantity(Math.abs(item.getDifference()));
                transaction.setReason("盘点差异");
                inventoryTransactionMapper.insert(transaction);
            }
        }
        
        // 3. 更新盘点任务状态
        CheckTask task = checkTaskMapper.selectByCheckNo(checkNo);
        task.setStatus("COMPLETED");
        checkTaskMapper.updateById(task);
    }
}
```

---

## 🔑 关键技术点说明

### 1. RocketMQ延时消息使用场景

| 场景 | Topic | 延时时间 | 用途 |
|------|-------|----------|------|
| 订单超时取消 | order-timeout-topic | 30分钟 | 自动取消未支付订单,回滚库存 |
| 库存预警通知 | inventory-alert-topic | 立即 | 库存低于阈值时通知采购员 |
| 配送状态更新 | delivery-status-topic | 立即 | 实时推送配送状态给前端 |
| 验收拒收通知 | inspection-reject-topic | 立即 | 通知供应商生成售后单 |
| 供应商绩效计算 | supplier-performance-topic | 每月1号 | 自动生成月度绩效报告 |

**代码示例**:
```java
// 发送延时消息
rocketMQTemplate.syncSendDelayTimeMills(
    "order-timeout-topic",
    orderNo,
    30 * 60 * 1000  // 30分钟
);

// 监听延时消息
@Component
@RocketMQMessageListener(
    topic = "order-timeout-topic",
    consumerGroup = "order-timeout-consumer-group"
)
public class OrderTimeoutListener implements RocketMQListener<String> {
    @Override
    public void onMessage(String orderNo) {
        // 检查订单是否已支付
        Order order = orderMapper.selectByOrderNo(orderNo);
        if ("PENDING_PAYMENT".equals(order.getStatus())) {
            // 取消订单,回滚库存
            orderService.cancelOrder(orderNo, "超时未支付");
        }
    }
}
```

### 2. Seata分布式事务使用场景

| 场景 | 涉及服务 | 事务名称 |
|------|----------|----------|
| 订单创建 | order + inventory + delivery | create-order-tx |
| 采购入库 | material + inspect + warehouse | purchase-inbound-tx |
| 调拨出库 | warehouse (from) + warehouse (to) | transfer-stock-tx |
| 供应商入驻 | supplier + user | supplier-register-tx |

**代码示例**:
```java
@Service
public class OrderServiceImpl implements OrderService {
    
    @Autowired
    private InventoryFeignClient inventoryFeignClient;
    
    @Autowired
    private DeliveryFeignClient deliveryFeignClient;
    
    @GlobalTransactional(name = "create-order-tx", rollbackFor = Exception.class)
    @Override
    public String createOrder(OrderCreateDTO dto) {
        // 1. 创建订单(本地事务)
        Order order = new Order();
        order.setOrderNo("DD" + System.currentTimeMillis());
        order.setUserId(dto.getUserId());
        orderMapper.insert(order);
        
        // 2. 扣减库存(远程调用,自动纳入全局事务)
        inventoryFeignClient.decreaseStock(
            dto.getSkuId(), 
            dto.getQuantity()
        );
        
        // 3. 创建配送单(远程调用,自动纳入全局事务)
        deliveryFeignClient.createDeliveryOrder(
            order.getOrderNo(),
            dto.getAddress()
        );
        
        // 如果任何一步失败,全部回滚
        return order.getOrderNo();
    }
}
```

### 3. Redisson分布式锁使用场景

| 场景 | Lock Key | 超时时间 | 用途 |
|------|----------|----------|------|
| 秒杀抢购 | lock:seckill:{userId}:{sessionId} | 10秒 | 防止同一用户重复抢购 |
| 库存扣减 | lock:stock:{skuId} | 5秒 | 防止并发扣减导致超卖 |
| 订单创建 | lock:order:{userId} | 3秒 | 防止同一用户重复下单 |
| 盘点任务 | lock:check:{warehouseId} | 30秒 | 防止同一仓库同时盘点 |

**代码示例**:
```java
@Service
public class SeckillServiceImpl implements SeckillService {
    
    @Autowired
    private RedissonClient redissonClient;
    
    @Override
    public String seckill(Long userId, Long sessionId, Long skuId) {
        // 获取分布式锁
        String lockKey = "lock:seckill:" + userId + ":" + sessionId;
        RLock lock = redissonClient.getLock(lockKey);
        
        try {
            // 尝试加锁,最多等待5秒,锁定10秒后自动释放
            if (lock.tryLock(5, 10, TimeUnit.SECONDS)) {
                // 1. 检查是否已抢购过
                if (hasSeckilled(userId, sessionId)) {
                    throw new BusinessException("您已抢购过该商品");
                }
                
                // 2. 扣减库存(Lua脚本)
                if (!decreaseStock(sessionId, skuId)) {
                    throw new BusinessException("库存不足");
                }
                
                // 3. 创建订单
                String orderNo = createOrder(userId, sessionId, skuId);
                
                return orderNo;
            } else {
                throw new BusinessException("系统繁忙,请稍后重试");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new BusinessException("系统异常");
        } finally {
            // 释放锁
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }
}
```

### 4. Redis Lua脚本原子操作

**库存扣减脚本** (`decrease_stock.lua`):
```lua
-- KEYS[1]: 库存key
-- ARGV[1]: 扣减数量
local stock = tonumber(redis.call('get', KEYS[1]))
if stock and stock >= tonumber(ARGV[1]) then
    redis.call('decrby', KEYS[1], ARGV[1])
    return 1  -- 成功
end
return 0  -- 失败
```

**Java调用**:
```java
String luaScript = loadLuaScript("decrease_stock.lua");
Long result = redisTemplate.execute(
    new DefaultRedisScript<>(luaScript, Long.class),
    Collections.singletonList(stockKey),
    quantity.toString()
);

if (result == 1) {
    // 扣减成功
} else {
    // 库存不足
}
```

---

## 📊 性能优化建议

### 1. 数据库索引优化
```sql
-- 订单表索引
CREATE INDEX idx_order_user ON `order`(user_id, create_time DESC);
CREATE INDEX idx_order_status ON `order`(status, create_time DESC);

-- 库存表索引
CREATE INDEX idx_inventory_warehouse ON inventory(warehouse_id, material_id);
CREATE INDEX idx_inventory_material ON inventory(material_id, location_id);

-- 配送表索引
CREATE INDEX idx_delivery_status ON delivery_order(status, create_time DESC);
CREATE INDEX idx_delivery_order ON delivery_order(order_no);
```

### 2. Redis缓存策略
```java
// 热点数据缓存
@Cacheable(value = "product", key = "#skuId", unless = "#result == null")
public ProductSku getProductSku(Long skuId) {
    return productSkuMapper.selectById(skuId);
}

// 库存预热(秒杀开始前5分钟)
@Scheduled(cron = "0 */5 * * * ?")
public void preheatSeckillStock() {
    List<SeckillSession> sessions = seckillSessionMapper.selectUpcomingSessions();
    for (SeckillSession session : sessions) {
        String stockKey = "stock:seckill:" + session.getId() + ":" + session.getSkuId();
        redisTemplate.opsForValue().set(stockKey, session.getStock());
    }
}
```

### 3. 限流配置 (Resilience4j)
```yaml
resilience4j:
  ratelimiter:
    instances:
      seckill-api:
        limit-for-period: 5          # 每秒允许5次请求
        limit-refresh-period: 1s     # 刷新周期1秒
        timeout-duration: 0          # 不等待,直接拒绝
      
      common-api:
        limit-for-period: 100
        limit-refresh-period: 1s
        timeout-duration: 1s
```

---

## 🧪 测试建议

### 1. 单元测试
```java
@SpringBootTest
class InventoryServiceTest {
    
    @Autowired
    private InventoryService inventoryService;
    
    @Test
    void testDecreaseSeckillStock() {
        // 准备测试数据
        Long sessionId = 1L;
        Long skuId = 100L;
        Integer quantity = 1;
        
        // 执行扣减
        boolean result = inventoryService.decreaseSeckillStock(sessionId, skuId, quantity);
        
        // 验证结果
        assertTrue(result);
        
        // 验证Redis库存
        String stockKey = "stock:seckill:" + sessionId + ":" + skuId;
        Integer remainingStock = redisTemplate.opsForValue().get(stockKey);
        assertEquals(99, remainingStock);
    }
}
```

### 2. 压力测试 (JMeter)
```
测试场景: 秒杀抢购
并发用户: 5000
持续时间: 5分钟
预期指标:
  - QPS ≥ 5000
  - P99响应时间 ≤ 200ms
  - 超卖率 = 0%
  - 成功率 ≥ 99.9%
```

---

## 📝 开发规范

### 1. 命名规范
- 实体类: `PascalCase` (如: `PurchasePlan`, `DeliveryOrder`)
- 方法名: `camelCase` (如: `createPurchasePlan`, `updateDeliveryStatus`)
- 常量: `UPPER_SNAKE_CASE` (如: `ORDER_STATUS_PENDING`)
- 数据库表: `snake_case` (如: `purchase_plan`, `delivery_order`)

### 2. 注释规范
```java
/**
 * 创建采购计划
 * 
 * @param applicantId 申请人ID
 * @param items 采购明细列表
 * @return 采购计划编号
 * @throws BusinessException 当参数无效时抛出
 */
String createPurchasePlan(Long applicantId, List<PurchasePlanItemDTO> items);
```

### 3. 异常处理
```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<Result> handleBusinessException(BusinessException e) {
        return ResponseEntity.ok(Result.error(e.getCode(), e.getMessage()));
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Result> handleException(Exception e) {
        log.error("系统异常", e);
        return ResponseEntity.ok(Result.error(500, "系统异常"));
    }
}
```

---

## 🚀 部署建议

### Docker Compose生产环境配置
```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
    volumes:
      - /data/mysql:/var/lib/mysql
  
  redis:
    image: redis:7-alpine
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G
  
  rocketmq-broker:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
  
  seckill-inventory-service:
    deploy:
      replicas: 3  # 3个实例
      resources:
        limits:
          cpus: '1'
          memory: 2G
```

---

## 📞 技术支持

如有问题,请参考以下文档:
- [INVENTORY_SERVICE_EXAMPLE.md](file://c:\Users\dell\Desktop\ai-seckill-hybrid\INVENTORY_SERVICE_EXAMPLE.md) - 完整代码示例
- [REFACTORING_GUIDE.md](file://c:\Users\dell\Desktop\ai-seckill-hybrid\REFACTORING_GUIDE.md) - 重构实施指南
- [QUICK_REFERENCE.md](file://c:\Users\dell\Desktop\ai-seckill-hybrid\QUICK_REFERENCE.md) - 快速参考卡

**祝您开发顺利! 🎉**
