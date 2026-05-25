<template>
  <div class="material-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>物资管理</span>
          <el-button type="primary" @click="handleAdd">新增物资</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryForm" class="search-form">
        <el-form-item label="物资名称">
          <el-input v-model="queryForm.name" placeholder="输入物资名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="materialCode" label="物资编码" width="150" />
        <el-table-column prop="materialName" label="物资名称" min-width="150" />
        <el-table-column prop="specification" label="规格" width="120" />
        <el-table-column prop="unit" label="单位" width="80" />
        <el-table-column prop="safetyStock" label="安全库存" width="100" />
        <el-table-column prop="shelfLife" label="保质期(天)" width="100" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="primary" @click="handlePurchase(row)">采购</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const queryForm = reactive({ name: '' })

const handleSearch = () => {
  loading.value = true
  setTimeout(() => {
    tableData.value = [
      { materialCode: 'MT00000001', materialName: '砂糖橘', specification: '5kg/箱', unit: '箱', safetyStock: 10, shelfLife: 7 }
    ]
    loading.value = false
  }, 500)
}

const handleReset = () => { queryForm.name = ''; handleSearch() }
const handleAdd = () => ElMessage.info('新增物资功能开发中')
const handleEdit = (row: any) => ElMessage.info(`编辑物资: ${row.materialName}`)
const handlePurchase = (row: any) => ElMessage.info(`采购物资: ${row.materialName}`)

onMounted(() => handleSearch())
</script>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.search-form { margin-bottom: 20px; }
</style>
