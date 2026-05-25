# AI智能秒杀系统 - 技术架构详解

## 🏗️ 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer (客户端层)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Web Browser │  │ Mobile App   │  │  API Clients │      │
│  │  (Vue 3)     │  │  (Future)    │  │  (Postman)   │      │
│  └──────┬───────┘  └──────────────┘  └──────────────┘      │
└─────────┼───────────────────────────────────────────────────┘
          │ HTTPS/HTTP
          ▼
┌─────────────────────────────────────────────────────────────┐
│                  Gateway Layer (网关层)                       │
│  ┌────────────────────────────────────────────────────┐     │
│  │   Spring Cloud Gateway (端口: 8080)                │     │
│  │   ├─ 路由转发                                       │     │
│  │   ├─ 负载均衡                                       │     │
│  │   ├─ 限流熔断                                       │     │
│  │   ├─ 权限校验                                       │     │
│  │   └─ API文档 (SpringDoc OpenAPI)                   │     │
│  └────────────────────────────────────────────────────┘     │
└─────────┬────────────────┬───────────────┬──────────────────┘
          │                │               │
          ▼                ▼               ▼
┌─────────────────────────────────────────────────────────────┐
│              Microservices Layer (微服务层)                   │
│                                                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  User    │  │ Product  │  │  Order   │  │ Seckill  │   │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │   │
│  │ :8081    │  │ :8082    │  │ :8083    │  │ :8084    │   │
│  │          │  │          │  │          │  │          │   │
│  │• 用户管理│  │• 商品查询│  │• 订单创建│  │• 库存扣减│   │
│  │• 登录认证│  │• 库存查询│  │• 订单查询│  │• 异步处理│   │
│  │• 权限控制│  │• 价格计算│  │• 状态管理│  │• 限流控制│   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        │ Feign       │ Feign       │ Feign       │ Redis +
        │             │             │             │ Async Queue
        ▼             ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────┐
│              AI Agent Layer (AI智能层)                        │
│  ┌────────────────────────────────────────────────────┐     │
│  │   Python FastAPI Service (端口: 8000)              │     │
│  │                                                     │     │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  │     │
│  │  │ ReAct Agent │  │ RAG Engine  │  │ Tools     │  │     │
│  │  │             │  │             │  │           │  │     │
│  │  │• 推理引擎   │  │• 向量检索   │  │• Redis工具│  │     │
│  │  │• 自我反思   │  │• 知识库     │  │• 统计工具 │  │     │
│  │  │• 置信度评估 │  │• ChromaDB   │  │• 分析工具 │  │     │
│  │  └─────────────┘  └─────────────┘  └───────────┘  │     │
│  └────────────────────────────────────────────────────┘     │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/REST
                         ▼
┌─────────────────────────────────────────────────────────────┐
│            Infrastructure Layer (基础设施层)                  │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    MySQL     │  │    Redis     │  │    Nacos     │      │
│  │    :3306     │  │    :6379     │  │    :8848     │      │
│  │              │  │              │  │              │      │
│  │ • 用户数据   │  │ • 库存缓存   │  │ • 服务注册   │      │
│  │ • 商品数据   │  │ • 会话管理   │  │ • 配置中心   │      │
│  │ • 订单数据   │  │ • 限流计数   │  │ • 健康检查   │      │
│  │ • 秒杀记录   │  │ • 统计数据   │  │ • 服务发现   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## 🔍 核心流程详解

### 1. 秒杀流程

```
用户请求
   │
   ▼
┌─────────────────┐
│  API Gateway    │ ← 路由转发、限流
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Seckill Service │
│                 │
│ 1. Redis预检库存 │ ← GET seckill:stock:{productId}
│ 2. 用户限流检查  │ ← SETNX seckill:user:{uid}:{pid}
│ 3. Redis原子递减 │ ← DECRBY seckill:stock:{productId}
│ 4. 入队异步处理  │ ← BlockingQueue.offer()
│ 5. 等待结果      │ ← CompletableFuture.get()
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Consumer Pool  │ ← 10个消费者线程
│                 │
│ 1. 出队任务      │ ← queue.take()
│ 2. Feign调用     │ ← OrderService.createOrder()
│ 3. 返回结果      │ ← future.complete()
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Order Service  │
│                 │
│ 1. 创建订单记录  │ ← INSERT INTO order
│ 2. 更新库存      │ ← UPDATE stock (乐观锁)
│ 3. 记录秒杀日志  │ ← INSERT INTO seckill_record
└────────┬────────┘
         │
         ▼
    返回订单号
```

**关键技术点**:
- **Redis原子操作**: 保证库存扣减的原子性
- **内存队列**: 削峰填谷,保护后端服务
- **CompletableFuture**: 异步非阻塞,提升吞吐量
- **用户限流**: 防止恶意刷单(10秒内只能请求一次)

### 2. AI分析流程

