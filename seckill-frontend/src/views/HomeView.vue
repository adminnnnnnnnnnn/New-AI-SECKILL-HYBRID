<template>
  <div class="seckill-container">
    <!-- 头部 -->
    <el-header class="header">
      <h1>🚀 AI智能秒杀系统</h1>
      <p class="subtitle">基于Spring Boot 3 + Vue 3 + FastAPI的现代化秒杀平台</p>
    </el-header>

    <el-main>
      <!-- 实时数据看板 -->
      <el-row :gutter="20" class="stats-row">
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-item">
              <div class="stat-icon success">✓</div>
              <div class="stat-content">
                <div class="stat-value">{{ statistics.success }}</div>
                <div class="stat-label">秒杀成功</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-item">
              <div class="stat-icon fail">✗</div>
              <div class="stat-content">
                <div class="stat-value">{{ statistics.fail }}</div>
                <div class="stat-label">秒杀失败</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-item">
              <div class="stat-icon total">Σ</div>
              <div class="stat-content">
                <div class="stat-value">{{ statistics.total }}</div>
                <div class="stat-label">总请求数</div>
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-item">
              <div class="stat-icon rate">%</div>
              <div class="stat-content">
                <div class="stat-value">{{ successRate }}%</div>
                <div class="stat-label">成功率</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>

      <!-- 库存监控 -->
      <el-card class="inventory-card" shadow="always">
        <template #header>
          <div class="card-header">
            <span>📦 实时库存监控</span>
            <el-button type="primary" size="small" @click="refreshStats" :loading="loading">
              刷新
            </el-button>
          </div>
        </template>
        <el-row :gutter="20">
          <el-col :span="12">
            <div class="product-stock">
              <h3>iPhone 15 Pro</h3>
              <el-progress 
                :percentage="(currentStock.product_1 / 100) * 100" 
                :color="customColors"
                :stroke-width="20"
              />
              <p>剩余库存: {{ currentStock.product_1 }} / 100</p>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="product-stock">
              <h3>华为 Mate 60 Pro</h3>
              <el-progress 
                :percentage="(currentStock.product_2 / 100) * 100" 
                :color="customColors"
                :stroke-width="20"
              />
              <p>剩余库存: {{ currentStock.product_2 }} / 100</p>
            </div>
          </el-col>
        </el-row>
      </el-card>

      <!-- 秒杀操作区 -->
      <el-card class="action-card" shadow="always">
        <template #header>
          <div class="card-header">
            <span>⚡ 秒杀操作</span>
          </div>
        </template>
        <el-form :model="seckillForm" label-width="100px">
          <el-form-item label="用户ID">
            <el-input-number v-model="seckillForm.userId" :min="1" :max="999999" />
          </el-form-item>
          <el-form-item label="商品选择">
            <el-select v-model="seckillForm.productId" placeholder="请选择商品">
              <el-option label="iPhone 15 Pro (¥6999)" :value="1" />
              <el-option label="华为 Mate 60 Pro (¥4999)" :value="2" />
            </el-select>
          </el-form-item>
          <el-form-item label="购买数量">
            <el-input-number v-model="seckillForm.quantity" :min="1" :max="10" />
          </el-form-item>
          <el-form-item>
            <el-button 
              type="danger" 
              size="large" 
              @click="handleSeckill"
              :loading="loading"
              class="seckill-btn"
            >
              🔥 立即秒杀
            </el-button>
          </el-form-item>
        </el-form>
      </el-card>

      <!-- AI智能分析 -->
      <el-card class="ai-card" shadow="always">
        <template #header>
          <div class="card-header">
            <span>🤖 AI智能分析助手</span>
          </div>
        </template>
        <el-input
          v-model="aiQuestion"
          type="textarea"
          :rows="3"
          placeholder="例如: 当前秒杀成功率如何?库存还剩多少?有什么优化建议?"
        />
        <el-button 
          type="primary" 
          @click="handleAIAnalyze" 
          :loading="aiLoading"
          style="margin-top: 10px"
        >
          开始分析
        </el-button>
        
        <el-alert
          v-if="aiResult"
          :title="aiResult.answer"
          type="info"
          :closable="false"
          show-icon
          style="margin-top: 15px"
        >
          <template #default>
            <div class="ai-result">
              <p><strong>置信度:</strong> {{ (aiResult.confidence * 100).toFixed(1) }}%</p>
              <p><strong>反思应用:</strong> {{ aiResult.reflection_applied ? '是' : '否' }}</p>
              <el-divider />
              <p><strong>数据快照:</strong></p>
              <pre>{{ JSON.stringify(aiResult.data_snapshot, null, 2) }}</pre>
            </div>
          </template>
        </el-alert>
      </el-card>
    </el-main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useSeckillStore } from '@/stores/seckill'

