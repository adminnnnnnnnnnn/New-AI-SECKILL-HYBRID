# 🏗️ AI-Seckill-Hybrid 云端开发架构

## 系统架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    本地开发环境 (Windows)                      │
│                                                               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   VSCode     │◄──►│    Qoder     │◄──►│     Git      │   │
│  │              │    │   AI Assistant│    │              │   │
│  └──────┬───────┘    └──────────────┘    └──────┬───────┘   │
│         │                                       │            │
│         │ Remote SSH                            │ git push   │
│         ▼                                       ▼            │
└─────────┼───────────────────────────────────────┼────────────┘
          │                                       │
          │                                       │
          │                                       │
          ▼                                       ▼
┌─────────┼───────────────────────────────────────┼────────────┐
│         │        腾讯云服务器 (Ubuntu)           │            │
│         ▼                                       │            │
│  ┌──────────────┐                               │            │
│  │  /opt/ai-    │◄──────────────────────────────┘            │
│  │  seckill/    │  git pull                                   │
│  │              │                                             │
│  │  ├─ seckill-parent/  (Java微服务)                          │
│  │  │  ├─ seckill-gateway        :8080                        │
│  │  │  ├─ seckill-user-service   :8081                        │
│  │  │  ├─ seckill-product-service:8082                        │
│  │  │  ├─ seckill-order-service  :8083                        │
│  │  │  ├─ seckill-seckill-service:8084                        │
│  │  │  └─ seckill-inventory-service:8085                      │
│  │  │                                                         │
│  │  ├─ python-ai-agent/         :8000                         │
│  │  ├─ seckill-frontend/        :5173                         │
│  │  └─ scripts/                                               │
│  │     ├─ deploy.sh                                           │
│  │     ├─ stop.sh                                             │
│  │     └─ server-setup.sh                                     │
│  └──────┬──────────────────────────────────────────┐         │
│         │ Docker Containers                         │         │
│         ├───────────────────────────────────────────┤         │
│         │  MySQL  :3306                             │         │
│         │  Redis  :6379                             │         │
│         │  Nacos  :8848                             │         │
│         │  RocketMQ :9876                           │         │
│         └───────────────────────────────────────────┘         │
└─────────┬─────────────────────────────────────────────────────┘
          │
          │ HTTP/HTTPS
          ▼
┌─────────────────────────────────────────────────────────────┐
│                    用户访问                                    │
│                                                               │
│  浏览器 → http://服务器IP:5173  (前端界面)                     │
│       → http://服务器IP:8080  (API网关)                        │
│       → http://服务器IP:8848/nacos (Nacos控制台)               │
└─────────────────────────────────────────────────────────────┘
```

## 数据流向

### 1. 代码开发流程

```
开发者想法
    ↓
Qoder辅助生成代码 (在VSCode中)
    ↓
代码直接写入服务器文件 (/opt/ai-seckill/)
    ↓
Git提交并推送到GitHub/Gitee
    ↓
执行 ./scripts/deploy.sh
    ↓
服务重新部署
    ↓
用户访问新版本
```

### 2. 用户请求流程

```
用户浏览器
    ↓
http://服务器IP:5173 (Vue前端)
    ↓
前端调用 API → http://服务器IP:8080/api/xxx
    ↓
API Gateway (Spring Cloud Gateway)
    ↓
路由到对应微服务
    ├─ User Service (用户认证)
    ├─ Product Service (商品信息)
    ├─ Seckill Service (秒杀逻辑)
    └─ Order Service (订单处理)
    ↓
访问 MySQL / Redis
    ↓
返回结果给前端
```

### 3. AI分析流程

```
前端AI助手界面
    ↓
发送问题到 Python AI Agent (:8000)
    ↓
AI Agent分析
    ├─ 查询Redis缓存
    ├─ 调用Java微服务API
    └─ 使用LLM生成回答
    ↓
