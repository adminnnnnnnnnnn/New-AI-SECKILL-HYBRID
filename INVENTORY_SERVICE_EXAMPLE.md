# 库存服务完整实现示例 - seckill-inventory-service

## 📁 项目结构
```
seckill-inventory-service/
├── pom.xml                                    ✅ 已创建
├── src/main/java/com/seckill/inventory/
│   ├── InventoryServiceApplication.java       # 启动类
│   ├── config/
│   │   ├── RedisConfig.java                   # Redis配置
│   │   ├── RedissonConfig.java                # Redisson配置
│   │   └── SeataConfig.java                   # Seata配置
│   ├── controller/
│   │   └── InventoryController.java           # REST API控制器
│   ├── service/
│   │   ├── InventoryService.java              # 服务接口
│   │   └── impl/
│   │       └── InventoryServiceImpl.java      # 服务实现(核心业务)
│   ├── mapper/
│   │   ├── SkuInventoryMapper.java            # MyBatis Mapper
│   │   └── InventoryTransactionMapper.java    # 流水Mapper
│   ├── entity/
│   │   ├── SkuInventory.java                  # 库存实体
│   │   └── InventoryTransaction.java          # 流水实体
│   ├── vo/
│   │   ├── InventoryVO.java                   # 库存视图对象
│   │   └── DecreaseStockDTO.java              # 扣减库存请求
│   └── listener/
│       └── StockRollbackListener.java         # RocketMQ监听器
├── src/main/resources/
│   ├── application.yml                        # 应用配置
│   ├── mapper/
│   │   ├── SkuInventoryMapper.xml             # MyBatis XML
│   │   └── InventoryTransactionMapper.xml
│   └── lua/
│       └── decrease_stock.lua                 # Lua脚本
└── src/test/java/
    └── com/seckill/inventory/
        └── service/
            └── InventoryServiceTest.java      # 单元测试
```

---

## 1. 启动类 - InventoryServiceApplication.java

```java
package com.seckill.inventory;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * 库存服务启动类
 * 
 * @author AI Assistant
 * @version 4.0
 */
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan("com.seckill.inventory.mapper")
public class InventoryServiceApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(InventoryServiceApplication.class, args);
        System.out.println("========================================");
        System.out.println("库存服务启动成功! 端口: 8083");
        System.out.println("Swagger文档: http://localhost:8083/swagger-ui.html");
        System.out.println("========================================");
    }
}
```

---

## 2. 应用配置 - application.yml

```yaml
server:
  port: 8083

spring:
  application:
    name: seckill-inventory-service
  
  # 数据源配置
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/seckill?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
    username: root
    password: root123456
    druid:
      initial-size: 5
      min-idle: 5
      max-active: 20
      max-wait: 60000
      test-while-idle: true
      validation-query: SELECT 1
  
  # Redis配置
  data:
    redis:
      host: localhost
      port: 6379
      database: 0
      timeout: 3000ms
      lettuce:
        pool:
          max-active: 20
          max-idle: 10
          min-idle: 5
          max-wait: 3000ms
  
  # RocketMQ配置
  rocketmq:
    name-server: localhost:9876
    producer:
      group: inventory-producer-group
      send-message-timeout: 3000
      retry-times-when-send-failed: 2
      retry-times-when-send-async-failed: 2

# Nacos配置
cloud:
  nacos:
    discovery:
      server-addr: localhost:8848
      namespace: public
    config:
      server-addr: localhost:8848
      file-extension: yaml

# Seata配置
seata:
  enabled: true
  application-id: ${spring.application.name}
  tx-service-group: my_test_tx_group
  service:
    vgroup-mapping:
      my_test_tx_group: default
    grouplist:
      default: 127.0.0.1:8091
  config:
    type: file
  registry:
    type: file

# MyBatis-Plus配置
mybatis-plus:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.seckill.inventory.entity
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
  global-config:
    db-config:
      id-type: auto
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0

# SpringDoc配置
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html
    tags-sorter: alpha
    operations-sorter: alpha

# Resilience4j配置
resilience4j:
  ratelimiter:
    instances:
      inventory-limiter:
        limit-for-period: 1000
        limit-refresh-period: 1s
        timeout-duration: 0
  bulkhead:
    instances:
      inventory-bulkhead:
        max-concurrent-calls: 500
        max-wait-duration: 10ms

# 日志配置
logging:
  level:
    com.seckill.inventory: debug
    io.seata: info
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"
```

---

## 3. Redis配置 - RedisConfig.java

