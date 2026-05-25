<template>
  <div class="inventory-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>库存管理</span>
          <el-button type="primary" @click="handleRefresh">刷新</el-button>
        </div>
      </template>

      <!-- 查询条件 -->
      <el-form :inline="true" :model="queryForm" class="search-form">
        <el-form-item label="仓库">
          <el-select v-model="queryForm.warehouseId" placeholder="选择仓库" clearable>
            <el-option label="青岛中心仓" :value="1" />
            <el-option label="北京前置仓" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="商品名称">
          <el-input v-model="queryForm.skuName" placeholder="输入商品名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 库存表格 -->
      <el-table :data="inventoryList" border stripe v-loading="loading">
        <el-table-column prop="warehouseName" label="仓库名称" width="150" />
        <el-table-column prop="skuName" label="商品名称" min-width="200" />
        <el-table-column prop="totalQuantity" label="总库存" width="100" />
        <el-table-column prop="availableQuantity" label="可用库存" width="100">
          <template #default="{ row }">
            <el-tag :type="getStockType(row.availableQuantity)">
              {{ row.availableQuantity }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="occupiedQuantity" label="预占库存" width="100" />
        <el-table-column prop="lockedQuantity" label="锁定库存" width="100" />
        <el-table-column prop="safetyStock" label="安全库存" width="100" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleViewDetail(row)">详情</el-button>
            <el-button size="small" type="warning" @click="handleAdjust(row)">调整</el-button>
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

    <!-- 库存预警 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <span>库存预警</span>
      </template>
      <el-alert
        v-for="alert in alerts"
        :key="alert.id"
        :title="alert.message"
        :type="alert.type"
        :closable="false"
        show-icon
        style="margin-bottom: 10px"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const inventoryList = ref([])
const alerts = ref([])

const queryForm = reactive({
  warehouseId: null,
  skuName: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

// 获取库存类型
const getStockType = (quantity: number) => {
  if (quantity <= 0) return 'danger'
  if (quantity <= 10) return 'warning'
  return 'success'
}

// 查询库存
const handleSearch = async () => {
  loading.value = true
  try {
    // TODO: 调用API
    // const res = await getInventoryList(queryForm, pagination)
    // inventoryList.value = res.data.list
    // pagination.total = res.data.total
    
    // 模拟数据
    inventoryList.value = [
      {
        warehouseName: '青岛中心仓',
        skuName: '新疆阿克苏苹果-5kg/箱',
        totalQuantity: 1000,
        availableQuantity: 850,
        occupiedQuantity: 100,
        lockedQuantity: 50,
        safetyStock: 100
      }
    ]
    pagination.total = 1
  } catch (error) {
    ElMessage.error('查询失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const handleReset = () => {
  queryForm.warehouseId = null
  queryForm.skuName = ''
  handleSearch()
}

// 刷新
const handleRefresh = () => {
  handleSearch()
  ElMessage.success('刷新成功')
}

// 查看详情
const handleViewDetail = (row: any) => {
  console.log('查看详情', row)
}

// 调整库存
const handleAdjust = (row: any) => {
  console.log('调整库存', row)
}

// 加载库存预警
const loadAlerts = () => {
  alerts.value = [
    { id: 1, message: '砂糖橘库存低于安全阈值(当前: 5, 安全: 10)', type: 'warning' },
    { id: 2, message: '鲜鸡蛋即将过期(剩余3天)', type: 'error' }
  ]
}

onMounted(() => {
  handleSearch()
  loadAlerts()
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
