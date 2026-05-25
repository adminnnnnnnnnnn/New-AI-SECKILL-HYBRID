<template>
  <div class="inspect-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>验收管理</span>
        </div>
      </template>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="taskNo" label="任务编号" width="180" />
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column prop="skuName" label="商品名称" min-width="150" />
        <el-table-column prop="quantity" label="数量" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 0 ? 'warning' : 'success'">{{ row.status === 0 ? '待验收' : '已完成' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="160" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" size="small" type="primary" @click="handleInspect(row)">验收</el-button>
            <el-button v-else size="small" @click="handleView(row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])

const handleSearch = () => {
  loading.value = true
  setTimeout(() => {
    tableData.value = [
      { taskNo: 'INS202605200001', orderNo: 'DD20260520000001', skuName: '新疆阿克苏苹果', quantity: 10, status: 0, createTime: '2026-05-20 10:30:00' }
    ]
    loading.value = false
  }, 500)
}

const handleInspect = (row: any) => ElMessage.info(`验收任务: ${row.taskNo}`)
const handleView = (row: any) => ElMessage.info(`查看验收记录: ${row.taskNo}`)

onMounted(() => handleSearch())
</script>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