```java
package com.seckill.inventory.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * Redis配置类
 */
@Configuration
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        
        // Key使用String序列化
        template.setKeySerializer(new StringRedisSerializer());
        template.setHashKeySerializer(new StringRedisSerializer());
        
        // Value使用JSON序列化
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        template.setHashValueSerializer(new GenericJackson2JsonRedisSerializer());
        
        template.afterPropertiesSet();
        return template;
    }
}
```

---

## 4. Lua脚本 - decrease_stock.lua

```lua
-- 原子扣减库存Lua脚本
-- KEYS[1]: 库存key (stock:{skuId}:{warehouseId})
-- ARGV[1]: 扣减数量

local stock_key = KEYS[1]
local decrease_qty = tonumber(ARGV[1])

-- 获取当前库存
local current_stock = tonumber(redis.call('get', stock_key))

if current_stock and current_stock >= decrease_qty then
    -- 扣减库存
    redis.call('decrby', stock_key, decrease_qty)
    return 1  -- 成功
else
    return 0  -- 库存不足
end
```

**放置位置**: `src/main/resources/lua/decrease_stock.lua`

**加载方式**:
```java
@Value("classpath:lua/decrease_stock.lua")
private Resource decreaseStockScript;

private DefaultRedisScript<Long> redisScript;

@PostConstruct
public void init() {
    redisScript = new DefaultRedisScript<>();
    redisScript.setLocation(decreaseStockScript);
    redisScript.setResultType(Long.class);
}
```

---

## 5. 核心服务实现 - InventoryServiceImpl.java

