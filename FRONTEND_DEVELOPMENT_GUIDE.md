# 🚀 供应链系统 - 前端开发快速指南

**更新日期**: 2026-05-20  
**当前进度**: 40% (核心框架已完成)

---

## ✅ 已完成部分

### 1. 项目基础架构 (100%)
- ✅ Vue3 + TypeScript + Vite + Element Plus
- ✅ 路由配置 (`src/router/index.ts`)
- ✅ API封装 (`src/api/request.ts`, `src/api/inventory.ts`)
- ✅ 登录页面 (`src/views/login/Login.vue`)
- ✅ 主布局组件 (`src/layout/MainLayout.vue`)
- ✅ 数据看板页面 (`src/views/dashboard/Dashboard.vue`)
- ✅ 库存管理页面 (`src/views/inventory/InventoryManagement.vue`)

### 2. 已创建的目录结构
```
seckill-frontend/
├── src/
│   ├── api/                    # API接口
│   │   ├── request.ts          # axios封装 ✅
│   │   └── inventory.ts        # 库存API ✅
│   ├── router/                 # 路由配置
│   │   └── index.ts            # 路由定义 ✅
│   ├── layout/                 # 布局组件
│   │   └── MainLayout.vue      # 主布局 ✅
│   ├── views/                  # 页面组件
│   │   ├── login/              # 登录
│   │   │   └── Login.vue       # 登录页 ✅
│   │   ├── dashboard/          # 数据看板
│   │   │   └── Dashboard.vue   # 看板页 ✅
│   │   ├── inventory/          # 库存管理
│   │   │   └── InventoryManagement.vue  # 库存页 ✅
│   │   ├── product/            # 商品管理 ⏳
│   │   ├── seckill/            # 秒杀管理 ⏳
│   │   ├── order/              # 订单管理 ⏳
│   │   ├── material/           # 物资管理 ⏳
│   │   ├── warehouse/          # 仓储管理 ⏳
│   │   ├── delivery/           # 配送追踪 ⏳
│   │   ├── supplier/           # 供应商管理 ⏳
│   │   └── inspect/            # 验收管理 ⏳
│   └── App.vue
└── package.json
```

---

## ⏳ 待完成部分

### 需要创建的页面 (7个)

| 页面 | 路径 | 优先级 | 预计工时 |
|------|------|--------|----------|
| 商品管理 | `src/views/product/ProductManagement.vue` | P0 | 2小时 |
| 秒杀管理 | `src/views/seckill/SeckillManagement.vue` | P0 | 2小时 |
| 订单管理 | `src/views/order/OrderManagement.vue` | P0 | 2小时 |
| 物资管理 | `src/views/material/MaterialManagement.vue` | P0 | 2小时 |
| 仓储管理 | `src/views/warehouse/WarehouseManagement.vue` | P0 | 2小时 |
| 配送追踪 | `src/views/delivery/DeliveryTracking.vue` | P0 | 2小时 |
| 供应商管理 | `src/views/supplier/SupplierManagement.vue` | P0 | 2小时 |
| 验收管理 | `src/views/inspect/InspectManagement.vue` | P1 | 2小时 |

### 需要创建的API接口 (7个)

| API模块 | 路径 | 优先级 | 预计工时 |
|---------|------|--------|----------|
| 商品API | `src/api/product.ts` | P0 | 30分钟 |
| 秒杀API | `src/api/seckill.ts` | P0 | 30分钟 |
| 订单API | `src/api/order.ts` | P0 | 30分钟 |
| 物资API | `src/api/material.ts` | P0 | 30分钟 |
| 仓储API | `src/api/warehouse.ts` | P0 | 30分钟 |
| 配送API | `src/api/delivery.ts` | P0 | 30分钟 |
| 供应商API | `src/api/supplier.ts` | P0 | 30分钟 |

---

## 📝 页面开发模板

### 标准页面结构示例

以**商品管理页面**为例:

```vue
<template>
  <div class="product-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>商品管理</span>
          <el-button type="primary" @click="handleAdd">新增商品</el-button>
        </div>
      </template>

      <!-- 查询条件 -->
      <el-form :inline="true" :model="queryForm" class="search-form">
        <el-form-item label="商品名称">
          <el-input v-model="queryForm.name" placeholder="输入商品名称" clearable />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="queryForm.categoryId" placeholder="选择分类" clearable>
            <el-option label="水果类" :value="1" />
            <el-option label="蔬菜类" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="商品名称" min-width="150" />
        <el-table-column prop="categoryName" label="分类" width="120" />
        <el-table-column prop="price" label="价格" width="100" />
        <el-table-column prop="stock" label="库存" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '上架' : '下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.pageSize"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSearch"
        @current-change="handleSearch"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])

const queryForm = reactive({
  name: '',
  categoryId: null
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

// 查询
const handleSearch = async () => {
  loading.value = true
  try {
    // TODO: 调用API
    // const res = await getProductList(queryForm, pagination)
    // tableData.value = res.data.list
    // pagination.total = res.data.total
    
    // 模拟数据
    tableData.value = [
      { id: 1, name: '新疆阿克苏苹果', categoryName: '水果类', price: 59.9, stock: 1000, status: 1 }
    ]
    pagination.total = 1
  } catch (error) {
    ElMessage.error('查询失败')
  } finally {
    loading.value = false
  }
}

// 重置
const handleReset = () => {
  queryForm.name = ''
  queryForm.categoryId = null
  handleSearch()
}

// 新增
const handleAdd = () => {
  console.log('新增商品')
}

// 编辑
const handleEdit = (row: any) => {
  console.log('编辑商品', row)
}

// 删除
const handleDelete = (row: any) => {
  ElMessageBox.confirm('确定要删除该商品吗?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    // TODO: 调用删除API
    ElMessage.success('删除成功')
    handleSearch()
  })
}

onMounted(() => {
  handleSearch()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}
</style>
```