返回智能分析结果
```

## 技术栈总览

### 基础设施层
- **操作系统**: Ubuntu 22.04 LTS
- **容器化**: Docker + Docker Compose
- **服务发现**: Nacos 2.3.0
- **消息队列**: RocketMQ 5.1.4
- **分布式事务**: Seata 2.0.0

### 数据存储层
- **关系数据库**: MySQL 8.0
- **缓存**: Redis 7.x
- **向量数据库**: ChromaDB (Python AI)

### 后端服务层
- **Java微服务**: Spring Boot 3.2.3 + Spring Cloud 2023
- **ORM**: MyBatis-Plus 3.5.5
- **连接池**: Druid 1.2.21
- **分布式锁**: Redisson 3.27.0
- **熔断限流**: Resilience4j 2.1.0

### AI服务层
- **Web框架**: FastAPI 0.110.0
- **LLM**: 通义千问 (DashScope)
- **向量检索**: ChromaDB 0.4.24
- **LangChain**: 0.1.12

### 前端层
- **框架**: Vue 3.4+
- **语言**: TypeScript 5.x
- **构建工具**: Vite 5.x
- **UI组件**: Element Plus 2.6
- **状态管理**: Pinia 2.1
- **图表**: ECharts 5.5

### 开发工具层
- **IDE**: VSCode + Remote SSH
- **AI助手**: Qoder
- **版本控制**: Git
- **代码托管**: GitHub / Gitee

## 端口映射表

| 服务 | 容器端口 | 宿主机端口 | 用途 |
|------|---------|-----------|------|
| MySQL | 3306 | 3306 | 数据库 |
| Redis | 6379 | 6379 | 缓存 |
| Nacos | 8848 | 8848 | 服务注册中心 |
| RocketMQ NameServer | 9876 | 9876 | 消息队列 |
| RocketMQ Broker | 10911 | 10911 | 消息队列 |
| RocketMQ Console | 8080 | 8081 | MQ管理界面 |
| Seata | 8091 | 8091 | 分布式事务 |
| Python AI | 8000 | 8000 | AI智能分析 |
| API Gateway | 8080 | 8080 | 统一网关 |
| User Service | 8081 | - | 用户服务(内网) |
| Product Service | 8082 | - | 商品服务(内网) |
| Order Service | 8083 | - | 订单服务(内网) |
| Seckill Service | 8084 | - | 秒杀服务(内网) |
| Inventory Service | 8085 | - | 库存服务(内网) |
| Vue Frontend | 5173 | 5173 | 前端界面 |

## 资源需求评估

### 腾讯云服务器配置

**最低配置（测试环境）：**
- CPU: 4核
- 内存: 8GB
- 磁盘: 50GB SSD
- 带宽: 5Mbps
- 预估成本: ~200元/月

**推荐配置（生产环境）：**
- CPU: 8核
- 内存: 16GB
- 磁盘: 100GB SSD
- 带宽: 10Mbps
- 预估成本: ~400元/月

### 资源分配

```
总内存: 8GB
├─ MySQL: 1GB
├─ Redis: 512MB
├─ Nacos: 512MB
├─ Java微服务 (6个): 3GB (每个512MB)
├─ Python AI: 512MB
├─ Vue Frontend: 256MB
└─ 系统预留: 1.5GB
```

## 安全建议

### 1. 防火墙配置

```bash
# 只开放必要端口
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 5173/tcp  # 前端
sudo ufw allow 8080/tcp  # API网关
sudo ufw allow 8848/tcp  # Nacos
sudo ufw enable
```

### 2. 数据库安全

```bash
# MySQL只允许内网访问
# 在docker-compose.yml中移除ports映射，或使用内部网络

# 修改MySQL root密码
docker exec -it seckill-mysql mysql -uroot -p
ALTER USER 'root'@'%' IDENTIFIED BY '强密码';
FLUSH PRIVILEGES;
```

### 3. SSH安全

```bash
# 禁用密码登录，仅使用密钥
sudo vim /etc/ssh/sshd_config
# PasswordAuthentication no
# PubkeyAuthentication yes

sudo systemctl restart sshd
```

### 4. 定期更新

```bash
# 每周更新系统
sudo apt update && sudo apt upgrade -y

# 更新Docker镜像
docker-compose pull
docker-compose up -d
```

## 备份策略

### 自动化备份脚本

创建 `/opt/ai-seckill/scripts/backup.sh`：

```bash
#!/bin/bash
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 备份MySQL
docker exec seckill-mysql mysqldump -uroot -proot123456 seckill > \
  $BACKUP_DIR/mysql_$DATE.sql

# 备份Redis
docker exec seckill-redis redis-cli BGSAVE
sleep 5
cp /var/lib/docker/volumes/redis-data/_data/dump.rdb \
  $BACKUP_DIR/redis_$DATE.rdb

# 备份代码
cd /opt/ai-seckill
git bundle create $BACKUP_DIR/code_$DATE.bundle --all

# 删除7天前的备份
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.rdb" -mtime +7 -delete
find $BACKUP_DIR -name "*.bundle" -mtime +7 -delete

echo "备份完成: $DATE"
```

设置定时任务：
```bash
crontab -e
# 每天凌晨2点备份
0 2 * * * /opt/ai-seckill/scripts/backup.sh >> /var/log/backup.log 2>&1
```

## 监控告警

### 安装监控工具

```bash
# 安装Prometheus + Grafana（可选）
docker run -d --name prometheus -p 9090:9090 prom/prometheus
docker run -d --name grafana -p 3001:3000 grafana/grafana
```

### 关键指标监控

- CPU使用率 < 80%
- 内存使用率 < 85%
- 磁盘使用率 < 90%
- MySQL连接数 < 100
- Redis命中率 > 80%
- API响应时间 < 500ms

## 故障排查指南

### 常见问题及解决方案

| 问题 | 可能原因 | 解决方案 |
|------|---------|---------|
| 服务无法启动 | 端口被占用 | `netstat -tlnp \| grep 端口` 找到并杀死进程 |
| 内存不足 | JVM堆内存过大 | 调整 `-Xms` 和 `-Xmx` 参数 |
| 数据库连接失败 | MySQL未就绪 | `docker logs seckill-mysql` 查看日志 |
| 前端白屏 | npm依赖未安装 | `cd seckill-frontend && npm install` |
| Git推送失败 | 网络问题 | 配置代理或使用SSH方式 |
| Docker容器退出 | 配置文件错误 | `docker logs 容器ID` 查看详细错误 |

---

**架构设计完成！🎯**
