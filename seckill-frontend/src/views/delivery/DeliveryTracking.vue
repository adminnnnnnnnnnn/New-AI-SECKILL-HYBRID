<template>
  <div class="delivery-tracking">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>配送追踪</span>
        </div>
      </template>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="deliveryNo" label="配送单号" width="180" />
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column prop="receiverName" label="收货人" width="100" />
        <el-table-column prop="receiverPhone" label="联系电话" width="130" />
        <el-table-column prop="carrier" label="物流公司" width="120" />
        <el-table-column prop="trackingNo" label="物流单号" width="150" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleTrack(row)">轨迹</el-button>
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

const getStatusType = (status: number) => {
  const types: Record<number, string> = { 0: 'info', 1: 'primary', 2: 'warning', 3: 'success', 4: 'danger' }
  return types[status] || ''
}

const getStatusText = (status: number) => {
  const texts: Record<number, string> = { 0: '待接单', 1: '已接单', 2: '配送中', 3: '已签收', 4: '异常' }
  return texts[status] || '未知'
}

const handleSearch = () => {
  loading.value = true
  setTimeout(() => {
    tableData.value = [
      { deliveryNo: 'DL202605200001', orderNo: 'DD20260520000001', receiverName: '李四', receiverPhone: '13900139000', carrier: '顺丰速运', trackingNo: 'SF1234567890', status: 2 }
    ]
    loading.value = false
  }, 500)
}

const handleTrack = (row: any) => ElMessage.info(`查看配送轨迹: ${row.deliveryNo}`)

onMounted(() => handleSearch())
</script>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
