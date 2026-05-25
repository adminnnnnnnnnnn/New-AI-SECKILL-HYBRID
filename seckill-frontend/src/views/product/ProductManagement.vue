<template>
  <div class="product-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>商品管理</span>
          <el-button type="primary" @click="handleAdd">新增商品</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryForm" class="search-form">
        <el-form-item label="商品名称">
          <el-input v-model="queryForm.name" placeholder="输入商品名称" clearable />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="queryForm.categoryId" placeholder="选择分类" clearable>
            <el-option label="水果类" :value="1" />
            <el-option label="蔬菜类" :value="2" />
            <el-option label="肉类" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" border stripe v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="商品名称" min-width="150" />
        <el-table-column prop="categoryName" label="分类" width="120" />
        <el-table-column prop="price" label="价格(元)" width="100" />
        <el-table-column prop="stock" label="库存" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '上架' : '下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button v-if="row.status === 0" size="small" type="success" @click="handlePublish(row)">上架</el-button>
            <el-button v-else size="small" type="warning" @click="handleOffline(row)">下架</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

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
import * as productApi from '@/api/product'

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

const handleSearch = async () => {
  loading.value = true
  try {
    const res = await productApi.getProductList({ ...queryForm, ...pagination })
    tableData.value = res.data.list || []
    pagination.total = res.data.total || 0
  } catch (error) {
    ElMessage.error('查询失败')
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  queryForm.name = ''
  queryForm.categoryId = null
  handleSearch()
}

const handleAdd = () => {
  ElMessage.info('新增商品功能开发中')
}

const handleEdit = (row: any) => {
  ElMessage.info(`编辑商品: ${row.name}`)
}

const handlePublish = async (row: any) => {
  try {
    await productApi.publishProduct(row.id)
    ElMessage.success('上架成功')
    handleSearch()
  } catch (error) {
    ElMessage.error('上架失败')
  }
}

const handleOffline = async (row: any) => {
  try {
    await productApi.offlineProduct(row.id)
    ElMessage.success('下架成功')
    handleSearch()
  } catch (error) {
    ElMessage.error('下架失败')
  }
}

const handleDelete = (row: any) => {
  ElMessageBox.confirm(`确定要删除商品"${row.name}"吗?`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await productApi.deleteProduct(row.id)
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
.search-form {
  margin-bottom: 20px;
}
</style>
