<template>
  <div class="warehouse-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>仓储管理</span>
          <el-button type="primary" @click="handleAdd">新增仓库</el-button>
        </div>
      </template>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="warehouseCode" label="仓库编码" width="120" />
        <el-table-column prop="warehouseName" label="仓库名称" min-width="150" />
        <el-table-column prop="warehouseType" label="类型" width="100" />
        <el-table-column prop="manager" label="负责人" width="100" />
        <el-table-column prop="phone" label="联系电话" width="130" />
        <el-table-column prop="capacity" label="容量(m³)" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">{{ row.status === 1 ? '正常' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="primary" @click="handleCheck(row)">盘点</el-button>
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
      { warehouseCode: 'WH01', warehouseName: '青岛中心仓', warehouseType: '中心仓', manager: '张三', phone: '13800138000', capacity: 1000, status: 1 }
    ]
    loading.value = false
  }, 500)
}

const handleAdd = () => ElMessage.info('新增仓库功能开发中')
const handleEdit = (row: any) => ElMessage.info(`编辑仓库: ${row.warehouseName}`)
const handleCheck = (row: any) => ElMessage.info(`盘点仓库: ${row.warehouseName}`)

onMounted(() => handleSearch())
</script>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
