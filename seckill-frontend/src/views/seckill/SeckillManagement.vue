<template>
  <div class="seckill-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>秒杀管理</span>
          <el-button type="primary" @click="handleAdd">新增场次</el-button>
        </div>
      </template>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="skuName" label="商品名称" min-width="150" />
        <el-table-column prop="seckillPrice" label="秒杀价(元)" width="120" />
        <el-table-column prop="stock" label="秒杀库存" width="100" />
        <el-table-column prop="startTime" label="开始时间" width="160" />
        <el-table-column prop="endTime" label="结束时间" width="160" />
        <el-table-column prop="limitPerUser" label="限购数量" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="success" @click="handleWarmup(row)">预热</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as seckillApi from '@/api/seckill'

const loading = ref(false)
const tableData = ref([])

const getStatusType = (status: number) => {
  const types: Record<number, string> = {
    0: 'info',
    1: 'success',
    2: 'warning'
  }
  return types[status] || ''
}

const getStatusText = (status: number) => {
  const texts: Record<number, string> = {
    0: '未开始',
    1: '进行中',
    2: '已结束'
  }
  return texts[status] || '未知'
}

const handleSearch = async () => {
  loading.value = true
  try {
    const res = await seckillApi.getSeckillSessionList({})
    tableData.value = res.data.list || []
  } catch (error) {
    ElMessage.error('查询失败')
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  ElMessage.info('新增秒杀场次功能开发中')
}

const handleEdit = (row: any) => {
  ElMessage.info(`编辑场次: ${row.skuName}`)
}

const handleWarmup = async (row: any) => {
  try {
    await seckillApi.warmupStock(row.id)
    ElMessage.success('预热成功')
  } catch (error) {
    ElMessage.error('预热失败')
  }
}

const handleDelete = (row: any) => {
  ElMessageBox.confirm(`确定要删除场次"${row.skuName}"吗?`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await seckillApi.deleteSeckillSession(row.id)
      ElMessage.success('删除成功')
      handleSearch()
    } catch (error) {
      ElMessage.error('删除失败')
    }
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
</style>
