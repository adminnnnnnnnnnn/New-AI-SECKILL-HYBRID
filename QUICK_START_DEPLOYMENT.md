# 🚀 AI-Seckill-Hybrid 腾讯云部署快速开始清单

## ✅ 准备阶段（本地Windows电脑）

### 1. 安装必要软件
- [ ] 安装 **Docker Desktop**（已安装✓）
- [ ] 安装 **Git** for Windows
- [ ] 安装 **VSCode**
- [ ] 安装 **JDK 17**
- [ ] 安装 **Maven 3.9+**
- [ ] 安装 **Node.js 18+**
- [ ] 安装 **Python 3.11+**

### 2. 初始化Git仓库
```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid
git init
git add .
git commit -m "Initial commit"
```

### 3. 创建远程仓库
- [ ] 在 **GitHub** 或 **Gitee** 创建新仓库 `ai-seckill-hybrid`
- [ ] 关联远程仓库并推送代码

```powershell
# GitHub示例
git remote add origin https://github.com/你的用户名/ai-seckill-hybrid.git
git branch -M main
git push -u origin main
```

### 4. 配置VSCode
- [ ] 安装扩展：**Remote - SSH**
- [ ] 按 `F1` → 输入 `Remote-SSH: Connect to Host`
- [ ] 添加服务器：`ssh root@你的服务器IP`

---

## ✅ 腾讯云服务器配置

### 1. 购买服务器
- [ ] 登录腾讯云控制台
- [ ] 购买CVM实例：
  - 配置：**4核8G**（最低），推荐8核16G
  - 系统：**Ubuntu 22.04 LTS**
  - 磁盘：**50GB SSD**
  - 带宽：**5Mbps+**
- [ ] 记录服务器公网IP

### 2. 配置安全组
在腾讯云控制台开放端口：
- [ ] **22** (SSH)
- [ ] **80** (HTTP)
- [ ] **443** (HTTPS)
- [ ] **3000** 或 **5173** (Vue前端)
- [ ] **8080** (API网关)
- [ ] **8848** (Nacos)
- [ ] **8000** (Python AI)

### 3. 连接到服务器
```bash
ssh root@你的服务器IP
# 输入密码
```

---

## ✅ 服务器环境搭建

### 方式A：使用一键脚本（推荐）

```bash
# 1. 下载并执行初始化脚本
curl -o setup.sh https://raw.githubusercontent.com/你的用户名/ai-seckill-hybrid/main/scripts/server-setup.sh
chmod +x setup.sh
sudo ./setup.sh

# 2. 克隆代码
cd /opt/ai-seckill
git clone https://github.com/你的用户名/ai-seckill-hybrid.git .

# 3. 执行一键部署
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 方式B：手动安装

```bash
# 1. 更新系统
sudo apt update && sudo apt upgrade -y

# 2. 安装Docker
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# 3. 安装Java
sudo apt install -y openjdk-17-jdk maven

# 4. 安装Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
sudo apt install -y nodejs

# 5. 安装Python
sudo apt install -y python3.11 python3.11-venv

# 6. 克隆代码
mkdir -p /opt/ai-seckill
cd /opt/ai-seckill
git clone https://github.com/你的用户名/ai-seckill-hybrid.git .

# 7. 启动基础设施
docker-compose up -d mysql redis nacos

# 8. 等待MySQL就绪后初始化数据库
sleep 15
docker exec -i seckill-mysql mysql -uroot -proot123456 seckill < schema.sql

# 9. 编译Java项目
cd seckill-parent
mvn clean install -DskipTests

# 10. 启动各个服务（每个服务一个screen会话）
cd ..
screen -dmS gateway bash -c "cd seckill-parent/seckill-gateway && mvn spring-boot:run"
screen -dmS user-service bash -c "cd seckill-parent/seckill-user-service && mvn spring-boot:run"
# ... 其他服务类似

# 11. 启动Python AI
cd python-ai-agent
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
screen -dmS ai-agent bash -c "source venv/bin/activate && uvicorn app.main:app --host 0.0.0.0 --port 8000"

# 12. 启动前端
cd ../seckill-frontend
npm install
screen -dmS frontend bash -c "npm run dev -- --host 0.0.0.0"
```

---

## ✅ VSCode远程开发配置

### 1. 配置SSH连接

编辑 `C:\Users\你的用户名\.ssh\config`：

```
Host ai-seckill
    HostName 你的服务器IP
    User root
    Port 22
    ForwardAgent yes
