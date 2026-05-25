# 供应链集中筹措管理系统 - 重构实施指南 v4.0

## 📋 目录
1. [重构概述](#重构概述)
2. [技术架构升级](#技术架构升级)
3. [数据库迁移](#数据库迁移)
4. [微服务模块创建](#微服务模块创建)
5. [RocketMQ集成](#rocketmq集成)
6. [Seata分布式事务](#seata分布式事务)
7. [Redis增强使用](#redis增强使用)
8. [前端适配](#前端适配)
9. [部署配置](#部署配置)
10. [测试验证](#测试验证)

---

## 重构概述

### 目标
将现有AI-SECKILL-HYBRID秒杀系统升级为完整的**供应链集中筹措管理系统**,新增:
- ✅ 物资管理(采购计划、出入库、调拨)
- ✅ 仓储服务(多仓库、库位管理、盘点)
- ✅ 配送追踪(物流轨迹、状态实时更新)
- ✅ 供应商管理(资质审核、绩效评价)
- ✅ 验收服务(质检、批次追溯)

### 核心技术栈扩展
| 技术 | 版本 | 用途 |
|------|------|------|
| RocketMQ | 5.0+ | 订单异步处理、延时消息、事务消息 |
| Seata | 2.0.0 | 分布式事务(AT模式) |
| Redisson | 3.27.0 | 分布式锁、防重复提交 |
| Resilience4j | 2.1.0 | 限流熔断、降级保护 |

---

## 技术架构升级

### 1. 父POM更新
已在`seckill-parent/pom.xml`中添加以下依赖管理:
```xml
<!-- RocketMQ -->
<rocketmq-spring.version>2.3.0</rocketmq-spring.version>

<!-- Seata -->
<seata.version>2.0.0</seata.version>

<!-- Redisson -->
<redisson.version>3.27.0</redisson.version>

<!-- Resilience4j -->
<resilience4j.version>2.1.0</resilience4j.version>
```

### 2. 新增微服务模块
需要在`seckill-parent/pom.xml`的`<modules>`中添加:
```xml
<module>seckill-inventory-service</module>
<module>seckill-material-service</module>
<module>seckill-warehouse-service</module>
<module>seckill-delivery-service</module>
<module>seckill-supplier-service</module>
<module>seckill-inspect-service</module>
```

---

## 数据库迁移

### 执行步骤
1. **备份现有数据**(如有生产数据)
```bash
mysqldump -h localhost -u root -p seckill > backup_$(date +%Y%m%d).sql
```

2. **执行新Schema**
```bash
mysql -h localhost -u root -p < seckill-parent/schema.sql
```

3. **验证表结构**
```sql
USE seckill;
SHOW TABLES;
-- 应看到30+张表
```

---

## 微服务模块创建

### 标准模块结构
每个新微服务需包含以下结构:
```
seckill-xxx-service/
├── pom.xml                          # Maven配置
├── src/main/java/com/seckill/xxx/
│   ├── XxxServiceApplication.java   # 启动类
│   ├── controller/                  # 控制器层
│   ├── service/                     # 业务逻辑层
│   │   └── impl/                    # 实现类
│   ├── mapper/                      # MyBatis Mapper
│   ├── entity/                      # 实体类
│   ├── vo/                          # 视图对象
│   ├── config/                      # 配置类
│   └── exception/                   # 异常处理
└── src/main/resources/
    ├── application.yml              # 应用配置
    └── mapper/                      # MyBatis XML
```

### 示例:库存服务(seckill-inventory-service)

#### 1. pom.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.seckill</groupId>
        <artifactId>seckill-parent</artifactId>
        <version>2.0.0</version>
    </parent>

    <artifactId>seckill-inventory-service</artifactId>
    <name>Inventory Service</name>
    <description>库存管理服务 - 多仓库库存扣减、预占、回滚</description>

    <dependencies>
        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Nacos服务注册发现 -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        </dependency>

        <!-- Nacos配置中心 -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
        </dependency>

        <!-- MyBatis-Plus -->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-spring-boot3-starter</artifactId>
        </dependency>

        <!-- MySQL驱动 -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
        </dependency>

        <!-- Druid连接池 -->
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>druid-spring-boot-3-starter</artifactId>
        </dependency>

        <!-- Redis -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>

        <!-- Redisson分布式锁 -->
        <dependency>
            <groupId>org.redisson</groupId>
            <artifactId>redisson-spring-boot-starter</artifactId>
        </dependency>

        <!-- RocketMQ -->
        <dependency>
            <groupId>org.apache.rocketmq</groupId>
            <artifactId>rocketmq-spring-boot-starter</artifactId>
        </dependency>

        <!-- Seata分布式事务 -->
        <dependency>
            <groupId>io.seata</groupId>
            <artifactId>seata-spring-boot-starter</artifactId>
        </dependency>

        <!-- OpenFeign服务调用 -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>

        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- SpringDoc OpenAPI -->
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

#### 2. application.yml
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
    url: jdbc:mysql://localhost:3306/seckill?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: root123456
    druid:
      initial-size: 5
      min-idle: 5
      max-active: 20
      max-wait: 60000
  
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
  
  # RocketMQ配置
  rocketmq:
    name-server: localhost:9876
    producer:
      group: inventory-producer-group
      send-message-timeout: 3000

# Nacos配置
cloud:
  nacos:
    discovery:
      server-addr: localhost:8848
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

# SpringDoc配置
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /swagger-ui.html

# 日志配置
logging:
  level:
    com.seckill.inventory: debug
```

#### 3. 启动类 InventoryServiceApplication.java
```java
package com.seckill.inventory;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan("com.seckill.inventory.mapper")
public class InventoryServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(InventoryServiceApplication.class, args);
    }
}
```

#### 4. 核心业务:库存扣减Lua脚本
创建文件:`src/main/resources/lua/decrease_stock.lua`
```lua
-- 原子扣减库存Lua脚本
-- KEYS[1]: 库存key (stock:{skuId}:{warehouseId})
-- ARGV[1]: 扣减数量

local stock = tonumber(redis.call('get', KEYS[1]))
local decrease = tonumber(ARGV[1])

if stock and stock >= decrease then
    redis.call('decrby', KEYS[1], decrease)
    return 1  -- 成功
else
    return 0  -- 库存不足
end
```

#### 5. 库存服务核心代码示例

**InventoryController.java**
```java
package com.seckill.inventory.controller;

import com.seckill.inventory.service.InventoryService;
import com.seckill.inventory.vo.InventoryVO;
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
    public boolean decreaseStock(
            @RequestParam Long skuId,
            @RequestParam Long warehouseId,
            @RequestParam Integer quantity) {
        return inventoryService.decreaseStock(skuId, warehouseId, quantity);
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

    @GetMapping("/{skuId}/{warehouseId}")
    @Operation(summary = "查询库存", description = "查询指定SKU在指定仓库的库存详情")
    public InventoryVO getInventory(
            @PathVariable Long skuId,
            @PathVariable Long warehouseId) {
        return inventoryService.getInventory(skuId, warehouseId);
    }
}
```

**InventoryService.java**
```java
package com.seckill.inventory.service;

import com.seckill.inventory.vo.InventoryVO;

public interface InventoryService {
    
    /**
     * 原子扣减库存(Redis Lua脚本保证原子性)
     */
    boolean decreaseStock(Long skuId, Long warehouseId, Integer quantity);
    
    /**
     * 预占库存(用于待支付订单)
     */
    boolean reserveStock(String orderNo, Long skuId, Long warehouseId, Integer quantity);
    
    /**
     * 释放预占库存(订单取消或超时)
     */
    void releaseReservedStock(String orderNo);
    
    /**
     * 查询库存
     */
    InventoryVO getInventory(Long skuId, Long warehouseId);
    
    /**
     * 回补库存(订单取消时)
     */
    void rollbackStock(Long skuId, Long warehouseId, Integer quantity);
}
```

---

## RocketMQ集成

### 1. docker-compose.yml添加RocketMQ
```yaml
  # RocketMQ消息队列
  rocketmq-namesrv:
    image: apache/rocketmq:5.1.4
    container_name: rocketmq-namesrv
    ports:
      - "9876:9876"
    command: sh mqnamesrv
    networks:
      - seckill-network

  rocketmq-broker:
    image: apache/rocketmq:5.1.4
    container_name: rocketmq-broker
    ports:
      - "10911:10911"
      - "10909:10909"
    environment:
      NAMESRV_ADDR: rocketmq-namesrv:9876
    command: sh mqbroker -n rocketmq-namesrv:9876
    depends_on:
      - rocketmq-namesrv
    volumes:
      - ./docker/rocketmq/broker.conf:/home/rocketmq/rocketmq-5.1.4/conf/broker.conf
    networks:
      - seckill-network

  # RocketMQ Console(可选,可视化管理界面)
  rocketmq-console:
    image: apacherocketmq/rocketmq-dashboard:latest
    container_name: rocketmq-console
    ports:
      - "8081:8080"
    environment:
      JAVA_OPTS: -Drocketmq.namesrv.addr=rocketmq-namesrv:9876
    depends_on:
      - rocketmq-namesrv
    networks:
      - seckill-network
```

### 2. 订单超时取消 - 延时消息示例

**OrderTimeoutListener.java**
```java
package com.seckill.order.listener;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
@RocketMQMessageListener(
    topic = "order-timeout-topic",
    consumerGroup = "order-timeout-consumer-group",
    selectorExpression = "*"
)
public class OrderTimeoutListener implements RocketMQListener<String> {

    private final OrderService orderService;

    @Override
    public void onMessage(String orderNo) {
        log.info("收到订单超时消息: {}", orderNo);
        try {
            // 检查订单是否仍未支付
            if (orderService.isUnpaid(orderNo)) {
                // 取消订单并回滚库存
                orderService.cancelOrderAndRollbackStock(orderNo);
                log.info("订单{}已自动取消", orderNo);
            }
        } catch (Exception e) {
            log.error("处理订单超时消息失败: {}", orderNo, e);
            // RocketMQ会自动重试
        }
    }
}
```

**发送延时消息**
```java
// 订单创建后发送30分钟延时消息
rocketMQTemplate.syncSendDelayTimeMills(
    "order-timeout-topic",
    orderNo,
    30 * 60 * 1000  // 30分钟
);
```

---

## Seata分布式事务

### 1. docker-compose.yml添加Seata Server
```yaml
  # Seata分布式事务服务器
  seata-server:
    image: seataio/seata-server:2.0.0
    container_name: seata-server
    ports:
      - "8091:8091"
    environment:
      SEATA_PORT: 8091
      STORE_MODE: file
    networks:
      - seckill-network
```

### 2. 使用示例 - 订单创建分布式事务

```java
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;
    private final InventoryFeignClient inventoryFeignClient;
    private final DeliveryFeignClient deliveryFeignClient;

    @GlobalTransactional(name = "create-order-tx", rollbackFor = Exception.class)
    @Override
    public String createOrder(OrderCreateDTO dto) {
        // 1. 创建订单
        Orders order = new Orders();
        // ... 设置订单信息
        orderMapper.insert(order);

        // 2. 远程调用扣减库存(Seata会自动纳入全局事务)
        inventoryFeignClient.decreaseStock(
            dto.getSkuId(),
            dto.getWarehouseId(),
            dto.getQuantity()
        );

        // 3. 创建配送单
        deliveryFeignClient.createDeliveryOrder(
            order.getOrderNo(),
            dto.getWarehouseId()
        );

        return order.getOrderNo();
    }
}
```

---

## Redis增强使用

### 1. Redis Key设计规范
```
商品库存:     stock:{skuId}:{warehouseId}
秒杀库存:     seckill:stock:{sessionId}
预占库存:     reserved:{orderNo}
分布式锁:     lock:seckill:{userId}:{sessionId}
用户限购:     limit:{userId}:{sessionId}
会话Token:    session:{token}
验证码:       captcha:{phone}
```

### 2. Redisson分布式锁示例

```java
@Service
@RequiredArgsConstructor
public class SeckillServiceImpl implements SeckillService {

    private final RedissonClient redissonClient;
    private final StringRedisTemplate redisTemplate;

    public boolean seckill(Long userId, Long sessionId) {
        String lockKey = "lock:seckill:" + userId + ":" + sessionId;
        RLock lock = redissonClient.getLock(lockKey);
        
        try {
            // 尝试获取锁,最多等待5秒,锁定10秒后自动释放
            if (lock.tryLock(5, 10, TimeUnit.SECONDS)) {
                // 1. 检查是否已抢购过
                String limitKey = "limit:" + userId + ":" + sessionId;
                if (Boolean.TRUE.equals(redisTemplate.hasKey(limitKey))) {
                    throw new BusinessException("您已抢购过该商品");
                }

                // 2. 执行Lua脚本原子扣减库存
                String stockKey = "seckill:stock:" + sessionId;
                Long result = redisTemplate.execute(
                    decreaseStockScript,
                    Collections.singletonList(stockKey),
                    "1"  // 扣减1件
                );

                if (result == 1) {
                    // 3. 记录限购标识(设置过期时间为秒杀场次结束时间)
                    redisTemplate.opsForValue().set(limitKey, "1", 1, TimeUnit.HOURS);
                    return true;
                } else {
                    throw new BusinessException("库存不足");
                }
            } else {
                throw new BusinessException("系统繁忙,请稍后重试");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new BusinessException("系统异常");
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }
}
```

---

## 前端适配

### 1. 新增页面路由
在`seckill-frontend/src/router/index.ts`中添加:
```typescript
{
  path: '/material',
  name: 'Material',
  component: () => import('@/views/MaterialView.vue'),
  meta: { title: '物资管理' }
},
{
  path: '/warehouse',
  name: 'Warehouse',
  component: () => import('@/views/WarehouseView.vue'),
  meta: { title: '仓储管理' }
},
{
  path: '/delivery',
  name: 'Delivery',
  component: () => import('@/views/DeliveryView.vue'),
  meta: { title: '配送追踪' }
},
{
  path: '/supplier',
  name: 'Supplier',
  component: () => import('@/views/SupplierView.vue'),
  meta: { title: '供应商管理' }
}
```

### 2. API接口封装
创建`seckill-frontend/src/api/inventory.ts`:
```typescript
import request from '@/utils/request'

export function getInventory(skuId: number, warehouseId: number) {
  return request({
    url: `/api/inventory/${skuId}/${warehouseId}`,
    method: 'get'
  })
}

export function decreaseStock(data: {
  skuId: number
  warehouseId: number
  quantity: number
}) {
  return request({
    url: '/api/inventory/decrease',
    method: 'post',
    params: data
  })
}
```

---

## 部署配置

### 完整docker-compose.yml
参考项目根目录的`docker-compose.yml`,确保包含:
- ✅ MySQL 8.0
- ✅ Redis 7.x
- ✅ Nacos 2.3.0
- ✅ RocketMQ 5.1.4
- ✅ Seata Server 2.0.0
- ✅ 所有Java微服务
- ✅ Python AI Agent
- ✅ 前端Nginx

### 启动顺序
1. 基础设施: `docker-compose up -d mysql redis nacos rocketmq-namesrv seata-server`
2. 等待30秒让基础设施就绪
3. Java微服务: 按依赖顺序启动
4. Python AI Agent
5. 前端

---

## 测试验证

### 1. 单元测试
```bash
cd seckill-parent
mvn test
```

### 2. 压力测试(JMeter)
- 秒杀接口: 5000 QPS,持续5分钟
- 验证: 无超卖、无重复下单

### 3. 功能测试清单
- [ ] 商品发布→审核→上架流程
- [ ] 秒杀抢购→订单创建→支付→发货→配送→完成
- [ ] 物资采购→入库→出库
- [ ] 仓库间调拨
- [ ] 库存盘点
- [ ] 配送状态实时更新
- [ ] 供应商资质审核
- [ ] 验收任务处理

---

## 下一步行动

### 立即可执行的任务
1. ✅ 数据库Schema已更新
2. ✅ 父POM已添加新依赖
3. ⏳ 创建6个新微服务模块(参考上述示例)
4. ⏳ 配置RocketMQ和Seata的docker-compose
5. ⏳ 实现核心业务逻辑
6. ⏳ 前端页面开发

### 需要您确认的事项
1. 是否需要我继续创建所有6个新微服务的完整代码?
2. 是否需要生成完整的docker-compose.yml配置文件?
3. 是否需要提供前端Vue组件示例代码?
4. 是否需要编写单元测试和集成测试?

请告诉我您希望我优先完成哪部分工作!