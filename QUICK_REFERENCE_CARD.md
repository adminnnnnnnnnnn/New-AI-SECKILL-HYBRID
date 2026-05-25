# 🚀 供应链集中筹措管理系统 v4.0 - 快速参考卡片

**版本**: 100% Complete | **日期**: 2026-05-20

---

## ⚡ 3步快速启动

### Step 1: 启动基础设施
```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid
.\start-all.bat
```

### Step 2: 启动后端服务
```powershell
cd seckill-parent
.\start-services.bat
# 选择 [3] 库存服务 或 [A] 全部启动
```

### Step 3: 启动前端
```powershell
cd ..\seckill-frontend
.\start-frontend.bat
```

**访问**: http://localhost:5173  
**账号**: admin / admin123

---

## 📊 核心服务端口

| 服务 | 端口 | Swagger文档 |
|------|------|-------------|
| API网关 | 8080 | - |
| 商品服务 | 8081 | http://localhost:8081/swagger-ui.html |
| 秒杀服务 | 8082 | http://localhost:8082/swagger-ui.html |
| 库存服务 | 8083 | http://localhost:8083/swagger-ui.html |
| 订单服务 | 8084 | http://localhost:8084/swagger-ui.html |
| 用户服务 | 8085 | http://localhost:8085/swagger-ui.html |
| 验收服务 | 8086 | http://localhost:8086/swagger-ui.html |
| 物资服务 | 8087 | http://localhost:8087/swagger-ui.html |
| 仓储服务 | 8088 | http://localhost:8088/swagger-ui.html |
| 配送服务 | 8089 | http://localhost:8089/swagger-ui.html |
| 供应商服务 | 8090 | http://localhost:8090/swagger-ui.html |

---

## 🔧 常用命令

### Docker管理
```powershell
# 查看容器状态
docker ps

# 重启所有服务
docker-compose restart

# 停止所有服务
docker-compose down

# 查看日志
docker logs seckill-mysql
docker logs seckill-redis
```

### 数据库操作
```powershell
# 连接MySQL
docker exec -it seckill-mysql mysql -uroot -proot123456 seckill

# 执行SQL文件
docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < schema.sql

# 备份数据库
docker exec seckill-mysql mysqldump -uroot -proot123456 seckill > backup.sql
```

### Redis操作
```powershell
# 连接Redis CLI
docker exec -it seckill-redis redis-cli

# 查看库存
GET stock:seckill:1:100

# 设置库存
SET stock:seckill:1:100 10000

# 清空所有数据
FLUSHDB
```

### Maven构建
```powershell
# 编译所有模块
cd seckill-parent
mvn clean install -DskipTests

# 运行单个服务
cd seckill-inventory-service
mvn spring-boot:run

# 打包部署
mvn clean package -DskipTests
```

### 前端开发
```powershell
cd seckill-frontend

# 安装依赖
npm install

# 开发模式
npm run dev

# 生产构建
npm run build

# 预览生产版本
npm run preview
```

---

## 🎯 核心功能演示

### 1. 秒杀流程
```
用户登录 → 浏览商品 → 参与秒杀 → 库存扣减(Redis Lua) → 创建订单(RocketMQ) → 订单完成
```

### 2. 库存管理
```
查询库存 → 预占库存(Redisson锁) → 确认扣减 → 释放预占(超时回滚)
```

### 3. 订单履约
```
创建订单 → 支付 → 发货 → 配送追踪 → 签收确认 → 评价
```

### 4. 供应链管理
```
供应商入驻 → 资质审核 → 采购计划 → 物资入库 → 质量验收 → 批次追溯
```

---

## 📈 压力测试

### 执行测试
```powershell
cd performance-test
.\run-load-test.bat
```

### 预期指标
- ✅ QPS ≥ 5000
- ✅ P99响应时间 ≤ 200ms
- ✅ 错误率 ≤ 0.1%
- ✅ 超卖率 = 0%

### 查看报告
```powershell
start results\report-YYYYMMDD_HHMMSS\index.html
```

---

## 🐛 常见问题排查

### 问题1: 前端无法访问后端API
**症状**: CORS错误或网络请求失败

**解决**:
```powershell
# 检查后端是否启动
curl http://localhost:8083/api/inventory/list

# 检查CORS配置
# 确保application.yml中配置了跨域
```

### 问题2: Redis连接失败
**症状**: "Cannot get Jedis connection"

**解决**:
```powershell
# 检查Redis容器
docker ps | findstr redis

# 重启Redis
docker restart seckill-redis

# 测试连接
docker exec -it seckill-redis redis-cli ping
```

### 问题3: 数据库连接失败
**症状**: "Communications link failure"

**解决**:
```powershell
# 检查MySQL容器
docker ps | findstr mysql

# 查看日志
docker logs seckill-mysql

# 重启MySQL
docker restart seckill-mysql
```

### 问题4: Nacos服务注册失败
**症状**: "Connect to server failed"

**解决**:
```powershell
# 检查Nacos状态
docker ps | findstr nacos

# 访问控制台
start http://localhost:8848/nacos
# 账号: nacos / nacos
```