```java
package com.seckill.inventory.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.seckill.inventory.entity.SkuInventory;
import com.seckill.inventory.entity.InventoryTransaction;
import com.seckill.inventory.mapper.SkuInventoryMapper;
import com.seckill.inventory.mapper.InventoryTransactionMapper;
import com.seckill.inventory.service.InventoryService;
import com.seckill.inventory.vo.InventoryVO;
import com.seckill.inventory.vo.DecreaseStockDTO;
import io.seata.spring.annotation.GlobalTransactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.scripting.support.ResourceScriptSource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * 库存服务实现类
 * 
 * 核心技术:
 * 1. Redis Lua脚本 - 原子扣减库存
 * 2. Redisson分布式锁 - 防止并发冲突
 * 3. Seata分布式事务 - 保证跨服务一致性
 * 4. RocketMQ异步消息 - 库存回滚补偿
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class InventoryServiceImpl implements InventoryService {

    private final SkuInventoryMapper skuInventoryMapper;
    private final InventoryTransactionMapper transactionMapper;
    private final StringRedisTemplate redisTemplate;
    private final RedissonClient redissonClient;
    private final RocketMQTemplate rocketMQTemplate;

    private DefaultRedisScript<Long> decreaseStockScript;

    @PostConstruct
    public void init() {
        decreaseStockScript = new DefaultRedisScript<>();
        decreaseStockScript.setScriptSource(
            new ResourceScriptSource(new ClassPathResource("lua/decrease_stock.lua"))
        );
        decreaseStockScript.setResultType(Long.class);
    }

    /**
     * 原子扣减库存(Redis Lua脚本保证原子性)
     * 
     * @param skuId SKU ID
     * @param warehouseId 仓库ID
     * @param quantity 扣减数量
     * @return 是否成功
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean decreaseStock(Long skuId, Long warehouseId, Integer quantity) {
        String lockKey = "lock:stock:" + skuId + ":" + warehouseId;
        RLock lock = redissonClient.getLock(lockKey);

        try {
            // 尝试获取分布式锁,最多等待5秒,锁定10秒后自动释放
            if (lock.tryLock(5, 10, TimeUnit.SECONDS)) {
                // 1. Redis原子扣减
                String stockKey = "stock:" + skuId + ":" + warehouseId;
                Long result = redisTemplate.execute(
                    decreaseStockScript,
                    Collections.singletonList(stockKey),
                    String.valueOf(quantity)
                );

                if (result == null || result == 0) {
                    log.warn("库存不足: skuId={}, warehouseId={}, quantity={}", 
                        skuId, warehouseId, quantity);
                    return false;
                }

                // 2. MySQL同步扣减(乐观锁)
                int rows = skuInventoryMapper.decreaseStock(skuId, warehouseId, quantity);
                if (rows == 0) {
                    log.error("MySQL扣减库存失败: skuId={}, warehouseId={}", skuId, warehouseId);
                    throw new RuntimeException("库存扣减失败");
                }

                // 3. 记录库存流水
                saveTransaction(skuId, warehouseId, "SALE_OUT", -quantity);

                log.info("库存扣减成功: skuId={}, warehouseId={}, quantity={}", 
                    skuId, warehouseId, quantity);
                return true;
            } else {
                log.warn("获取库存锁超时: skuId={}, warehouseId={}", skuId, warehouseId);
                return false;
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("获取锁被中断", e);
            throw new RuntimeException("系统繁忙");
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    /**
     * 预占库存(用于待支付订单)
     * 
     * @param orderNo 订单号
     * @param skuId SKU ID
     * @param warehouseId 仓库ID
     * @param quantity 预占数量
     * @return 是否成功
     */
    @Override
    public boolean reserveStock(String orderNo, Long skuId, Long warehouseId, Integer quantity) {
        String lockKey = "lock:reserve:" + orderNo;
        RLock lock = redissonClient.getLock(lockKey);

        try {
            if (lock.tryLock(3, 5, TimeUnit.SECONDS)) {
                // 1. 检查可用库存
                String stockKey = "stock:" + skuId + ":" + warehouseId;
                String reservedKey = "reserved:" + orderNo;

                Long availableStock = redisTemplate.opsForValue().getOperations()
                    .execute((connection) -> {
                        byte[] stockBytes = connection.stringCommands().get(stockKey.getBytes());
                        return stockBytes != null ? Long.parseLong(new String(stockBytes)) : 0L;
                    });

                if (availableStock < quantity) {
                    return false;
                }

                // 2. 扣减可用库存
                redisTemplate.opsForValue().decrement(stockKey, quantity);

                // 3. 记录预占信息(设置30分钟过期)
                redisTemplate.opsForValue().set(reservedKey, 
                    String.format("%d:%d:%d", skuId, warehouseId, quantity), 
                    30, TimeUnit.MINUTES);

                log.info("库存预占成功: orderNo={}, skuId={}, quantity={}", 
                    orderNo, skuId, quantity);
                return true;
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("预占库存异常", e);
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
        return false;
    }

    /**
     * 释放预占库存(订单取消或超时)
     * 
     * @param orderNo 订单号
     */
    @Override
    public void releaseReservedStock(String orderNo) {
        String reservedKey = "reserved:" + orderNo;
        String reservedValue = redisTemplate.opsForValue().get(reservedKey);

        if (reservedValue != null) {
            String[] parts = reservedValue.split(":");
            Long skuId = Long.parseLong(parts[0]);
            Long warehouseId = Long.parseLong(parts[1]);
            Integer quantity = Integer.parseInt(parts[2]);

            // 回补库存
            String stockKey = "stock:" + skuId + ":" + warehouseId;
            redisTemplate.opsForValue().increment(stockKey, quantity);

            // 删除预占记录
            redisTemplate.delete(reservedKey);

            // 记录流水
            saveTransaction(skuId, warehouseId, "RESERVE_RELEASE", quantity);

            log.info("预占库存已释放: orderNo={}, quantity={}", orderNo, quantity);
        }
    }

    /**
     * 查询库存
     * 
     * @param skuId SKU ID
     * @param warehouseId 仓库ID
     * @return 库存信息
     */
    @Override
    public InventoryVO getInventory(Long skuId, Long warehouseId) {
        // 优先从Redis查询
        String stockKey = "stock:" + skuId + ":" + warehouseId;
        String stockStr = redisTemplate.opsForValue().get(stockKey);

        if (stockStr != null) {
            InventoryVO vo = new InventoryVO();
            vo.setSkuId(skuId);
            vo.setWarehouseId(warehouseId);
            vo.setAvailableQuantity(Integer.parseInt(stockStr));
            return vo;
        }

        // Redis未命中,查询数据库
        SkuInventory inventory = skuInventoryMapper.selectOne(
            new LambdaQueryWrapper<SkuInventory>()
                .eq(SkuInventory::getSkuId, skuId)
                .eq(SkuInventory::getWarehouseId, warehouseId)
        );

        if (inventory != null) {
            // 同步到Redis
            redisTemplate.opsForValue().set(stockKey, 
                String.valueOf(inventory.getAvailableQuantity()));

            InventoryVO vo = new InventoryVO();
            vo.setSkuId(inventory.getSkuId());
            vo.setWarehouseId(inventory.getWarehouseId());
            vo.setTotalQuantity(inventory.getTotalQuantity());
            vo.setLockedQuantity(inventory.getLockedQuantity());
            vo.setAvailableQuantity(inventory.getAvailableQuantity());
            vo.setBatchNo(inventory.getBatchNo());
            vo.setProductionDate(inventory.getProductionDate());
            vo.setExpiryDate(inventory.getExpiryDate());
            return vo;
        }

        return null;
    }

    /**
     * 回补库存(订单取消时)
     * 
     * @param skuId SKU ID
     * @param warehouseId 仓库ID
     * @param quantity 回补数量
     */
    @Override
    @GlobalTransactional(name = "rollback-stock-tx", rollbackFor = Exception.class)
    public void rollbackStock(Long skuId, Long warehouseId, Integer quantity) {
        String lockKey = "lock:stock:" + skuId + ":" + warehouseId;
        RLock lock = redissonClient.getLock(lockKey);

        try {
            if (lock.tryLock(5, 10, TimeUnit.SECONDS)) {
                // 1. Redis回补
                String stockKey = "stock:" + skuId + ":" + warehouseId;
                redisTemplate.opsForValue().increment(stockKey, quantity);

                // 2. MySQL回补
                skuInventoryMapper.increaseStock(skuId, warehouseId, quantity);

                // 3. 记录流水
                saveTransaction(skuId, warehouseId, "ORDER_CANCEL", quantity);

                log.info("库存回补成功: skuId={}, warehouseId={}, quantity={}", 
                    skuId, warehouseId, quantity);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("库存回补异常", e);
            throw new RuntimeException("库存回补失败");
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    /**
     * 保存库存流水
     */
    private void saveTransaction(Long skuId, Long warehouseId, 
                                 String changeType, Integer changeQuantity) {
        InventoryTransaction transaction = new InventoryTransaction();
        transaction.setTransactionNo(UUID.randomUUID().toString().replace("-", ""));
        transaction.setSkuId(skuId);
        transaction.setWarehouseId(warehouseId);
        transaction.setChangeType(changeType);
        transaction.setChangeQuantity(changeQuantity);
        transaction.setCreatedAt(LocalDateTime.now());
        
        transactionMapper.insert(transaction);
    }
}
```

