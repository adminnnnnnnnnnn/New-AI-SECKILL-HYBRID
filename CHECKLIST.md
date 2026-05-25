# 🚀 项目启动验证清单

## ✅ 文件完整性检查

### Java后端 (seckill-parent)
- [x] pom.xml - 升级到Spring Boot 3.2.3
- [x] seckill-common/pom.xml - Jakarta依赖
- [x] seckill-gateway/pom.xml - 版本更新
- [x] seckill-user-service/pom.xml - 版本更新
- [x] seckill-product-service/pom.xml - 版本更新+SpringDoc
- [x] seckill-order-service/pom.xml - MyBatis-Plus 3适配
- [x] seckill-seckill-service/pom.xml - Resilience4j升级
- [x] schema.sql - 数据库初始化脚本

### Python AI Agent (python-ai-agent)
- [x] requirements.txt - 依赖升级到最新
- [x] Dockerfile - 容器化配置
- [x] app/main.py - FastAPI入口
- [x] app/config.py - 配置管理
- [x] app/api/seckill.py - AI分析接口

### Vue 3前端 (seckill-frontend)
- [x] package.json - 依赖配置
- [x] vite.config.ts - Vite配置
- [x] tsconfig.json - TypeScript配置
- [x] index.html - HTML入口
- [x] src/main.ts - 应用入口
- [x] src/App.vue - 根组件
- [x] src/router/index.ts - 路由配置
- [x] src/stores/seckill.ts - Pinia状态管理
- [x] src/utils/request.ts - Axios封装
- [x] src/views/HomeView.vue - 主页面(完整功能)

### DevOps配置
- [x] docker-compose.yml - 服务编排
- [x] docker/gateway/Dockerfile - Gateway容器化
- [x] .env.example - 环境变量模板
- [x] .gitignore - Git忽略规则
- [x] start.sh - Linux/Mac启动脚本
- [x] start.bat - Windows启动脚本

### 文档
- [x] README.md - 项目总览
- [x] QUICKSTART.md - 快速开始指南
- [x] REFACTORING_SUMMARY.md - 重构总结
- [x] CHECKLIST.md - 本文件

## 🎯 启动前准备

### 1. 系统要求检查

```bash
# 检查Java版本 (需要17+)
java -version

# 检查Python版本 (需要3.11+)
python --version

# 检查Node.js版本 (需要18+)
node --version
npm --version

# 检查Maven版本 (需要3.9+)
mvn --version

# 检查Docker (可选,用于一键部署)
docker --version
docker-compose --version
```

**预期输出示例:**
```
openjdk version "17.0.x" 2024-xx-xx
Python 3.11.x
v18.x.x
9.x.x
Apache Maven 3.9.x
Docker version 24.x.x
Docker Compose version v2.x.x
```

### 2. 端口占用检查

确保以下端口未被占用:

| 端口 | 服务 | 用途 |
|------|------|------|
| 3306 | MySQL | 数据库 |
| 6379 | Redis | 缓存 |
| 8848 | Nacos | 服务注册 |
| 8080 | Gateway | API网关 |
| 8081 | User Service | 用户服务 |
| 8082 | Product Service | 商品服务 |
| 8083 | Order Service | 订单服务 |
| 8084 | Seckill Service | 秒杀服务 |
| 8000 | Python AI | AI分析服务 |
| 3000 | Frontend | 前端界面 |

**检查命令:**
```bash
# Windows
netstat -ano | findstr "3306 6379 8848 8080 8000 3000"

# Linux/Mac
lsof -i :3306,:6379,:8848,:8080,:8000,:3000
```

如有端口冲突,请先停止占用进程或修改配置。

### 3. 获取API Key

访问 https://dashscope.console.aliyun.com/ 申请通义千问API Key

创建 `.env` 文件:
```env
DASHSCOPE_API_KEY=sk-a7db72f5eb2d45e8ba1692da12728c06
```

## 🚦 启动方式选择

### 方式A: Docker Compose一键启动(推荐新手)

**优点**: 
- ✅ 无需安装MySQL、Redis、Nacos
- ✅ 环境隔离,不影响本地
- ✅ 一键启停,方便管理

**步骤**:

#### Windows用户
```cmd
start.bat
```

#### Linux/Mac用户
```bash
chmod +x start.sh
./start.sh
```