```

### 2. 连接服务器

1. 打开VSCode
2. 点击左下角绿色图标 或 按 `F1`
3. 选择 `Remote-SSH: Connect to Host...`
4. 选择 `ai-seckill`
5. 输入密码
6. VSCode在新窗口打开远程服务器

### 3. 打开项目

- 点击 `文件 > 打开文件夹`
- 选择 `/opt/ai-seckill`
- 现在可以像本地一样编辑服务器代码

### 4. 安装远程扩展

在远程VSCode中安装：
- [ ] Vue Language Features (Volar)
- [ ] Spring Boot Extension Pack
- [ ] Python
- [ ] Docker
- [ ] GitLens
- [ ] Maven for Java

---

## ✅ 使用Qoder辅助编程

### 工作流程

```
1. 本地VSCode → Remote SSH连接服务器
2. 在远程环境中打开代码
3. 使用Qoder生成/修改代码
4. Qoder直接修改服务器上的文件
5. 在VSCode终端测试
6. Git提交并推送
7. 执行deploy.sh部署
```

### 示例对话

```
你: "帮我优化seckill-inventory-service的库存扣减逻辑，使用Redis原子操作"

Qoder会:
- 分析当前代码
- 生成优化方案
- 直接修改服务器上的Java文件
- 提供测试建议
```

---

## ✅ 验证部署

### 1. 检查服务状态

```bash
# 查看所有screen会话
screen -ls

# 查看Docker容器
docker ps

# 查看日志
screen -r gateway  # 按Ctrl+A+D退出
```

### 2. 访问系统

在浏览器打开：
- [ ] **前端**: http://你的服务器IP:5173
- [ ] **API文档**: http://你的服务器IP:8080/swagger-ui.html
- [ ] **Nacos**: http://你的服务器IP:8848/nacos (账号: nacos, 密码: nacos)
- [ ] **Python AI**: http://你的服务器IP:8000/docs

### 3. 测试功能

- [ ] 注册/登录用户
- [ ] 创建商品
- [ ] 创建秒杀活动
- [ ] 参与秒杀
- [ ] 查看订单

---

## ✅ 日常开发流程

### 修改代码

```bash
# 1. 在VSCode中通过Remote SSH编辑代码
# 2. 使用Qoder辅助生成代码
# 3. 在VSCode终端测试

# 4. 提交代码
cd /opt/ai-seckill
git add .
git commit -m "优化库存扣减逻辑"
git push

# 5. 重新部署
./scripts/deploy.sh
```

### 查看日志

```bash
# Gateway日志
screen -r gateway

# Java服务日志
tail -f seckill-parent/seckill-gateway/logs/app.log

# Docker日志
docker-compose logs -f mysql
```

### 重启服务

```bash
# 停止所有服务
./scripts/stop.sh

# 重新启动
./scripts/deploy.sh

# 或重启单个服务
screen -S gateway -X quit
screen -dmS gateway bash -c "cd /opt/ai-seckill/seckill-parent/seckill-gateway && mvn spring-boot:run"
```

---

## ✅ 监控和维护

### 系统监控

```bash
# CPU和内存
htop

# 磁盘空间
df -h

# Docker资源
docker stats

# 网络连接
netstat -tlnp
```

### 数据库备份

```bash
# 手动备份
docker exec seckill-mysql mysqldump -uroot -proot123456 seckill > /backup/seckill_$(date +%Y%m%d).sql

# 定时备份（每天凌晨2点）
crontab -e
0 2 * * * docker exec seckill-mysql mysqldump -uroot -proot123456 seckill > /backup/seckill_$(date +\%Y\%m\%d).sql
```

---

## ❓ 常见问题

### Q1: 端口被占用
```bash
# 查看占用端口的进程
netstat -tlnp | grep 8080
# 杀死进程
kill -9 PID
```

### Q2: 内存不足
```bash
# 增加Swap空间
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Q3: Docker容器启动失败
```bash
# 查看日志
docker logs 容器ID

# 重启容器
docker-compose restart 服务名
```

### Q4: Git推送失败
```bash
# 配置代理（如果需要）
git config --global http.proxy http://127.0.0.1:7890
```

---

## 📞 获取帮助

- 📖 完整文档: 查看 `DEPLOYMENT_GUIDE.md`
- 🐛 问题反馈: 提交GitHub Issue
- 💬 技术支持: 询问Qoder

---

**祝部署顺利！🎉**