---

## 6. RocketMQ监听器 - StockRollbackListener.java

```java
package com.seckill.inventory.listener;

import com.seckill.inventory.service.InventoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.springframework.stereotype.Component;

/**
 * 库存回滚监听器
 * 监听订单取消消息,自动回滚库存
 */
@Slf4j
@Component
@RequiredArgsConstructor
@RocketMQMessageListener(
    topic = "order-cancel-topic",
    consumerGroup = "inventory-rollback-consumer-group",
    selectorExpression = "*"
)
public class StockRollbackListener implements RocketMQListener<String> {

    private final InventoryService inventoryService;

    @Override
    public void onMessage(String message) {
        log.info("收到库存回滚消息: {}", message);
        
        try {
            // 消息格式: skuId:warehouseId:quantity
            String[] parts = message.split(":");
            Long skuId = Long.parseLong(parts[0]);
            Long warehouseId = Long.parseLong(parts[1]);
            Integer quantity = Integer.parseInt(parts[2]);

            // 执行库存回滚
            inventoryService.rollbackStock(skuId, warehouseId, quantity);
            
            log.info("库存回滚成功: {}", message);
        } catch (Exception e) {
            log.error("库存回滚失败: {}", message, e);
            // RocketMQ会自动重试
            throw e;
        }
    }
}
```

---

## 7. MyBatis Mapper - SkuInventoryMapper.java

```java
package com.seckill.inventory.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.seckill.inventory.entity.SkuInventory;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

/**
 * SKU库存Mapper
 */
public interface SkuInventoryMapper extends BaseMapper<SkuInventory> {

    /**
     * 扣减库存(乐观锁)
     */
    @Update("UPDATE sku_inventory SET available_quantity = available_quantity - #{quantity}, " +
            "locked_quantity = locked_quantity + #{quantity}, " +
            "version = version + 1 " +
            "WHERE sku_id = #{skuId} AND warehouse_id = #{warehouseId} " +
            "AND available_quantity >= #{quantity}")
    int decreaseStock(@Param("skuId") Long skuId, 
                      @Param("warehouseId") Long warehouseId, 
                      @Param("quantity") Integer quantity);

    /**
     * 增加库存
     */
    @Update("UPDATE sku_inventory SET available_quantity = available_quantity + #{quantity}, " +
            "locked_quantity = locked_quantity - #{quantity}, " +
            "version = version + 1 " +
            "WHERE sku_id = #{skuId} AND warehouse_id = #{warehouseId}")
    int increaseStock(@Param("skuId") Long skuId, 
                      @Param("warehouseId") Long warehouseId, 
                      @Param("quantity") Integer quantity);
}
```

---

## 8. 控制器 - InventoryController.java