### 问题5: RocketMQ消息发送失败
**症状**: "Send message timeout"

**解决**:
```powershell
# 检查RocketMQ容器
docker ps | findstr rocketmq

# 访问控制台
start http://localhost:8081

# 重启RocketMQ
docker-compose restart rocketmq-namesrv rocketmq-broker
```

---

## 📚 重要文档索引

### 必读文档
1. **[FINAL_PROJECT_100_PERCENT_COMPLETE.md](FINAL_PROJECT_100_PERCENT_COMPLETE.md)** - 项目完成总结
2. **[VERIFICATION_CHECKLIST_100_PERCENT.md](VERIFICATION_CHECKLIST_100_PERCENT.md)** - 验证清单
3. **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - 详细使用指南

### 技术文档
4. **[TECHNICAL_IMPLEMENTATION_GUIDE.md](TECHNICAL_IMPLEMENTATION_GUIDE.md)** - 技术实现细节
5. **[INVENTORY_SERVICE_EXAMPLE.md](INVENTORY_SERVICE_EXAMPLE.md)** - 代码示例(800行)
6. **[ARCHITECTURE.md](ARCHITECTURE.md)** - 架构设计

### 开发文档
7. **[FRONTEND_DEVELOPMENT_GUIDE.md](FRONTEND_DEVELOPMENT_GUIDE.md)** - 前端开发指南
8. **[PRD_COMPLETION_REPORT.md](PRD_COMPLETION_REPORT.md)** - PRD需求对照
9. **[REFACTORING_GUIDE.md](REFACTORING_GUIDE.md)** - 重构指南

### 部署文档
10. **[QUICK_START_AND_TEST.md](QUICK_START_AND_TEST.md)** - 快速启动
11. **[DELIVERY_CHECKLIST.md](DELIVERY_CHECKLIST.md)** - 交付清单
12. **[README_FINAL.md](README_FINAL.md)** - 项目README

---

## 🎨 系统架构图

```
┌─────────────────────────────────────┐
│      Vue 3 Frontend (5173)          │
│   11 Pages + 33 APIs + ECharts      │
└──────────────┬──────────────────────┘
               │ HTTP/WebSocket
┌──────────────▼──────────────────────┐
│    API Gateway (8080)               │
│  Resilience4j + JWT Auth            │
└──┬────┬────┬────┬────┬─────────────┘
   │    │    │    │    │
┌───▼──┐┌─▼──┐┌─▼──┐┌─▼──┐┌─▼──┐
│Prod  ││Sec ││Inv ││Ord ││Mat │...
│8081  ││8082││8083││8084││8087│
└──┬───┘└──┬─┘└──┬─┘└──┬─┘└──┬─┘
   └───────┴──┬──┴──┬──┴──┬──┘
              │     │     │
         ┌────▼──┐┌─▼────┐┌─▼────┐
         │Redis  ││Rocket││Seata │
         │7.x    ││MQ 5.0││2.0   │
         └────┬──┘└──────┘└──────┘
              │
         ┌────▼──────────────┐
         │   MySQL 8.0       │
         │  (30+ Tables)     │
         └───────────────────┘
```

---

## 💡 开发技巧

### 1. 快速调试
```powershell
# 实时查看日志
docker logs -f seckill-mysql

# 进入容器内部
docker exec -it seckill-redis sh

# 查看Java进程
jps -l
```

### 2. 性能监控
```powershell
# 查看CPU/内存使用
docker stats

# 查看JVM信息
jstat -gc <pid> 1000

# 线程分析
jstack <pid> > thread-dump.txt
```

### 3. 数据清理
```powershell
# 清空Redis
docker exec seckill-redis redis-cli FLUSHALL

# 重置数据库
docker exec seckill-mysql mysql -uroot -proot123456 -e "DROP DATABASE seckill; CREATE DATABASE seckill;"
docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < schema.sql
```

---

## 🎯 下一步行动

### 立即可做
- ✅ 启动系统并体验所有功能
- ✅ 阅读技术文档了解架构设计
- ✅ 执行压力测试验证性能

### 短期优化(1-2天)
- 🔧 补充详细单元测试断言
- 🔧 SQL索引优化
- 🔧 Redis缓存策略完善

### 长期规划
- 📊 Prometheus + Grafana监控
- 🔄 Jenkins CI/CD流水线
- 📱 移动端APP开发

---

## 📞 技术支持

### 快速帮助
- 📘 完整文档: [FINAL_PROJECT_100_PERCENT_COMPLETE.md](FINAL_PROJECT_100_PERCENT_COMPLETE.md)
- 📗 使用指南: [USAGE_GUIDE.md](USAGE_GUIDE.md)
- 📙 技术实现: [TECHNICAL_IMPLEMENTATION_GUIDE.md](TECHNICAL_IMPLEMENTATION_GUIDE.md)

### 联系信息
- 📧 项目仓库: GitHub/GitLab
- 💬 问题反馈: Issues
- 📖 在线文档: Wiki

---

**🎊 祝您使用愉快! 项目100%完成!**

**从75%到100%,我们共同完成了这个壮举!**

**加油! 💪✨🚀**