```
前端提问
   │
   ▼
┌─────────────────┐
│  API Gateway    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Python AI Agent │
│                 │
│ 1. 接收问题      │ ← POST /api/seckill/analyze
│ 2. 获取实时数据  │ ← Redis: stock, stats
│ 3. 构建上下文    │ ← Prompt Engineering
│ 4. LLM推理       │ ← DashScope Qwen API
│ 5. 置信度评估    │ ← Confidence Score
│ 6. 自我反思      │ ← Self-Reflection (if low confidence)
│ 7. 返回答案      │ ← JSON Response
└────────┬────────┘
         │
         ▼
   显示分析结果
```

**AI能力**:
- **ReAct框架**: Reasoning + Acting,边思考边行动
- **RAG增强**: Retrieval-Augmented Generation,基于知识库
- **自我反思**: 低置信度时自动重新思考
- **工具调用**: 实时查询Redis获取最新数据

### 3. 服务注册与发现

```
┌──────────────┐     Register      ┌──────────────┐
│ User Service │ ─────────────────►│              │
└──────────────┘                    │              │
                                    │   Nacos      │
┌──────────────┐     Register      │   Server     │
│Product Service│─────────────────►│              │
└──────────────┘                    │              │
                                    │              │
┌──────────────┐     Register      │              │
│Order Service │──────────────────►│              │
└──────────────┘                    └──────┬───────┘
                                           │
                                    Discover│
                                           │
                                    ┌──────▼───────┐
                                    │   Gateway    │
                                    │              │
                                    │ Load Balance │
                                    └──────────────┘
```

**优势**:
- 服务动态扩缩容
- 自动健康检查
- 负载均衡
- 配置集中管理

## 💾 数据流设计

### Redis数据结构

```
# 库存缓存 (String)
seckill:stock:1 = 100    # iPhone 15 Pro库存
seckill:stock:2 = 100    # 华为 Mate 60 Pro库存

# 用户限流 (String with TTL)
seckill:user:123:1 = "1" EX 10  # 用户123对商品1的限流,10秒过期

# 统计数据 (Hash)
seckill:stats = {
  "success": 1523,
  "fail": 477,
  "total": 2000
}

# AI分析缓存 (String)
seckill:ai:stats = {...}  # AI分析结果JSON
```

### MySQL表结构

```sql
-- 商品表
product (id, product_name, price, seckill_price, status, version)

-- 库存表
stock (id, product_id, total_stock, seckill_stock, version)

-- 订单表
order (id, order_no, user_id, product_id, quantity, amount, status)
  ├─ 唯一索引: uk_user_product_status (user_id, product_id, status)
  └─ 作用: 防止同一用户对同一商品重复下单

-- 秒杀记录表
seckill_record (id, user_id, product_id, order_no, status, created_at)
  ├─ 唯一索引: uk_user_product (user_id, product_id)
  └─ 作用: 记录每次秒杀尝试
```

## 🔐 安全设计

### 1. 防超卖机制

```
层级1: Redis预检
  ├─ 原子递减库存
  └─ 失败立即返回

层级2: 数据库乐观锁
  ├─ UPDATE stock SET seckill_stock = seckill_stock - 1 
  │   WHERE product_id = ? AND seckill_stock > 0
  └─ 影响行数 = 0 表示库存不足

层级3: 唯一约束
  ├─ uk_user_product_status
  └─ 防止重复下单
```

### 2. 防刷单机制

```
用户限流:
  ├─ Redis SETNX (10秒TTL)
  ├─ 同一用户10秒内只能请求一次
  └─ 请求完成后删除key

IP限流(Gateway):
  ├─ Sentinel流量控制
  └─ 单IP每秒最多10次请求
```

### 3. 数据安全

```
敏感信息:
  ├─ API Key存储在.env文件
  ├─ .gitignore排除敏感配置
  └─ Docker环境变量注入

SQL注入防护:
  ├─ MyBatis-Plus参数化查询
  └─ 禁止字符串拼接SQL

XSS防护:
  ├─ Vue自动转义
  └─ Element Plus安全组件
```

## ⚡ 性能优化策略

### 1. 缓存策略

```
多级缓存:
  L1: 浏览器缓存 (静态资源)
  L2: CDN缓存 (图片、CSS、JS)
  L3: Redis缓存 (热点数据)
  L4: JVM本地缓存 (Caffeine,可选)

缓存更新:
  ├─ Cache-Aside模式
  ├─ 先更新DB,再删除Cache
  └─ 双删策略(可选)
```

### 2. 异步处理

```
同步流程: 用户 → Gateway → Seckill → Order → DB (耗时: 200ms)
异步流程: 用户 → Gateway → Seckill → Queue → [Async] → Order → DB (耗时: 50ms)

优势:
  ├─ 响应时间降低75%
  ├─ 吞吐量提升4倍
  └─ 用户体验更好
```