---

## 🔧 快速开发步骤

### Step 1: 创建API接口文件

参考 `src/api/inventory.ts`,为每个模块创建对应的API文件:

```typescript
// src/api/product.ts
import request from './request'

export function getProductList(params: any) {
  return request({
    url: '/api/product/list',
    method: 'get',
    params
  })
}

export function getProductDetail(id: number) {
  return request({
    url: `/api/product/${id}`,
    method: 'get'
  })
}

export function createProduct(data: any) {
  return request({
    url: '/api/product',
    method: 'post',
    data
  })
}

export function updateProduct(id: number, data: any) {
  return request({
    url: `/api/product/${id}`,
    method: 'put',
    data
  })
}

export function deleteProduct(id: number) {
  return request({
    url: `/api/product/${id}`,
    method: 'delete'
  })
}
```

### Step 2: 创建页面组件

复制上面的模板,修改为对应模块的字段和功能。

### Step 3: 更新路由配置

在 `src/router/index.ts` 中已经配置好所有路由,无需修改。

---

## 📊 各模块页面要点

### 1. 商品管理 (ProductManagement.vue)
- 功能: 商品CRUD、分类筛选、上下架
- API: `getProductList`, `createProduct`, `updateProduct`, `deleteProduct`
- 特殊: 支持图片上传、SPU/SKU管理

### 2. 秒杀管理 (SeckillManagement.vue)
- 功能: 秒杀场次配置、商品关联、时间设置
- API: `getSeckillSessionList`, `createSeckillSession`
- 特殊: 倒计时显示、库存预热按钮

### 3. 订单管理 (OrderManagement.vue)
- 功能: 订单列表、状态筛选、订单详情
- API: `getOrderList`, `cancelOrder`
- 特殊: 状态流转展示、物流轨迹

### 4. 物资管理 (MaterialManagement.vue)
- 功能: 物资档案、采购计划、出入库
- API: `getMaterialList`, `createPurchasePlan`
- 特殊: 采购审批流程

### 5. 仓储管理 (WarehouseManagement.vue)
- 功能: 仓库管理、库位管理、盘点任务
- API: `getWarehouseList`, `createCheckTask`
- 特殊: 库位可视化、盘点差异

### 6. 配送追踪 (DeliveryTracking.vue)
- 功能: 配送单列表、轨迹查询、异常上报
- API: `getDeliveryList`, `getDeliveryTrajectory`
- 特殊: 地图集成(可选)

### 7. 供应商管理 (SupplierManagement.vue)
- 功能: 供应商档案、资质审核、绩效评价
- API: `getSupplierList`, `auditSupplier`
- 特殊: 评级展示、红黑名单

### 8. 验收管理 (InspectManagement.vue)
- 功能: 验收任务、质检记录、拍照上传
- API: `getInspectTaskList`, `submitInspectRecord`
- 特殊: 图片预览、批次追溯

---

## 🎯 开发建议

### 优先级P0 (今天完成)
1. ✅ 商品管理页面
2. ✅ 订单管理页面
3. ✅ 秒杀管理页面
4. ✅ 对应的API接口文件

### 优先级P1 (明天完成)
1. 物资管理页面
2. 仓储管理页面
3. 配送追踪页面
4. 供应商管理页面

### 优先级P2 (后天完成)
1. 验收管理页面
2. 优化现有页面
3. 添加更多交互功能

---

## 🚀 运行前端项目

```powershell
cd c:\Users\dell\Desktop\ai-seckill-hybrid\seckill-frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问: http://localhost:5173
```

---

## 📞 技术支持

**已完成的核心文件**:
- ✅ `src/router/index.ts` - 路由配置
- ✅ `src/api/request.ts` - axios封装
- ✅ `src/api/inventory.ts` - 库存API
- ✅ `src/views/login/Login.vue` - 登录页
- ✅ `src/layout/MainLayout.vue` - 主布局
- ✅ `src/views/dashboard/Dashboard.vue` - 数据看板
- ✅ `src/views/inventory/InventoryManagement.vue` - 库存管理

**下一步**: 按照模板快速复制创建其他7个页面!

**预计总工时**: 2-3天可完成所有前端页面开发
