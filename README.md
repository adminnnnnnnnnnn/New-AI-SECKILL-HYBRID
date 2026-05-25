# AI智能秒杀系统 (AI-Seckill-Hybrid)

基于 **Spring Boot 3 + Vue 3 + FastAPI** 的现代化高并发秒杀系统,集成AI智能分析能力。

## 🚀 技术栈

### 后端服务
- **Java微服务**: Spring Boot 3.2.3 + Java 17 + Spring Cloud 2023
- **Python AI Agent**: FastAPI + OpenAI SDK + ChromaDB向量数据库
- **数据库**: MySQL 8.0 + Redis 7.x
- **服务治理**: Nacos 2.3.0 (服务注册发现 + 配置中心)
- **ORM框架**: MyBatis-Plus 3.5.5
- **API文档**: SpringDoc OpenAPI 3.0

### 前端应用
- **框架**: Vue 3.4+ (Composition API)
- **语言**: TypeScript 5.x
- **构建工具**: Vite 5.x
- **UI组件**: Element Plus 2.6
- **状态管理**: Pinia 2.1
- **HTTP客户端**: Axios 1.6
- **数据可视化**: ECharts 5.5

## 📁 项目结构

```
ai-seckill-hybrid/
├── seckill-parent/              # Java微服务父工程
│   ├── seckill-common/         # 公共模块(实体、VO、异常)
│   ├── seckill-gateway/        # API网关(Spring Cloud Gateway)
│   ├── seckill-user-service/   # 用户服务
│   ├── seckill-product-service/# 商品服务
│   ├── seckill-order-service/  # 订单服务
│   ├── seckill-seckill-service/# 秒杀核心服务
│   └── schema.sql              # 数据库初始化脚本
├── python-ai-agent/            # Python AI智能分析服务
│   ├── app/
│   │   ├── agent/             # AI Agent核心逻辑
│   │   ├── api/               # REST API接口
│   │   ├── services/          # Redis等服务
│   │   └── main.py            # FastAPI入口
│   └── requirements.txt       # Python依赖
├── seckill-frontend/           # Vue 3前端应用
│   ├── src/
│   │   ├── views/             # 页面组件
│   │   ├── stores/            # Pinia状态管理
│   │   ├── router/            # 路由配置
│   │   └── utils/             # 工具函数
│   └── package.json
├── docker/                     # Docker配置文件
├── docker-compose.yml          # Docker编排文件
└── README.md                   # 项目说明
```

## 🎯 核心功能

### 1. 高并发秒杀
- ✅ Redis原子操作预减库存
- ✅ 内存队列异步削峰填谷
- ✅ 用户限流防重复提交
- ✅ CompletableFuture异步处理
- ✅ 分布式锁保证数据一致性

### 2. AI智能分析
- ✅ 实时库存监控与预警
- ✅ 秒杀成功率分析
- ✅ 智能优化建议
- ✅ 自然语言问答交互
- ✅ 自我反思提升准确度

### 3. 微服务架构
- ✅ Spring Cloud Gateway统一网关
- ✅ Nacos服务注册与发现
- ✅ OpenFeign服务间调用
- ✅ Resilience4j熔断降级
- ✅ 负载均衡

### 4. 现代化前端
- ✅ 实时数据看板
- ✅ 响应式设计
- ✅ 库存可视化监控
- ✅ AI对话交互界面
- ✅ 一键秒杀操作

## 🛠️ 快速开始

### 前置要求

- JDK 17+
- Python 3.11+
- Node.js 18+
- Maven 3.9+
- Docker & Docker Compose (可选)
- MySQL 8.0
- Redis 7.x
- Nacos 2.3.0

### 方式一: Docker Compose一键启动(推荐)

```bash
# 1. 克隆项目
git clone <repository-url>
cd ai-seckill-hybrid

# 2. 配置环境变量(可选)
cp .env.example .env
# 编辑.env文件,设置DASHSCOPE_API_KEY等

# 3. 启动所有服务
docker-compose up -d

# 4. 查看服务状态
docker-compose ps

# 5. 查看日志
docker-compose logs -f
```

访问地址:
- 前端界面: http://localhost:3000
- API网关: http://localhost:8080
- Python AI服务: http://localhost:8000
- Nacos控制台: http://localhost:8848/nacos (nacos/nacos)
- API文档: http://localhost:8080/swagger-ui.html

### 方式二: 本地开发环境

#### 1. 启动基础设施

```bash
# 启动MySQL
docker run -d --name mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=root123456 \
  -e MYSQL_DATABASE=seckill \
  mysql:8.0

# 启动Redis
docker run -d --name redis \
  -p 6379:6379 \
  redis:7-alpine

# 启动Nacos
docker run -d --name nacos \
  -p 8848:8848 \
  -e MODE=standalone \
  nacos/nacos-server:v2.3.0
```

#### 2. 初始化数据库

```bash
mysql -h localhost -u root -proot123456 seckill < seckill-parent/schema.sql
```

#### 3. 启动Java微服务