**等待约2-3分钟**,所有服务自动启动。

**验证**:
```bash
# 查看所有容器状态
docker-compose ps

# 应该看到所有服务都是 Up 状态
```

**访问**:
- 前端: http://localhost:3000
- API文档: http://localhost:8080/swagger-ui.html
- Nacos: http://localhost:8848/nacos (nacos/nacos)

**停止**:
```bash
docker-compose down
```

### 方式B: 本地开发环境(推荐开发者)

**优点**:
- ✅ 支持热重载
- ✅ 便于调试
- ✅ 快速迭代

#### Step 1: 启动基础设施(Docker)

```bash
# 一次性启动MySQL、Redis、Nacos
docker run -d --name seckill-mysql -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=root123456 \
  -e MYSQL_DATABASE=seckill \
  mysql:8.0 --character-set-server=utf8mb4

docker run -d --name seckill-redis -p 6379:6379 redis:7-alpine

docker run -d --name seckill-nacos -p 8848:8848 \
  -e MODE=standalone nacos/nacos-server:v2.3.0
```

#### Step 2: 初始化数据库

```bash
mysql -h localhost -u root -proot123456 seckill < seckill-parent/schema.sql
```

验证:
```sql
mysql -h localhost -u root -proot123456 seckill
SHOW TABLES;
SELECT * FROM product;
```

#### Step 3: 编译Java项目

```bash
cd seckill-parent
mvn clean install -DskipTests
```

**预期**: BUILD SUCCESS

#### Step 4: 启动Java微服务(5个终端)

**终端1 - 用户服务**:
```bash
cd seckill-user-service
mvn spring-boot:run
```
等待看到: `Started UserServiceApplication in X seconds`

**终端2 - 商品服务**:
```bash
cd seckill-product-service
mvn spring-boot:run
```

**终端3 - 订单服务**:
```bash
cd seckill-order-service
mvn spring-boot:run
```

**终端4 - 秒杀服务**:
```bash
cd seckill-seckill-service
mvn spring-boot:run
```

**终端5 - 网关**:
```bash
cd seckill-gateway
mvn spring-boot:run
```

**验证**: 访问 http://localhost:8848/nacos 查看服务注册情况

#### Step 5: 启动Python AI Agent

```bash
cd python-ai-agent

# 首次运行需要创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# 安装依赖
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 启动
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**验证**: 访问 http://localhost:8000/docs

#### Step 6: 启动前端

```bash
cd seckill-frontend

# 首次运行需要安装依赖
npm install --registry=https://registry.npmmirror.com

# 启动开发服务器
npm run dev
```

**验证**: 访问 http://localhost:3000

## ✅ 功能验证测试

### 测试1: 前端页面加载

1. 打开浏览器访问 http://localhost:3000
2. 应该看到紫色渐变背景的页面
3. 顶部显示"AI智能秒杀系统"标题
4. 四个统计卡片(成功、失败、总数、成功率)
5. 库存监控区域(两个进度条)
6. 秒杀操作表单
7. AI智能分析区域

**如果页面空白**:
- 按F12打开开发者工具
- 查看Console是否有错误
- 查看Network标签API请求是否成功

### 测试2: 实时数据刷新

1. 点击"刷新"按钮
2. 统计数据应该更新(初始为0)
3. 每5秒自动刷新一次

**如果数据不更新**:
- 检查后端服务是否全部启动
- 查看浏览器Network标签是否有失败的请求
- 检查Gateway日志

### 测试3: 执行秒杀

1. 输入用户ID: 1
2. 选择商品: iPhone 15 Pro
3. 数量: 1
4. 点击"立即秒杀"按钮

**预期结果**:
- 弹出提示: "秒杀成功!订单号: xxx"
- 库存减少1 (从100变为99)
- 成功数+1

**如果秒杀失败**:
- 检查Redis库存: `docker exec -it seckill-redis redis-cli GET seckill:stock:1`
- 查看秒杀服务日志
- 确认订单服务正常运行

### 测试4: AI智能分析

1. 在AI分析区域输入: "当前秒杀成功率如何?"
2. 点击"开始分析"
3. 等待3-5秒

**预期结果**:
- 显示AI回答
- 显示置信度(例如: 85.0%)
- 显示数据快照(JSON格式)

**如果AI无响应**:
- 检查Python服务是否运行
- 查看Python服务日志
- 确认DASHSCOPE_API_KEY已配置
- 测试API Key是否有效

### 测试5: 并发秒杀测试

使用Apache Bench进行压力测试:

```bash
# 发送1000个请求,100个并发
ab -n 1000 -c 100 -p seckill.json -T application/json \
   http://localhost:8080/api/seckill/do
