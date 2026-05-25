# 📚 AI-Seckill-Hybrid 部署文档索引

## 🎯 快速导航

### 🚀 新手入门（必读）
1. **[快速开始清单](QUICK_START_DEPLOYMENT.md)** - 按步骤操作的checklist
2. **[完整部署指南](DEPLOYMENT_GUIDE.md)** - 详细的部署说明和最佳实践

### 🏗️ 架构设计
3. **[云端架构文档](ARCHITECTURE_CLOUD.md)** - 系统架构图、技术栈、资源规划

### 🛠️ 工具脚本
4. **服务器初始化**: `scripts/server-setup.sh`
5. **一键部署**: `scripts/deploy.sh`
6. **停止服务**: `scripts/stop.sh`
7. **环境检查**: `scripts/check-local-env.bat`
8. **SSH配置示例**: `scripts/vscode-ssh-config.example`

---

## 📖 使用指南

### 场景1：首次部署到腾讯云

```bash
# 第1步：阅读快速开始清单
打开 QUICK_START_DEPLOYMENT.md

# 第2步：购买并配置腾讯云服务器
- 选择4核8G配置
- 开放必要端口（22/80/443/5173/8080/8848）

# 第3步：在服务器上执行
ssh root@你的服务器IP
curl -o setup.sh https://raw.githubusercontent.com/你的用户名/ai-seckill-hybrid/main/scripts/server-setup.sh
chmod +x setup.sh
sudo ./setup.sh

# 第4步：克隆代码并部署
cd /opt/ai-seckill
git clone https://github.com/你的用户名/ai-seckill-hybrid.git .
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# 第5步：访问系统
浏览器打开: http://你的服务器IP:5173
```

### 场景2：本地VSCode远程开发

```bash
# 第1步：安装VSCode扩展
- Remote - SSH

# 第2步：配置SSH连接
编辑 C:\Users\你的用户名\.ssh\config
添加服务器信息

# 第3步：连接服务器
F1 → Remote-SSH: Connect to Host → 选择 ai-seckill

# 第4步：打开项目
文件 → 打开文件夹 → /opt/ai-seckill

# 第5步：开始开发
- 使用Qoder辅助编程
- 在终端测试代码
- Git提交并推送
- 执行 ./scripts/deploy.sh 部署
```

### 场景3：日常维护和更新

```bash
# 查看服务状态
screen -ls
docker ps

# 查看日志
screen -r gateway
docker-compose logs -f

# 更新代码
cd /opt/ai-seckill
git pull origin main

# 重新部署
./scripts/deploy.sh

# 备份数据
./scripts/backup.sh
```

---

## 🔧 常用命令速查

### Git操作
```bash
# 查看状态
git status

# 提交代码
git add .
git commit -m "描述"
git push origin main

# 拉取最新代码
git pull origin main
```

### Docker操作
```bash
# 查看所有容器
docker ps -a

# 查看日志
docker logs 容器ID -f

# 重启容器
docker-compose restart 服务名

# 停止所有容器
docker-compose down
```

### Screen会话管理
```bash
# 查看所有会话
screen -ls

# 连接到会话
screen -r gateway

# 退出会话（保持运行）
Ctrl+A, 然后按 D

# 终止会话
screen -S gateway -X quit
```

### 系统监控
```bash
# CPU和内存
htop

# 磁盘空间
df -h

# 网络端口
netstat -tlnp

# Docker资源
docker stats
```

---

## 📊 服务端口对照表

| 服务 | 端口 | 访问方式 |
|------|------|---------|
| Vue前端 | 5173 | http://服务器IP:5173 |
| API网关 | 8080 | http://服务器IP:8080 |
| Nacos控制台 | 8848 | http://服务器IP:8848/nacos |
| Python AI | 8000 | http://服务器IP:8000/docs |
| MySQL | 3306 | 仅内网访问 |
| Redis | 6379 | 仅内网访问 |

**默认账号密码：**
- Nacos: nacos / nacos
- MySQL: root / root123456

---

## ❓ 常见问题

### Q1: 如何修改服务器配置？
```bash
# 编辑配置文件
vim /opt/ai-seckill/seckill-parent/seckill-gateway/src/main/resources/application.yml

# 重启服务
screen -S gateway -X quit
screen -dmS gateway bash -c "cd /opt/ai-seckill/seckill-parent/seckill-gateway && mvn spring-boot:run"
```

### Q2: 如何查看Java服务日志？
```bash
# 方式1: 通过screen
screen -r gateway

# 方式2: 查看日志文件
tail -f /opt/ai-seckill/seckill-parent/seckill-gateway/logs/app.log

# 方式3: 通过Docker（如果使用docker-compose）
docker-compose logs -f gateway
```

### Q3: 数据库如何备份？
```bash
# 手动备份
docker exec seckill-mysql mysqldump -uroot -proot123456 seckill > backup.sql

# 恢复备份
docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < backup.sql
```

### Q4: 如何增加服务器内存？
```bash
# 增加Swap空间
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 验证
free -h
```

### Q5: Qoder如何在远程环境中工作？
```
1. VSCode通过Remote SSH连接服务器
2. Qoder插件在本地VSCode中运行
3. Qoder可以访问远程文件系统
4. 所有代码修改直接应用到服务器
5. 无需手动同步文件
```

---

## 🎓 学习资源

### 官方文档
- [Spring Boot 3](https://spring.io/projects/spring-boot)
- [Vue 3](https://vuejs.org/)
- [Docker](https://docs.docker.com/)
- [VSCode Remote SSH](https://code.visualstudio.com/docs/remote/ssh)

### 相关文档
- [项目架构说明](ARCHITECTURE.md)
- [前端开发指南](FRONTEND_DEVELOPMENT_GUIDE.md)
- [技术实现指南](TECHNICAL_IMPLEMENTATION_GUIDE.md)

---

## 📞 获取帮助

- 📖 查看详细文档: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- 🐛 报告问题: GitHub Issues
- 💬 技术咨询: 使用Qoder助手

---

## 📝 文档更新记录

| 日期 | 版本 | 更新内容 |
|------|------|---------|
| 2026-05-21 | v1.0 | 初始版本，包含完整部署指南 |

---

**Happy Coding! 🚀**