const seckillStore = useSeckillStore()

// 状态
const seckillForm = ref({
  userId: 1,
  productId: 1,
  quantity: 1
})

const aiQuestion = ref('')
const aiResult = ref<any>(null)
const aiLoading = ref(false)

// 计算属性
const statistics = computed(() => seckillStore.statistics)
const currentStock = computed(() => seckillStore.currentStock)
const loading = computed(() => seckillStore.loading)

const successRate = computed(() => {
  const total = statistics.value.total
  if (total === 0) return 0
  return ((statistics.value.success / total) * 100).toFixed(1)
})

const customColors = [
  { color: '#f56c6c', percentage: 20 },
  { color: '#e6a23c', percentage: 40 },
  { color: '#5cb87a', percentage: 60 },
  { color: '#1989fa', percentage: 80 },
  { color: '#6f7ad3', percentage: 100 }
]

// 方法
const refreshStats = async () => {
  await seckillStore.fetchStats()
  ElMessage.success('数据已刷新')
}

const handleSeckill = async () => {
  try {
    const result = await seckillStore.doSeckill(
      seckillForm.value.userId,
      seckillForm.value.productId,
      seckillForm.value.quantity
    )
    
    if (result.success) {
      ElMessage.success(`秒杀成功!订单号: ${result.orderNo}`)
      // 刷新统计数据
      await refreshStats()
    } else {
      ElMessage.error(result.message || '秒杀失败')
    }
  } catch (error: any) {
    ElMessage.error(error.message || '秒杀失败')
  }
}

const handleAIAnalyze = async () => {
  if (!aiQuestion.value.trim()) {
    ElMessage.warning('请输入问题')
    return
  }
  
  aiLoading.value = true
  try {
    aiResult.value = await seckillStore.aiAnalyze(aiQuestion.value)
    ElMessage.success('AI分析完成')
  } catch (error: any) {
    ElMessage.error(error.message || 'AI分析失败')
  } finally {
    aiLoading.value = false
  }
}

// 生命周期
onMounted(() => {
  refreshStats()
  // 每5秒自动刷新一次
  setInterval(refreshStats, 5000)
})
</script>

<style scoped>
.seckill-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.header {
  text-align: center;
  color: white;
  margin-bottom: 30px;
}

.header h1 {
  font-size: 36px;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.subtitle {
  font-size: 16px;
  opacity: 0.9;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  border-radius: 10px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  color: white;
}

.stat-icon.success {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-icon.fail {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-icon.total {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.stat-icon.rate {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 5px;
}

.inventory-card,
.action-card,
.ai-card {
  margin-bottom: 20px;
  border-radius: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
  font-size: 18px;
}

.product-stock {
  padding: 20px;
}

.product-stock h3 {
  margin-bottom: 15px;
  color: #303133;
}

.product-stock p {
  margin-top: 10px;
  color: #606266;
  font-size: 14px;
}

.seckill-btn {
  width: 100%;
  font-size: 18px;
  font-weight: bold;
}

.ai-result {
  margin-top: 10px;
}

.ai-result pre {
  background: #f5f7fa;
  padding: 10px;
  border-radius: 5px;
  overflow-x: auto;
  font-size: 12px;
}
</style>