### 3. 连接池优化

```
Druid连接池配置:
  ├─ initial-size: 5
  ├─ max-active: 20
  ├─ min-idle: 5
  ├─ max-wait: 60000ms
  └─ 监控: SQL执行统计、慢查询检测

Redis连接池:
  ├─ Lettuce (默认)
  ├─ 支持异步
  └─ 连接复用
```

### 4. 数据库优化

```
索引优化:
  ├─ 主键索引: id
  ├─ 唯一索引: order_no, uk_user_product_status
  └─ 普通索引: user_id, product_id, created_at

查询优化:
  ├─ 避免SELECT *
  ├─ 分页查询LIMIT
  └─ 批量操作

读写分离(未来):
  ├─ 主库: 写操作
  └─ 从库: 读操作
```

## 📊 监控与可观测性

### 1. 应用监控

```
Spring Boot Actuator:
  ├─ /actuator/health - 健康检查
  ├─ /actuator/metrics - 指标数据
  ├─ /actuator/env - 环境变量
  └─ /actuator/loggers - 日志级别

Prometheus + Grafana (未来):
  ├─ JVM内存使用
  ├─ GC次数
  ├─ HTTP请求QPS
  └─ 数据库连接数
```

### 2. 链路追踪

```
Spring Cloud Sleuth + Zipkin (未来):
  ├─ 请求ID追踪
  ├─ 服务调用链
  ├─ 耗时分析
  └─ 依赖关系图
```

### 3. 日志收集

```
ELK Stack (未来):
  ├─ Elasticsearch: 日志存储
  ├─ Logstash: 日志处理
  └─ Kibana: 日志可视化

当前方案:
  ├─ SLF4J + Logback
  ├─ 文件滚动策略
  └─ 日志级别动态调整
```

## 🔄 部署架构

### 开发环境

```
Local Machine
  ├─ MySQL (Docker)
  ├─ Redis (Docker)
  ├─ Nacos (Docker)
  ├─ Java Services (IDE运行)
  ├─ Python Service (venv运行)
  └─ Frontend (npm run dev)
```

### 测试环境

```
Test Server (1台)
  ├─ Docker Compose
  │   ├─ MySQL
  │   ├─ Redis
  │   ├─ Nacos
  │   ├─ Java Services (Container)
  │   └─ Python Service (Container)
  └─ Nginx (Frontend + Reverse Proxy)
```

### 生产环境

```
Production Cluster (Kubernetes)
  ├─ Ingress Controller (Nginx)
  ├─ Frontend (Static Files on CDN)
  │
  ├─ Namespace: backend
  │   ├─ Gateway (Deployment × 2)
  │   ├─ User Service (Deployment × 2)
  │   ├─ Product Service (Deployment × 2)
  │   ├─ Order Service (Deployment × 2)
  │   └─ Seckill Service (Deployment × 3)
  │
  ├─ Namespace: ai
  │   └─ Python AI Agent (Deployment × 2)
  │
  └─ External Services
      ├─ MySQL Cluster (主从复制)
      ├─ Redis Cluster (哨兵模式)
      └─ Nacos Cluster (3节点)
```

## 🎯 扩展性设计

### 水平扩展

```
无状态服务:
  ├─ Gateway: 可随时增加实例
  ├─ User/Product/Order/Seckill: 支持横向扩容
  └─ Python AI Agent: 支持多副本

有状态服务:
  ├─ MySQL: 主从复制 + 读写分离
  ├─ Redis: 哨兵模式 / Cluster模式
  └─ Nacos: 集群部署
```

### 垂直扩展

```
资源升级:
  ├─ CPU: 提升并发处理能力
  ├─ 内存: 增加缓存容量
  └─ 磁盘: SSD提升I/O性能

配置调优:
  ├─ JVM参数: -Xms -Xmx -XX:+UseG1GC
  ├─ 线程池大小: 根据CPU核心数调整
  └─ 连接池大小: 根据负载调整
```

## 🚀 未来演进方向

### 短期 (1-3个月)

- [ ] 引入RocketMQ消息队列
- [ ] 实现分布式事务(Seata)
- [ ] 添加单元测试和集成测试
- [ ] CI/CD自动化部署
- [ ] Prometheus + Grafana监控

### 中期 (3-6个月)

- [ ] Elasticsearch日志检索
- [ ] Sentinel流量控制
- [ ] 页面静态化 + CDN
- [ ] 热点数据本地缓存(Caffeine)
- [ ] SkyWalking链路追踪

### 长期 (6-12个月)

- [ ] 分库分表(ShardingSphere)
- [ ] Kubernetes集群部署
- [ ] 灰度发布支持
- [ ] 多活数据中心
- [ ] AI推荐引擎(个性化秒杀)

---

**架构版本**: v2.0.0  
**最后更新**: 2026-05-19  
**维护者**: AI-Seckill Team
