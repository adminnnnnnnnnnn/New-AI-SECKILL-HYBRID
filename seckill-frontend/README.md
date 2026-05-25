# AI秒杀系统 - 前端

基于Vue 3 + TypeScript + Element Plus的现代化秒杀系统前端

## 技术栈

- **Vue 3.4+** - Composition API
- **TypeScript 5.x** - 类型安全
- **Vite 5.x** - 快速构建工具
- **Element Plus** - UI组件库
- **Pinia** - 状态管理
- **Axios** - HTTP客户端
- **ECharts** - 数据可视化

## 快速开始

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:3000

### 生产构建

```bash
npm run build
```

### 预览生产版本

```bash
npm run preview
```

## 功能特性

✅ 实时库存监控  
✅ 秒杀操作界面  
✅ AI智能分析助手  
✅ 数据统计看板  
✅ 响应式设计  

## 项目结构

```
src/
├── components/     # 公共组件
├── views/         # 页面视图
├── stores/        # Pinia状态管理
├── router/        # 路由配置
├── utils/         # 工具函数
└── main.ts        # 入口文件
```

## API代理配置

前端通过Vite代理转发API请求到后端网关(localhost:8080)
