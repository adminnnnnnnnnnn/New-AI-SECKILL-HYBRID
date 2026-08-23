# 🎯 AI-Seckill-Hybrid 腾讯云部�?- 完整操作手册

## 📌 你的服务器信�?

- **IP地址**: `YOUR_SERVER_IP`
- **配置**: 2�?CPU, 2GB 内存, 3Mbps 带宽
- **系统**: Ubuntu/CentOS（腾讯云�?
- **地域**: 上海二区
- **实例ID**: YOUR_INSTANCE_ID

---

## 🚀 超快速部署（3步完成）

### �?方式一：自动化脚本（推荐）

#### �?步：在Windows上上传代�?

双击运行�?
```
scripts\upload-to-server.bat
```

输入服务器密码后自动上传�?

#### �?步：SSH登录并部�?

```bash
# 登录服务�?
ssh root@YOUR_SERVER_IP

# 解压并部�?
cd /opt
mkdir -p ai-seckill
cd ai-seckill
unzip /opt/ai-seckill-upload.zip

# 赋予权限并执行部�?
chmod +x scripts/deploy-lightweight.sh
./scripts/deploy-lightweight.sh
```

等待10-15分钟，部署完成！

#### �?步：访问系统

浏览器打开�?
- **前端**: http://YOUR_SERVER_IP:5173
- **API**: http://YOUR_SERVER_IP:8080/swagger-ui.html

---

### �?方式二：手动部署（详细步骤）

如果自动化脚本失败，按以下步骤手动操作：

#### 步骤1：SSH登录服务�?

```powershell
# Windows PowerShell
ssh root@YOUR_SERVER_IP
# 输入腾讯云控制台的root密码
```

#### 步骤2：安装基础环境

```bash
# 更新系统
apt update && apt upgrade -y

# 安装Docker
apt install -y docker.io docker-compose
systemctl start docker
systemctl enable docker

# 安装Java 17
apt install -y openjdk-17-jdk maven

# 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# 验证
docker --version
java -version
node -v
```

#### 步骤3：上传代�?

**方式A：使用Git（如果你有GitHub仓库�?*

```bash
# 在服务器�?
mkdir -p /opt/ai-seckill
cd /opt/ai-seckill
git clone https://github.com/你的用户�?ai-seckill-hybrid.git .
```

**方式B：使用SCP从Windows上传**

在Windows PowerShell中：

```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid

# 压缩项目
tar -czf project.tar.gz --exclude=node_modules --exclude=target --exclude=.git .

# 上传
scp project.tar.gz root@YOUR_SERVER_IP:/opt/

# 在服务器上解�?
ssh root@YOUR_SERVER_IP
cd /opt
mkdir -p ai-seckill
cd ai-seckill
tar -xzf /opt/project.tar.gz
```

#### 步骤4：执行轻量级部署

```bash
cd /opt/ai-seckill

# 赋予执行权限
chmod +x scripts/deploy-lightweight.sh
chmod +x scripts/stop-lightweight.sh

# 开始部署（需�?0-15分钟�?
./scripts/deploy-lightweight.sh
```

#### 步骤5：验证部�?

```bash
# 查看服务状�?
ps aux | grep java

# 查看日志
tail -f logs/gateway.log

# 检查端�?
netstat -tlnp | grep -E '8080|5173'
```

浏览器访问测试：
- http://YOUR_SERVER_IP:5173

---

## 📚 完整文档索引

### 核心文档

1. **[DEPLOYMENT_2CORE_2GB.md](DEPLOYMENT_2CORE_2GB.md)** �?
   - **针对2�?G配置的详细指�?*
   - 包含所有优化策略和故障排查

2. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)**
   - 通用部署指南（适用于更高配置）

3. **[QUICK_START_DEPLOYMENT.md](QUICK_START_DEPLOYMENT.md)**
   - 快速开始清�?

4. **[ARCHITECTURE_CLOUD.md](ARCHITECTURE_CLOUD.md)**
   - 云端架构设计

5. **[CLOUD_DEPLOYMENT_SUMMARY.md](CLOUD_DEPLOYMENT_SUMMARY.md)**
   - 部署方案总结

### 工具脚本

位于 `scripts/` 目录�?

