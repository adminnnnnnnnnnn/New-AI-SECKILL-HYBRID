u# 🚀 AI-Seckill-Hybrid 腾讯云服务器�?�?G）快速部署指�?

## 📋 服务器信�?

- **服务器IP**: `YOUR_SERVER_IP`
- **配置**: 2�?CPU, 2GB 内存, 3Mbps 带宽
- **系统**: Ubuntu/CentOS
- **地域**: 上海二区

---

## ⚠️ 重要说明

由于你的服务器只�?**2GB 内存**，我们需要进行特殊优化：

### 优化策略
1. �?**增加Swap空间**：创�?GB虚拟内存缓解压力
2. �?**限制JVM堆内�?*：每个服务最�?56MB
3. �?**精简服务数量**：仅启动核心服务（网�?4个微服务�?
4. �?**禁用Nacos**：使用本地配置，节省500MB内存
5. �?**不启动Python AI**：暂时禁用，节省512MB内存

### 启动的服务列�?
- �?MySQL (数据�?
- �?Redis (缓存)
- �?API Gateway (8080)
- �?User Service (8085)
- �?Product Service (8081)
- �?Order Service (8084)
- �?Seckill Service (8082)
- �?Vue Frontend (5173)

### 禁用的服�?
- �?Nacos (太耗内�?
- �?Python AI Agent (太耗内�?
- �?Inventory/Material/Warehouse等其他服�?

---

## 🎯 快速开始（5步完成）

### �?步：SSH登录服务�?

在你的Windows电脑上打开PowerShell或Git Bash�?

```powershell
ssh root@YOUR_SERVER_IP
# 输入密码（腾讯云控制台获取）
```

### �?步：安装基础环境

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Docker
sudo apt install -y docker.io docker-compose

# 启动Docker
sudo systemctl start docker
sudo systemctl enable docker

# 安装Java 17
sudo apt install -y openjdk-17-jdk maven

# 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
sudo apt install -y nodejs

# 安装Git
sudo apt install -y git

# 验证安装
docker --version
java -version
node -v
git --version
```

### �?步：克隆代码并初始化

```bash
# 创建项目目录
mkdir -p /opt/ai-seckill
cd /opt/ai-seckill

# 初始化Git仓库
git init

# 配置Git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# 添加远程仓库（如果你有GitHub/Gitee仓库�?
# git remote add origin https://github.com/你的用户�?ai-seckill-hybrid.git
# git pull origin main

# 如果没有远程仓库，从本地上传
# 在Windows上执行：
# scp -r c:\Users\dell\Desktop\ai-seckill-hybrid\* root@YOUR_SERVER_IP:/opt/ai-seckill/
```

**上传代码的两种方式：**

**方式A：使用SCP上传（推荐）**

在Windows PowerShell中执行：

```powershell
# 压缩项目（排除不必要的文件）
cd c:\Users\dell\Desktop\ai-seckill-hybrid

# 使用tar压缩（需要Git Bash或WSL�?
tar -czf ai-seckill.tar.gz `
  --exclude=node_modules `
  --exclude=target `
  --exclude=.git `
  --exclude=__pycache__ `
  --exclude=venv `
  .

# 上传到服务器
scp ai-seckill.tar.gz root@YOUR_SERVER_IP:/opt/

# 在服务器上解�?
ssh root@YOUR_SERVER_IP
cd /opt/ai-seckill
tar -xzf /opt/ai-seckill.tar.gz
```

**方式B：使用Git推�?*

```powershell
# 在Windows�?
cd c:\Users\dell\Desktop\ai-seckill-hybrid
git init
git add .
git commit -m "Initial commit"

# 创建GitHub私有仓库
git remote add origin https://github.com/你的用户�?ai-seckill-hybrid.git
git push -u origin main

# 在服务器上拉�?
ssh root@YOUR_SERVER_IP
cd /opt/ai-seckill
git clone https://github.com/你的用户�?ai-seckill-hybrid.git .
```

### �?步：执行轻量级部�?

```bash
# 进入项目目录
cd /opt/ai-seckill

# 赋予脚本执行权限
chmod +x scripts/deploy-lightweight.sh
chmod +x scripts/stop-lightweight.sh

# 执行部署（大约需�?0-15分钟�?
./scripts/deploy-lightweight.sh
```

**部署过程会自动完成：**
1. 创建4GB Swap空间
2. 启动MySQL和Redis
3. 初始化数据库
4. 编译Java项目
5. 启动5个核心微服务
6. 构建并启动前�?

### �?步：验证部署

```bash
# 查看服务状�?
ps aux | grep java

# 查看日志
tail -f logs/gateway.log

# 检查端口占�?
netstat -tlnp | grep -E '8080|8081|8082|8084|8085|5173'

# 查看内存使用
free -h
```

**在浏览器访问�?*
- 前端界面: http://YOUR_SERVER_IP:5173
- API文档: http://YOUR_SERVER_IP:8080/swagger-ui.html

---

## 🔧 配置优化详解

### JVM参数优化

每个Java服务使用以下参数�?

```bash
-Xms128m          # 初始堆内�?28MB
-Xmx256m          # 最大堆内存256MB
-XX:+UseSerialGC  # 使用串行GC（适合小内存）
-XX:TieredStopAtLevel=1  # 简化JIT编译
```

### Swap配置

```bash
# 创建4GB Swap文件
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# 设置swappiness�?0（尽量使用物理内存）
sysctl vm.swappiness=10
```

### Docker优化

```bash
# 清理未使用的镜像和容�?
docker system prune -f

# 限制容器资源（如果需要）
docker run --memory=512m --cpus=0.5 mysql:8.0
```

---

## 📊 内存分配方案

```
总内�? 2GB
├─ 系统预留: 300MB
├─ Swap: 4GB (虚拟内存)
├─ MySQL: 300MB
├─ Redis: 100MB
├─ Gateway: 256MB
├─ User Service: 256MB
├─ Product Service: 256MB
├─ Order Service: 256MB
└─ Seckill Service: 256MB
   └─ 总计: ~1.9GB (接近满载)
```

---

## 🛠�?常用操作命令

### 查看服务状�?

```bash
# 查看所有Java进程
ps aux | grep java

# 查看特定服务日志
tail -f logs/gateway.log
tail -f logs/user-service.log
tail -f logs/product-service.log
tail -f logs/order-service.log
tail -f logs/seckill-service.log

# 查看Docker容器
docker ps

# 查看内存使用
free -h

# 查看磁盘空间
df -h
```

### 重启服务

```bash
# 停止所有服�?
./scripts/stop-lightweight.sh

# 重新启动
./scripts/deploy-lightweight.sh

# 或单独重启某个服�?
kill $(cat /tmp/gateway.pid)
nohup java -Xms128m -Xmx256m -jar seckill-parent/seckill-gateway/target/seckill-gateway-2.0.0.jar > logs/gateway.log 2>&1 &
echo $! > /tmp/gateway.pid
```

### 查看实时日志

```bash
# Gateway日志
tail -f logs/gateway.log

# 所有服务日志（多窗口）
tail -f logs/*.log
```

---

## �?常见问题排查

### Q1: 服务启动失败，提示OOM（内存不足）

```bash
# 检查内存使�?
free -h

# 如果内存不足，尝试：
# 1. 停止不必要的服务
./scripts/stop-lightweight.sh

# 2. 清理Docker缓存
docker system prune -f

# 3. 增加Swap空间
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 4. 重新启动
./scripts/deploy-lightweight.sh
```

### Q2: 前端无法访问

```bash
# 检查前端是否运�?
ps aux | grep serve

# 查看前端日志
tail -f logs/frontend.log

# 重启前端
kill $(cat /tmp/frontend.pid)
cd seckill-frontend
nohup serve -s dist -l 5173 > ../logs/frontend.log 2>&1 &
echo $! > /tmp/frontend.pid
```

### Q3: 数据库连接失�?

```bash
# 检查MySQL是否运行
docker ps | grep mysql

# 查看MySQL日志
docker logs seckill-mysql

# 重启MySQL
docker-compose restart mysql
```

### Q4: 编译时内存不�?

```bash
# Maven编译时增加内�?
export MAVEN_OPTS="-Xmx512m"
mvn clean install -DskipTests

# 或者分模块编译
mvn install -pl seckill-common -am -DskipTests
mvn install -pl seckill-gateway -am -DskipTests
# ... 逐个编译
```

### Q5: 服务器响应很�?

```bash
# 检查CPU使用
top

# 检查网络带�?
iftop

# 可能原因�?
# 1. 3Mbps带宽较小，建议升�?
# 2. 内存不足导致频繁Swap
# 3. 考虑升级�?�?G配置
```

---

## 🎯 VSCode远程开发配�?

虽然服务器配置较低，但你仍然可以使用VSCode Remote SSH进行开发：

### 配置步骤

1. **在Windows上配置SSH**

编辑 `C:\Users\你的用户名\.ssh\config`�?

```
Host tencent-server
    HostName YOUR_SERVER_IP
    User root
    Port 22
    ForwardAgent yes
```

2. **连接服务�?*

- 打开VSCode
- �?`F1` �?`Remote-SSH: Connect to Host...`
- 选择 `tencent-server`
- 输入密码

3. **打开项目**

- 文件 �?打开文件�?
- 选择 `/opt/ai-seckill`

4. **注意事项**

⚠️ **由于服务器只�?GB内存，建议：**
- 不要在服务器上运行完整的Maven编译
- 在本地编译好后上传jar�?
- 避免同时打开太多文件
- 定期清理日志文件

---

## 💡 性能优化建议

### 1. 定期清理日志

```bash
# 创建清理脚本
cat > /opt/ai-seckill/scripts/clean-logs.sh << 'EOF'
#!/bin/bash
cd /opt/ai-seckill/logs
find . -name "*.log" -size +10M -delete
echo "日志清理完成"
EOF

chmod +x /opt/ai-seckill/scripts/clean-logs.sh

# 添加到crontab（每周清理）
crontab -e
0 0 * * 0 /opt/ai-seckill/scripts/clean-logs.sh
```

### 2. 监控内存使用

```bash
# 创建监控脚本
cat > /opt/ai-seckill/scripts/monitor.sh << 'EOF'
#!/bin/bash
echo "=== 系统资源监控 ==="
echo "内存使用:"
free -h
echo ""
echo "磁盘使用:"
df -h /
echo ""
echo "Java进程:"
ps aux | grep java | grep -v grep
echo ""
echo "Docker容器:"
docker ps --format "table {{.Names}}\t{{.Status}}"
EOF

chmod +x /opt/ai-seckill/scripts/monitor.sh

# 随时查看
./scripts/monitor.sh
```

### 3. 升级建议

如果使用过程中发现性能不足，建议升级到�?

| 配置 | 月费 | 优势 |
|------|------|------|
| 当前: 2�?G | ~75�?| 勉强可用 |
| 推荐: 4�?G | ~150�?| 流畅运行所有服�?|
| 理想: 4�?G | ~200�?| 可运行全部微服务+AI |

---

## 📝 日常维护清单

### 每日检�?
- [ ] 查看服务是否正常：`ps aux | grep java`
- [ ] 检查内存使用：`free -h`
- [ ] 查看错误日志：`tail -100 logs/*.log`

### 每周维护
- [ ] 清理日志文件
- [ ] 清理Docker缓存：`docker system prune -f`
- [ ] 备份数据�?

### 每月维护
- [ ] 更新系统补丁：`apt update && apt upgrade -y`
- [ ] 检查磁盘空间：`df -h`
- [ ] 审查安全日志

---

## 🚨 紧急情况处�?

### 服务器完全卡�?

```bash
# 1. 通过腾讯云控制台重启服务�?

# 2. 重启后重新部�?
ssh root@YOUR_SERVER_IP
cd /opt/ai-seckill
./scripts/deploy-lightweight.sh
```

### 数据丢失

```bash
# 恢复数据库备�?
docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < backup.sql
```

---

## 📞 获取帮助

- 📖 完整文档: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- 🐛 问题反馈: GitHub Issues
- 💬 AI助手: 使用Qoder

---

## �?部署检查清�?

```
部署前：
�?已购买腾讯云服务器（2�?G�?
�?已记录服务器IP�?82.254.244.202
�?已配置安全组（开�?2/80/5173/8080端口�?
�?已从腾讯云获取root密码

部署中：
�?已通过SSH登录服务�?
�?已安装Docker、Java、Node.js
�?已上传项目代码到 /opt/ai-seckill
�?已执�?./scripts/deploy-lightweight.sh
�?部署过程无报�?

部署后：
�?MySQL和Redis正常运行
�?5个Java服务已启�?
�?前端可以访问：http://YOUR_SERVER_IP:5173
�?API文档可以访问：http://YOUR_SERVER_IP:8080/swagger-ui.html
�?内存使用正常（free -h�?
�?已配置VSCode Remote SSH

完成！�?
```

---

**祝你部署顺利！如果遇到任何问题，随时询问Qoder。🚀**
