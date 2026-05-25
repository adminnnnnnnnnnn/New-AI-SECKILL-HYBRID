# 快速开始指南

## 前置条件检查

在开始之前,请确保已安装以下软件:

- ✅ JDK 17+ (推荐 Eclipse Temurin 17)
- ✅ Python 3.11+
- ✅ Node.js 18+ & npm 9+
- ✅ Maven 3.9+
- ✅ MySQL 8.0
- ✅ Redis 7.x
- ✅ Docker & Docker Compose (可选,用于一键部署)

## 方式一: Docker Compose一键部署(最简单)

```bash
# Windows用户
start.bat

# Linux/Mac用户
chmod +x start.sh
./start.sh
```

等待所有服务启动后,访问 http://localhost:3000

## 方式二: 本地开发环境(适合开发调试)

### Step 1: 启动基础设施

使用Docker快速启动MySQL、Redis和Nacos:

```bash
# 启动MySQL
docker run -d --name seckill-mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=root123456 \
  -e MYSQL_DATABASE=seckill \
  -e TZ=Asia/Shanghai \
  mysql:8.0 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

# 启动Redis
docker run -d --name seckill-redis \
  -p 6379:6379 \
  redis:7-alpine

# 启动Nacos(单机模式)
docker run -d --name seckill-nacos \
  -p 8848:8848 \
  -p 9848:9848 \
  -e MODE=standalone \
  -e TZ=Asia/Shanghai \
  nacos/nacos-server:v2.3.0
```

### Step 2: 初始化数据库

```bash
# 方法1: 使用命令行
mysql -h localhost -u root -proot123456 seckill < seckill-parent/schema.sql

# 方法2: 使用Navicat/DBeaver等工具导入schema.sql文件
```

验证数据是否导入成功:
```sql
USE seckill;
SHOW TABLES;
SELECT * FROM product;
SELECT * FROM stock;
```

### Step 3: 配置环境变量

在项目根目录创建 `.env` 文件:

```env
DASHSCOPE_API_KEY=sk-a7db72f5eb2d45e8ba1692da12728c06
REDIS_HOST=localhost
REDIS_PORT=6379
```

**重要**: 需要申请通义千问API Key
- 访问: https://dashscope.console.aliyun.com/
- 注册/登录后获取API Key
- 替换上面的 `sk-your-api-key`

### Step 4: 启动Java微服务

打开5个终端窗口,分别启动各个服务:

#### 终端1: 编译父工程

```bash
cd seckill-parent
mvn clean install -DskipTests
```

#### 终端2: 用户服务 (端口: 8081)

```bash
cd seckill-user-service
mvn spring-boot:run
```

#### 终端3: 商品服务 (端口: 8082)

```bash
cd seckill-product-service
mvn spring-boot:run
```

#### 终端4: 订单服务 (端口: 8083)

```bash
cd seckill-order-service
mvn spring-boot:run
```

#### 终端5: 秒杀服务 (端口: 8084)

```bash
cd seckill-seckill-service
mvn spring-boot:run
```

#### 终端6: API网关 (端口: 8080)

```bash
cd seckill-gateway
mvn spring-boot:run
```

**启动顺序很重要!** 建议按以上顺序启动。

验证服务是否启动成功:
- 访问 Nacos控制台: http://localhost:8848/nacos (用户名/密码: nacos/nacos)
- 查看所有服务是否已注册

### Step 5: 启动Python AI Agent

```bash
cd python-ai-agent

# 创建虚拟环境(首次运行)
python -m venv venv

# 激活虚拟环境
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 启动服务
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

访问 http://localhost:8000/docs 查看API文档

### Step 6: 启动前端

```bash
cd seckill-frontend

# 安装依赖(首次运行)
npm install --registry=https://registry.npmmirror.com

# 启动开发服务器
npm run dev
```

访问 http://localhost:3000

## 验证系统是否正常运行

### 1. 测试秒杀功能

在前端界面:
1. 输入用户ID (例如: 1)
2. 选择商品 (iPhone 15 Pro 或 华为 Mate 60 Pro)
3. 点击"立即秒杀"按钮
4. 观察库存变化和统计数据

### 2. 测试AI分析

在AI智能分析区域:
1. 输入问题,例如: "当前秒杀成功率如何?"
2. 点击"开始分析"
3. 查看AI返回的分析结果和建议

### 3. 检查后端日志

观察各服务终端输出,应该看到:
- ✅ 服务注册成功
- ✅ Redis连接成功
- ✅ 数据库连接成功
- ✅ 秒杀请求处理日志

## 常见问题排查

### 问题1: Java服务启动失败

**症状**: 报错 `Connection refused` 或 `BeanCreationException`

**解决方案**:
1. 检查Nacos是否启动: `docker ps | grep nacos`
2. 检查端口是否被占用: `netstat -ano | findstr 8848`
3. 查看application.yml配置是否正确

### 问题2: Python服务无法连接Redis

**症状**: 报错 `ConnectionError: Error connecting to Redis`

**解决方案**:
1. 检查Redis是否运行: `docker ps | grep redis`
2. 测试Redis连接: `docker exec -it seckill-redis redis-cli ping` (应返回PONG)
3. 检查 `python-ai-agent/app/config.py` 中的REDIS_HOST配置

### 问题3: 前端页面空白

**症状**: 访问localhost:3000显示空白页

**解决方案**:
1. 打开浏览器开发者工具(F12),查看Console错误
2. 检查Network标签,确认API请求是否成功
3. 确认后端服务是否全部启动

### 问题4: 秒杀总是失败

**症状**: 点击秒杀后提示"库存不足"或"系统繁忙"

**解决方案**:
1. 检查Redis中库存是否正确: `docker exec -it seckill-redis redis-cli GET seckill:stock:1`
2. 重置库存: `docker exec -it seckill-redis redis-cli SET seckill:stock:1 100`
3. 重启秒杀服务

### 问题5: AI分析无响应

**症状**: 点击分析后一直loading

**解决方案**:
1. 检查DASHSCOPE_API_KEY是否正确配置
2. 查看Python服务日志是否有错误
3. 测试API Key是否有效: 访问通义千问控制台测试

## 开发调试技巧

### 热重载

- **Java**: 修改代码后需要重新编译运行 (或使用Spring DevTools)
- **Python**: FastAPI已配置 `--reload`,修改代码自动重启
- **Vue**: Vite支持HMR,修改代码浏览器自动刷新

### 日志查看

```bash
# 查看Java服务日志
tail -f seckill-*/logs/*.log

# 查看Python服务日志
# 直接在终端窗口查看

# 查看Docker容器日志
docker logs -f seckill-mysql
docker logs -f seckill-redis
docker logs -f seckill-nacos
```

### 数据库操作

```bash
# 进入MySQL容器
docker exec -it seckill-mysql mysql -uroot -proot123456 seckill

# 常用SQL
SELECT * FROM product;
SELECT * FROM stock;
SELECT * FROM `order` ORDER BY created_at DESC LIMIT 10;
SELECT COUNT(*) FROM seckill_record WHERE status = 1;
```

### Redis操作

```bash
# 进入Redis容器
docker exec -it seckill-redis redis-cli

# 常用命令
KEYS *
GET seckill:stock:1
GET seckill:stock:2
HGETALL seckill:stats
DEL seckill:stats  # 重置统计
SET seckill:stock:1 100  # 重置库存
```

## 下一步

- 📖 阅读 [完整文档](README.md)
- 🔧 查看 [API文档](http://localhost:8080/swagger-ui.html)
- 🎨 自定义前端界面
- 🚀 部署到生产环境
- 💡 贡献代码

祝开发愉快! 🎉