| 脚本 | 用�?| 执行位置 |
|------|------|---------|
| `deploy-lightweight.sh` | 轻量级部署（2�?G专用�?| 服务�?|
| `stop-lightweight.sh` | 停止轻量级服�?| 服务�?|
| `deploy.sh` | 完整部署�?�?G+�?| 服务�?|
| `stop.sh` | 停止完整服务 | 服务�?|
| `server-setup.sh` | 服务器环境初始化 | 服务�?|
| `upload-to-server.bat` | 上传代码到服务器 | Windows |
| `check-local-env.bat` | 检查本地环�?| Windows |

---

## 🔧 关键配置说明

### 为什么需要轻量级部署�?

你的服务器只�?**2GB 内存**，而完整部署需要约 **6-8GB**�?

| 服务 | 完整部署内存 | 轻量级部�?|
|------|------------|-----------|
| MySQL | 512MB | 300MB �?|
| Redis | 256MB | 100MB �?|
| Nacos | 512MB | �?禁用 |
| Gateway | 512MB | 256MB �?|
| User Service | 512MB | 256MB �?|
| Product Service | 512MB | 256MB �?|
| Order Service | 512MB | 256MB �?|
| Seckill Service | 512MB | 256MB �?|
| Inventory Service | 512MB | �?禁用 |
| Python AI | 512MB | �?禁用 |
| 其他服务 | 2GB | �?禁用 |
| **总计** | **~6.5GB** | **~1.4GB** �?|

通过以下优化，使系统能在2GB内存上运行：
1. �?增加4GB Swap虚拟内存
2. �?限制JVM堆内存为256MB/服务
3. �?禁用非核心服�?
4. �?使用串行GC减少内存开销

---

## 🛠�?常用命令速查

### 服务管理

```bash
# 启动服务
cd /opt/ai-seckill
./scripts/deploy-lightweight.sh

# 停止服务
./scripts/stop-lightweight.sh

# 重启单个服务
kill $(cat /tmp/gateway.pid)
nohup java -Xms128m -Xmx256m -jar seckill-parent/seckill-gateway/target/seckill-gateway-2.0.0.jar > logs/gateway.log 2>&1 &
echo $! > /tmp/gateway.pid
```

### 日志查看

```bash
# Gateway日志
tail -f logs/gateway.log

# 所有服务日�?
tail -f logs/*.log

# 最�?00�?
tail -100 logs/gateway.log
```

### 系统监控

```bash
# 内存使用
free -h

# CPU使用
top

# 磁盘空间
df -h

# Java进程
ps aux | grep java

# 端口占用
netstat -tlnp
```

### Docker管理

```bash
# 查看容器
docker ps

# 查看日志
docker logs seckill-mysql -f

# 重启容器
docker-compose restart mysql

# 清理空间
docker system prune -f
```

---

## �?常见问题

### Q1: 部署时提�?内存不足"

```bash
# 解决方案1：增加Swap空间
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 解决方案2：停止不必要的服�?
./scripts/stop-lightweight.sh

# 解决方案3：清理Docker缓存
docker system prune -f

# 然后重新部署
./scripts/deploy-lightweight.sh
```

### Q2: 前端访问很慢或无法访�?

```bash
# 检查原�?：带宽不足（3Mbps较小�?
# 解决：升级带宽到5Mbps+

# 检查原�?：前端未启动
ps aux | grep serve
# 如果未运行，重启前端
kill $(cat /tmp/frontend.pid)
cd seckill-frontend
nohup serve -s dist -l 5173 > ../logs/frontend.log 2>&1 &
echo $! > /tmp/frontend.pid

# 检查原�?：防火墙阻止
sudo ufw allow 5173/tcp
```

### Q3: Java服务启动失败

```bash
# 查看详细错误
tail -100 logs/gateway.log

# 常见原因1：端口被占用
netstat -tlnp | grep 8080
kill -9 <PID>

# 常见原因2：内存不�?
free -h
# 如果可用内存<500MB，先停止其他服务

# 常见原因3：数据库未就�?
docker ps | grep mysql
docker logs seckill-mysql
```

### Q4: 如何升级到更高配置？

如果你的业务增长，建议升级到 **4�?G** �?**4�?G**�?

```bash
# 1. 在腾讯云控制台升级配�?

# 2. 停止当前服务
./scripts/stop-lightweight.sh

# 3. 修改部署脚本，使用完整版
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# 这样可以启动所有微服务和AI Agent
```

---

## 🎯 VSCode远程开�?

### 配置方法

1. **安装扩展**
   - Remote - SSH

2. **配置SSH连接**

编辑 `C:\Users\你的用户名\.ssh\config`�?

```
Host tencent-2core
    HostName YOUR_SERVER_IP
    User root
    Port 22
```

