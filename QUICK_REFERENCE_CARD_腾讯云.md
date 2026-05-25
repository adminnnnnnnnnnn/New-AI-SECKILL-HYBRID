# 🚀 AI-Seckill-Hybrid 腾讯云部署 - 快速参考卡

## 📌 服务器信息
```
IP: 182.254.244.202
配置: 2核2G 3Mbps
系统: Ubuntu/CentOS
SSH: ssh root@182.254.244.202
```

---

## ⚡ 3步快速部署

### 第1步：上传代码（Windows）
```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid
scripts\upload-to-server.bat
# 输入服务器密码
```

### 第2步：部署服务（服务器）
```bash
ssh root@182.254.244.202
cd /opt/ai-seckill
unzip /opt/ai-seckill-upload.zip
chmod +x scripts/deploy-lightweight.sh
./scripts/deploy-lightweight.sh
# 等待10-15分钟
```

### 第3步：访问系统
```
前端: http://182.254.244.202:5173
API:  http://182.254.244.202:8080/swagger-ui.html
```

---

## 🔧 常用命令

### 服务管理
```bash
# 启动
./scripts/deploy-lightweight.sh

# 停止
./scripts/stop-lightweight.sh

# 查看状态
ps aux | grep java
free -h
```

### 日志查看
```bash
# Gateway日志
tail -f logs/gateway.log

# 所有日志
tail -f logs/*.log
```

### Docker管理
```bash
# 查看容器
docker ps

# 重启MySQL
docker-compose restart mysql

# 清理空间
docker system prune -f
```

---

## 🌐 端口说明

| 端口 | 服务 | 访问方式 |
|------|------|---------|
| 22 | SSH | ssh root@182.254.244.202 |
| 5173 | Vue前端 | http://182.254.244.202:5173 |
| 8080 | API网关 | http://182.254.244.202:8080 |
| 8081 | Product Service | 内网 |
| 8082 | Seckill Service | 内网 |
| 8084 | Order Service | 内网 |
| 8085 | User Service | 内网 |
| 3306 | MySQL | Docker内网 |
| 6379 | Redis | Docker内网 |

---

## ❗ 紧急处理

### 服务卡死
```bash
# 强制停止
./scripts/stop-lightweight.sh

# 重新启动
./scripts/deploy-lightweight.sh
```

### 内存不足
```bash
# 查看内存
free -h

# 增加Swap
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 无法访问
```bash
# 检查防火墙
sudo ufw status

# 开放端口
sudo ufw allow 5173/tcp
sudo ufw allow 8080/tcp
```

---

## 📚 文档索引

- **快速开始**: [README_腾讯云部署.md](README_腾讯云部署.md)
- **详细指南**: [DEPLOYMENT_2CORE_2GB.md](DEPLOYMENT_2CORE_2GB.md)
- **完整文档**: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **架构设计**: [ARCHITECTURE_CLOUD.md](ARCHITECTURE_CLOUD.md)

---

## 💡 提示

✅ **推荐操作**
- 定期清理日志：`rm logs/*.log`
- 监控内存使用：`free -h`
- 备份数据库：`docker exec seckill-mysql mysqldump -uroot -proot123456 seckill > backup.sql`

❌ **避免操作**
- 不要在服务器上编译Maven项目
- 不要同时启动太多服务
- 不要忘记清理Docker缓存

---

## 🎯 VSCode远程开发

```
1. 安装扩展: Remote - SSH
2. F1 → Remote-SSH: Connect to Host
3. 选择 tencent-server
4. 打开文件夹: /opt/ai-seckill
5. 开始使用Qoder辅助编程
```

---

**保存此文件，随时查阅！** 📌