```

**seckill.json内容**:
```json
{
  "userId": 999,
  "productId": 1,
  "quantity": 1
}
```

**观察**:
- 成功率应该在合理范围
- 不应该出现超卖(库存<0)
- 响应时间应该在可接受范围

## 🐛 常见问题速查

### Q1: Java服务启动报错 "Connection refused"

**原因**: Nacos未启动或连接失败

**解决**:
```bash
# 检查Nacos状态
docker ps | grep nacos

# 查看Nacos日志
docker logs seckill-nacos

# 重启Nacos
docker restart seckill-nacos
```

### Q2: Python服务报错 "ModuleNotFoundError"

**原因**: 依赖未安装或虚拟环境未激活

**解决**:
```bash
# 确认虚拟环境已激活
# Windows应该看到: (venv) C:\...
# Linux/Mac应该看到: (venv) user@host:...

# 重新安装依赖
pip install -r requirements.txt
```

### Q3: 前端报CORS错误

**原因**: 跨域请求被阻止

**解决**:
- 开发环境: Vite已配置代理,应该没问题
- 检查vite.config.ts中的proxy配置
- 确认Gateway允许跨域

### Q4: 秒杀总是提示"库存不足"

**原因**: Redis中库存为0或未初始化

**解决**:
```bash
# 检查Redis库存
docker exec -it seckill-redis redis-cli GET seckill:stock:1
docker exec -it seckill-redis redis-cli GET seckill:stock:2

# 重置库存
docker exec -it seckill-redis redis-cli SET seckill:stock:1 100
docker exec -it seckill-redis redis-cli SET seckill:stock:2 100

# 重启秒杀服务
```

### Q5: 前端页面样式混乱

**原因**: Element Plus CSS未正确加载

**解决**:
```bash
# 清除npm缓存
npm cache clean --force

# 删除node_modules重新安装
rm -rf node_modules
npm install
```

### Q6: Docker容器启动失败

**原因**: 端口冲突或资源不足

**解决**:
```bash
# 查看容器日志
docker logs seckill-mysql
docker logs seckill-redis

# 停止所有容器
docker-compose down

# 清理未使用的资源
docker system prune -a

# 重新启动
docker-compose up -d
```

## 📊 性能基准测试

### 单机性能参考

**硬件配置**: 
- CPU: 8核
- 内存: 16GB
- SSD硬盘

**预期性能**:
- 秒杀QPS: 2000-5000 req/s
- 平均响应时间: < 100ms
- P99响应时间: < 500ms
- AI分析响应: 2-5秒

**瓶颈分析**:
1. Redis单点: 可通过集群提升
2. 数据库写入: 可引入消息队列异步
3. AI调用: 外部API延迟,可增加缓存

## 🎓 学习路线

### 初学者路径

1. **第1天**: 阅读README和QUICKSTART
2. **第2天**: Docker方式部署,体验系统
3. **第3天**: 本地环境搭建,理解架构
4. **第4天**: 阅读核心代码(SeckillService)
5. **第5天**: 尝试修改前端界面
6. **第6天**: 添加新功能(例如:用户登录)
7. **第7天**: 性能优化实践

### 进阶路径

1. 研究Spring Boot 3新特性
2. 学习LangChain AI工作流
3. 实现分布式事务(Seata)
4. 引入消息队列(RocketMQ)
5. Kubernetes集群部署
6. 全链路监控(SkyWalking)

## 📞 获取帮助

1. **查阅文档**: README.md, QUICKSTART.md
2. **查看日志**: 各服务终端输出
3. **搜索Issue**: GitHub Issues
4. **提问**: 提供详细错误信息和日志

## ✨ 下一步行动

- [ ] 启动系统并验证所有功能
- [ ] 阅读核心代码理解架构
- [ ] 尝试修改一些配置
- [ ] 编写单元测试
- [ ] 部署到云服务器
- [ ] 分享给朋友 😊

---

**祝你使用愉快! 🎉**

如有任何问题,欢迎反馈!