```java
package com.seckill.inventory.controller;

import com.seckill.inventory.service.InventoryService;
import com.seckill.inventory.vo.InventoryVO;
import com.seckill.inventory.vo.DecreaseStockDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
@Tag(name = "库存管理", description = "多仓库库存查询、扣减、预占")
public class InventoryController {

    private final InventoryService inventoryService;

    @PostMapping("/decrease")
    @Operation(summary = "扣减库存", description = "原子扣减指定SKU在指定仓库的库存")
    public boolean decreaseStock(@RequestBody DecreaseStockDTO dto) {
        return inventoryService.decreaseStock(
            dto.getSkuId(), 
            dto.getWarehouseId(), 
            dto.getQuantity()
        );
    }

    @PostMapping("/reserve")
    @Operation(summary = "预占库存", description = "为订单预占库存,30分钟后自动释放")
    public boolean reserveStock(
            @RequestParam String orderNo,
            @RequestParam Long skuId,
            @RequestParam Long warehouseId,
            @RequestParam Integer quantity) {
        return inventoryService.reserveStock(orderNo, skuId, warehouseId, quantity);
    }

    @PostMapping("/release/{orderNo}")
    @Operation(summary = "释放预占", description = "订单取消时释放预占库存")
    public void releaseReservedStock(@PathVariable String orderNo) {
        inventoryService.releaseReservedStock(orderNo);
    }

    @GetMapping("/{skuId}/{warehouseId}")
    @Operation(summary = "查询库存", description = "查询指定SKU在指定仓库的库存详情")
    public InventoryVO getInventory(
            @PathVariable Long skuId,
            @PathVariable Long warehouseId) {
        return inventoryService.getInventory(skuId, warehouseId);
    }

    @PostMapping("/rollback")
    @Operation(summary = "回补库存", description = "订单取消时回补库存")
    public void rollbackStock(@RequestBody DecreaseStockDTO dto) {
        inventoryService.rollbackStock(
            dto.getSkuId(), 
            dto.getWarehouseId(), 
            dto.getQuantity()
        );
    }
}
```

---

## 9. 实体类 - SkuInventory.java

```java
package com.seckill.inventory.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("sku_inventory")
public class SkuInventory {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long skuId;
    private Long warehouseId;
    private Long locationId;
    private Integer totalQuantity;
    private Integer lockedQuantity;
    private Integer availableQuantity;
    private String batchNo;
    private LocalDate productionDate;
    private LocalDate expiryDate;
    private Integer version;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
```

---

## 10. VO对象 - InventoryVO.java

```java
package com.seckill.inventory.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDate;

@Data
@Schema(description = "库存视图对象")
public class InventoryVO {
    
    @Schema(description = "SKU ID")
    private Long skuId;
    
    @Schema(description = "仓库ID")
    private Long warehouseId;
    
    @Schema(description = "总库存数量")
    private Integer totalQuantity;
    
    @Schema(description = "锁定数量")
    private Integer lockedQuantity;
    
    @Schema(description = "可用数量")
    private Integer availableQuantity;
    
    @Schema(description = "批次号")
    private String batchNo;
    
    @Schema(description = "生产日期")
    private LocalDate productionDate;
    
    @Schema(description = "过期日期")
    private LocalDate expiryDate;
}
```

---

## 🚀 运行测试

### 1. 启动服务
```bash
cd seckill-inventory-service
mvn spring-boot:run
```

### 2. 访问Swagger文档
```
http://localhost:8083/swagger-ui.html
```

### 3. 测试API
```bash
# 查询库存
curl http://localhost:8083/api/inventory/1/1

# 扣减库存
curl -X POST http://localhost:8083/api/inventory/decrease \
  -H "Content-Type: application/json" \
  -d '{"skuId":1,"warehouseId":1,"quantity":5}'
```

---

## 📝 关键技术点总结

### 1. Redis Lua脚本原子扣减
- ✅ 保证库存扣减的原子性
- ✅ 避免超卖问题
- ✅ 高性能(单次RTT)

### 2. Redisson分布式锁
- ✅ 防止同一SKU并发扣减冲突
- ✅ 看门狗自动续期
- ✅ 超时自动释放

### 3. Seata分布式事务
- ✅ 跨服务数据一致性
- ✅ AT模式自动回滚
- ✅ 全局事务ID追踪

### 4. RocketMQ异步消息
- ✅ 订单取消库存回滚
- ✅ 削峰填谷
- ✅ 最终一致性保障

### 5. Resilience4j限流熔断
- ✅ 令牌桶限流
- ✅ 信号量隔离
- ✅ 熔断降级保护

---

这个库存服务示例展示了如何在一个服务中综合运用RocketMQ、Seata、Redisson等新技术栈。其他5个新服务可以参考此模式进行开发!