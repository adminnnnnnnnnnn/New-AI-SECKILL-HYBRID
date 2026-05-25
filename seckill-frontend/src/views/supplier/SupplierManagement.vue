<template>
  <div class="supplier-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>供应商管理</span>
        </div>
      </template>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="supplierCode" label="供应商编码" width="150" />
        <el-table-column prop="supplierName" label="供应商名称" min-width="180" />
        <el-table-column prop="creditCode" label="信用代码" width="180" />
        <el-table-column prop="contactPhone" label="联系电话" width="130" />
        <el-table-column label="评级" width="100">
          <template #default="{ row }">
            <el-tag :type="getRatingType(row.rating)">{{ row.rating }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="score" label="评分" width="80" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : row.status === 0 ? 'warning' : 'danger'">
              {{ row.status === 1 ? '合作中' : row.status === 0 ? '待审核' : '已终止' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleView(row)">查看</el-button>
            <el-button v-if="row.status === 0" size="small" type="success" @click="handleAudit(row)">审核</el-button>
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

const getRatingType = (rating: string) => {
  const types: Record<string, string> = { A: 'success', B: '', C: 'warning', D: 'danger' }
  return types[rating] || ''
}

const handleSearch = () => {
  loading.value = true
  setTimeout(() => {
    tableData.value = [
      { supplierCode: 'SUP001', supplierName: '青岛水果供应有限公司', creditCode: '91370200MA3TXXXX', contactPhone: '0532-88888888', rating: 'A', score: 95, status: 1 }
    ]
    loading.value = false
  }, 500)
}

const handleView = (row: any) => ElMessage.info(`查看供应商: ${row.supplierName}`)
const handleAudit = (row: any) => ElMessage.info(`审核供应商: ${row.supplierName}`)

onMounted(() => handleSearch())
</script>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