```bash
cd seckill-parent

# 编译打包
mvn clean install -DskipTests

# 按顺序启动服务
# 终端1: 用户服务
cd seckill-user-service
mvn spring-boot:run

# 终端2: 商品服务
cd seckill-product-service
mvn spring-boot:run

# 终端3: 订单服务
cd seckill-order-service
mvn spring-boot:run

# 终端4: 秒杀服务
cd seckill-seckill-service
mvn spring-boot:run

# 终端5: 网关
cd seckill-gateway
mvn spring-boot:run
```

#### 4. 启动Python AI Agent

```bash
cd python-ai-agent

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或 venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
export DASHSCOPE_API_KEY=sk-a7db72f5eb2d45e8ba1692da12728c06

# 启动服务
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 5. 启动前端

```bash
cd seckill-frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

访问 http://localhost:3000

## 📊 系统架构图

```
┌─────────────┐
│  Vue 3 Frontend │ :3000
└──────┬──────┘
       │ HTTP
       ▼
┌─────────────┐
│ API Gateway  │ :8080
│ (Spring Cloud)│
└──┬──┬──┬──┬─┘
   │  │  │  │
   ▼  ▼  ▼  ▼
┌────┐┌────┐┌────┐┌──────┐
│User││Prod││Order││Seckill│
│Svc ││Svc ││Svc  ││Svc   │
└────┘└────┘└────┘└──┬───┘
                      │ Feign
                      ▼
              ┌──────────────┐
              │ Python AI    │ :8000
              │ Agent        │
              └──────┬───────┘
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
     ┌─────────┐         ┌─────────┐
     │ MySQL   │         │ Redis   │
     │  :3306  │         │  :6379  │
     └─────────┘         └─────────┘
          ▲
          │
     ┌─────────┐
     │ Nacos   │
     │  :8848  │
     └─────────┘
```

## 🔧 配置说明

### 环境变量

创建 `.env` 文件:

```env
# DashScope API Key (通义千问)
DASHSCOPE_API_KEY=sk-xxxxxxxxx

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0

# MySQL配置
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=root123456
MYSQL_DATABASE=seckill

# Nacos配置
NACOS_SERVER_ADDR=localhost:8848
```

### Python AI Agent配置

编辑 `python-ai-agent/app/config.py`:

```python
class Config:
    DASHSCOPE_API_KEY = "sk-a7db72f5eb2d45e8ba1692da12728c06"
    DEFAULT_MODEL = "qwen-plus"  # 或 qwen-max, qwen-turbo
    ENABLE_RAG = True
```

## 🧪 测试

### 后端单元测试

```bash
cd seckill-parent
mvn test
```

### 前端测试

```bash
cd seckill-frontend
npm run test
```

### 压力测试

使用Apache Bench或JMeter对秒杀接口进行压测:

```bash
ab -n 10000 -c 100 http://localhost:8080/api/seckill/do
```

## 📝 API文档

启动服务后访问:
- Swagger UI: http://localhost:8080/swagger-ui.html
- OpenAPI JSON: http://localhost:8080/v3/api-docs

主要接口:

| 接口 | 方法 | 描述 |
|------|------|------|
| /api/seckill/do | POST | 执行秒杀 |
| /api/seckill/stats | GET | 获取统计数据 |
| /api/product/list | GET | 获取商品列表 |
| /api/ai/analyze | POST | AI智能分析 |

## 🎨 前端界面预览

- **实时数据看板**: 展示秒杀成功/失败数、成功率
- **库存监控**: 进度条可视化显示剩余库存
- **秒杀操作**: 简洁的表单界面,一键秒杀
- **AI助手**: 自然语言问答,获取智能分析

## 🚦 性能优化

### 已实现的优化

1. **Redis预减库存**: 避免直接操作数据库
2. **内存队列异步处理**: 削峰填谷,保护后端服务
3. **用户限流**: 防止恶意刷单
4. **CompletableFuture**: 异步非阻塞处理
5. **连接池**: Druid数据库连接池
6. **CDN加速**: 静态资源CDN分发(生产环境)

### 可进一步优化的方向

- [ ] 引入消息队列(RocketMQ/Kafka)
- [ ] 页面静态化 + CDN
- [ ] 热点数据本地缓存(Caffeine)
- [ ] 数据库读写分离
- [ ] 分库分表(ShardingSphere)
- [ ] Sentinel流量控制

## 🐛 常见问题

### 1. Java服务启动失败

检查Nacos是否启动,端口8848是否被占用。

### 2. Python AI服务无法连接Redis

确保Redis服务正常运行,检查`REDIS_HOST`配置。

### 3. 前端跨域问题

开发环境已通过Vite代理解决,生产环境需配置Nginx反向代理。

### 4. 数据库连接失败

检查MySQL服务状态,确认用户名密码正确。

## 📄 许可证

MIT License

## 👥 贡献

欢迎提交Issue和Pull Request!

## 📧 联系方式

如有问题,请提Issue或联系维护者。

---

**Enjoy Coding! 🚀**
