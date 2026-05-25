# 🚀 AI-Seckill-Hybrid 本地运行指南

## ✅ 当前运行状态（最后更新：2026-05-22）

所有服务已成功启动并正常运行！

### 📊 服务端口总览

| 服务名称 | 端口 | 访问地址 | 状态 |
|---------|------|---------|------|
| **Vue前端页面** | 3000 | http://localhost:3000 | ✅ 运行中 |
| **Gateway网关** | 8080 | http://localhost:8080 | ✅ 运行中 |
| **User用户服务** | 8081 | http://localhost:8081 | ✅ 运行中 |
| **Product商品服务** | 8082 | http://localhost:8082 | ✅ 运行中 |
| **Order订单服务** | 8083 | http://localhost:8083 | ✅ 运行中 |
| **Seckill秒杀服务** | 8084 | http://localhost:8084 | ✅ 运行中 |
| **MySQL数据库** | 3307 | localhost:3307 | ✅ Docker运行 |
| **Redis缓存** | 6379 | localhost:6379 | ✅ Docker运行 |

---

## 🎯 快速访问

### 1️⃣ 前端页面（主要入口）
```
http://localhost:3000
```
这是你使用系统的主要界面，可以进行：
- 用户注册/登录
- 浏览商品列表
- 参与秒杀活动
- 查看订单记录

### 2️⃣ API文档（开发者用）
```
http://localhost:8080/swagger-ui.html
```
通过Gateway统一访问所有微服务的API文档。

---

## 🔧 启动命令参考

### 前置条件检查

确保Docker容器已启动：
```powershell
docker ps
```

应该看到 `seckill-mysql` 和 `seckill-redis` 两个容器在运行。

### 启动后端服务

```powershell
# 进入项目目录
cd c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-parent

# 设置Java环境
$env:JAVA_HOME="D:\Java"
$env:Path="D:\Java\bin;$env:Path"

# 依次启动5个微服务（每个在新窗口运行）
Start-Process java -ArgumentList "-Xms256m","-Xmx512m","-jar","seckill-gateway\target\seckill-gateway-2.0.0.jar"
Start-Sleep -Seconds 5

Start-Process java -ArgumentList "-Xms256m","-Xmx512m","-jar","seckill-user-service\target\seckill-user-service-2.0.0.jar"
Start-Sleep -Seconds 5

Start-Process java -ArgumentList "-Xms256m","-Xmx512m","-jar","seckill-product-service\target\seckill-product-service-2.0.0.jar"
Start-Sleep -Seconds 5

Start-Process java -ArgumentList "-Xms256m","-Xmx512m","-jar","seckill-order-service\target\seckill-order-service-2.0.0.jar"
Start-Sleep -Seconds 5

Start-Process java -ArgumentList "-Xms256m","-Xmx512m","-jar","seckill-seckill-service\target\seckill-seckill-service-2.0.0.jar"
```

### 启动前端服务

```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-frontend
npm run dev
```

前端将在 http://localhost:3000 自动打开。

---

## 🛑 停止服务

### 停止所有Java进程
```powershell
Get-Process | Where-Object {$_.ProcessName -eq "java"} | Stop-Process -Force
```

### 停止前端服务
在前端运行的终端窗口按 `Ctrl + C`

### 停止Docker容器（可选）
```powershell
docker stop seckill-mysql seckill-redis
```

---

## 🔍 故障排查

### 问题1：端口被占用

**症状**：启动时报错 `Address already in use`

**解决**：
```powershell
# 查找占用端口的进程
netstat -ano | Select-String ":8080"

# 强制终止进程（替换PID为实际值）
Stop-Process -Id <PID> -Force
```

### 问题2：数据库连接失败

**症状**：服务启动时报 `Communications link failure`

**解决**：
```powershell
# 检查MySQL容器是否运行
docker ps | Select-String "mysql"

# 如果未运行，启动容器
docker start seckill-mysql

# 验证数据库是否存在
docker exec seckill-mysql mysql -uroot -proot123456 -e "SHOW DATABASES;"
```

### 问题3：Redis连接失败

**症状**：报错 `Cannot connect to Redis`

**解决**：
```powershell
# 检查Redis容器
docker ps | Select-String "redis"

# 测试Redis连接
docker exec seckill-redis redis-cli ping
# 应返回 PONG
```

### 问题4：前端无法访问后端

**症状**：前端页面空白或API调用失败

**解决**：
1. 检查Gateway是否在8080端口运行
2. 确认前端配置文件中的API地址指向 `http://localhost:8080`
3. 浏览器F12查看控制台错误信息

---

## 📝 重要说明

### 已修复的问题

1. ✅ **Spring Boot插件缺失** - 所有微服务已添加可执行JAR打包支持
2. ✅ **MyBatis映射错误** - OrderService的XML映射已修正
3. ✅ **Jakarta命名空间** - 所有javax.*已改为jakarta.*（适配Spring Boot 3）
4. ✅ **分布式组件临时禁用** - RocketMQ和Seata已注释，系统可独立运行

### 当前限制

- ⚠️ RocketMQ消息队列未启用（订单超时取消功能暂不可用）
- ⚠️ Seata分布式事务未启用（跨服务事务使用本地@Transactional）
- ⚠️ Nacos服务注册已禁用（服务间直接通过localhost调用）
- ⚠️ Python AI Agent未启动（智能分析功能暂不可用）

### 性能优化建议

如需提升性能，可以：
1. 调整JVM参数（当前为-Xms256m -Xmx512m）
2. 启用Redis集群模式
3. 引入消息队列处理异步任务
4. 配置Nginx反向代理和负载均衡

---

## 🎓 学习路径

### 新手入门
1. 访问 http://localhost:3000 体验前端功能
2. 查看 `seckill-frontend/src/views/` 了解页面结构
3. 阅读 `README.md` 了解项目整体架构

### 开发者深入
1. 研究Gateway路由配置：`seckill-gateway/src/main/resources/application.yml`
2. 分析秒杀核心逻辑：`seckill-seckill-service/src/main/java/com/seckill/seckill/service/`
3. 查看数据库表结构：`seckill-parent/schema.sql`

### 运维部署
1. 参考 `DEPLOYMENT_GUIDE.md` 了解完整部署流程
2. 使用 `docker-compose.yml` 一键部署生产环境
3. 配置监控告警（Prometheus + Grafana）

---

## 📞 获取帮助

如遇到问题：
1. 查看各服务的控制台日志
2. 检查 `QUICK_REFERENCE_CARD.md` 快速参考
3. 查阅项目根目录下的各类文档

---

**祝使用愉快！** 🎉

*文档最后更新：2026-05-22 12:00*