3. **连接服务�?*
   - F1 �?Remote-SSH: Connect to Host
   - 选择 `tencent-2core`

4. **打开项目**
   - 文件 �?打开文件�?�?`/opt/ai-seckill`

### ⚠️ 注意事项

由于服务器只�?GB内存�?
- �?不要在服务器上编译Maven项目（太耗内存）
- �?在本地编译后上传jar�?
- �?不要同时打开太多VSCode窗口
- �?定期清理日志文件

---

## 📊 性能预期

### 在当前配置下�?�?G 3Mbps�?

**可以支持�?*
- �?并发用户数：50-100�?
- �?QPS（每秒请求）�?00-200
- �?响应时间�?00-500ms

**不适合�?*
- �?高并发秒杀�?1000人同时参与）
- �?大规模数据分�?
- �?实时AI推理

### 建议升级时机

当出现以下情况时，考虑升级配置�?
- 内存使用持续 > 90%
- CPU使用持续 > 80%
- 响应时间 > 1�?
- 用户反馈卡顿

---

## 💰 成本分析

### 当前配置费用

| 项目 | 月费 | 说明 |
|------|------|------|
| 服务器（2�?G 3Mbps�?| ~75�?| 腾讯云标准型S5 |
| 系统盘（50GB SSD�?| 包含 | 已包含在服务器费�?|
| 流量�?| ~20�?| 按实际使�?|
| **总计** | **~95�?�?* | |

### 升级建议

| 配置 | 月费 | 适用场景 |
|------|------|---------|
| 2�?G 3Mbps（当前） | ~95�?| 开发测试、小流量 |
| 4�?G 5Mbps | ~180�?| 小型生产环境 |
| 4�?G 10Mbps | ~350�?| 中型生产环境 |
| 8�?6G 10Mbps | ~600�?| 大型生产环境 |

---

## 🎓 学习路径

### �?天：完成部署
- [ ] 阅读 DEPLOYMENT_2CORE_2GB.md
- [ ] 执行 upload-to-server.bat
- [ ] SSH登录并运�?deploy-lightweight.sh
- [ ] 验证前端可访�?

### �?天：熟悉环境
- [ ] 配置VSCode Remote SSH
- [ ] 查看各个服务日志
- [ ] 测试基本功能
- [ ] 了解项目结构

### �?-7天：开发实�?
- [ ] 使用Qoder辅助修改代码
- [ ] 添加新功能或修复Bug
- [ ] Git提交并重新部�?
- [ ] 性能调优

### �?周：深入理解
- [ ] 阅读架构文档
- [ ] 理解微服务通信
- [ ] 学习Redis缓存策略
- [ ] 掌握Docker容器管理

---

## 📞 技术支�?

### 获取帮助

1. **查看文档**
   - 首选：[DEPLOYMENT_2CORE_2GB.md](DEPLOYMENT_2CORE_2GB.md)
   - 完整指南：[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

2. **使用Qoder**
   - 在VSCode中直接询�?
   - 描述具体问题现象
   - 提供错误日志

3. **检查日�?*
   ```bash
   tail -f logs/gateway.log
   docker logs seckill-mysql
   ```

---

## �?最终检查清�?

部署完成后，确认以下项目�?

```
�?可以通过SSH登录服务�?
�?Docker正常运行（docker ps�?
�?MySQL和Redis容器已启�?
�?5个Java服务进程正在运行
�?前端进程正在运行
�?可以访问 http://YOUR_SERVER_IP:5173
�?可以访问 http://YOUR_SERVER_IP:8080/swagger-ui.html
�?内存使用正常（free -h�?
�?已配置VSCode Remote SSH
�?已了解如何查看日志和重启服务
�?已保存服务器root密码
```

全部打勾后，恭喜！部署成功！🎉

---

## 🚀 下一步行�?

1. **立即开�?*
   ```powershell
   # 在Windows�?
   cd c:\Users\dell\Desktop\ai-seckill-hybrid
   scripts\upload-to-server.bat
   ```

2. **登录服务器部�?*
   ```bash
   ssh root@YOUR_SERVER_IP
   cd /opt/ai-seckill
   ./scripts/deploy-lightweight.sh
   ```

3. **访问系统**
   ```
   浏览器打开: http://YOUR_SERVER_IP:5173
   ```

4. **开始开�?*
   - 配置VSCode Remote SSH
   - 使用Qoder辅助编程
   - 享受云端开发的便利�?

---

**祝你使用愉快！有任何问题随时询问Qoder。�?*
