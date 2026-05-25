<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <!-- 统计卡片 -->
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #409EFF">
              <el-icon><Goods /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.productCount }}</div>
              <div class="stat-label">商品总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #67C23A">
              <el-icon><List /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.orderCount }}</div>
              <div class="stat-label">订单总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #E6A23C">
              <el-icon><Box /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.inventoryCount }}</div>
              <div class="stat-label">库存总量</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" style="background-color: #F56C6C">
              <el-icon><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.supplierCount }}</div>
              <div class="stat-label">供应商数量</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>订单趋势</span>
          </template>
          <div ref="orderChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card>
          <template #header>
            <span>库存分布</span>
          </template>
          <div ref="inventoryChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 预警信息 -->
    <el-card style="margin-top: 20px">
      <template #header>
        <span>库存预警</span>
      </template>
      <el-table :data="alerts" border stripe>
        <el-table-column prop="warehouseName" label="仓库名称" width="150" />
        <el-table-column prop="skuName" label="商品名称" min-width="200" />
        <el-table-column prop="availableQuantity" label="可用库存" width="100">
          <template #default="{ row }">
            <el-tag :type="row.availableQuantity <= 0 ? 'danger' : 'warning'">
              {{ row.availableQuantity }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="safetyStock" label="安全库存" width="100" />
        <el-table-column label="预警类型" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.availableQuantity <= 0" type="danger">缺货</el-tag>
            <el-tag v-else type="warning">库存不足</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- AI智能分析助手 -->
    <el-card class="ai-card" shadow="always" style="margin-top: 20px">
      <template #header>
        <div class="card-header">
          <span>🤖 AI智能分析助手</span>
          <el-tag type="success" size="small">在线</el-tag>
        </div>
      </template>
      
      <el-alert
        title="💡 我可以帮您分析系统数据、提供优化建议"
        type="info"
        :closable="false"
        show-icon
        style="margin-bottom: 15px"
      >
        <template #default>
          <p style="margin: 5px 0; font-size: 13px;">试试问我：</p>
          <ul style="margin: 5px 0; padding-left: 20px; font-size: 13px;">
            <li>当前订单趋势如何？</li>
            <li>哪些商品库存不足？</li>
            <li>有什么优化建议？</li>
            <li>预测下周的订单量</li>
          </ul>
        </template>
      </el-alert>

      <el-input
        v-model="aiQuestion"
        type="textarea"
        :rows="3"
        placeholder="请输入您的问题，例如：当前订单趋势如何？"
        style="margin-bottom: 10px"
      />
      
      <el-button 
        type="primary" 
        @click="handleAIAnalyze" 
        :loading="aiLoading"
        :disabled="!aiQuestion.trim()"
      >
        🚀 开始分析
      </el-button>
      
      <!-- AI回答展示区 -->
      <el-collapse v-if="aiResult" v-model="activeCollapse" style="margin-top: 15px">
        <el-collapse-item name="1">
          <template #title>
            <div style="display: flex; align-items: center; gap: 10px; width: 100%">
              <el-icon color="#409EFF" size="20"><ChatDotRound /></el-icon>
              <strong style="flex: 1">AI分析结果</strong>
              <el-tag :type="aiResult.confidence >= 0.8 ? 'success' : aiResult.confidence >= 0.6 ? 'warning' : 'danger'" size="small">
                置信度: {{ (aiResult.confidence * 100).toFixed(1) }}%
              </el-tag>
            </div>
          </template>
          
          <div class="ai-result-content">
            <div class="ai-answer">
              <p>{{ aiResult.answer }}</p>
            </div>
            
            <el-divider />
            
            <div class="ai-metadata">
              <el-descriptions :column="2" border size="small">
                <el-descriptions-item label="反思应用">
                  <el-tag :type="aiResult.reflection_applied ? 'success' : 'info'" size="small">
                    {{ aiResult.reflection_applied ? '是' : '否' }}
                  </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="分析时间">
                  {{ formatTime(aiResult.data_snapshot?.timestamp) }}
                </el-descriptions-item>
              </el-descriptions>
            </div>
            
            <el-divider />
            
            <div class="ai-data-snapshot">
              <p style="font-weight: bold; margin-bottom: 10px">📊 实时数据快照：</p>
              <pre>{{ JSON.stringify(aiResult.data_snapshot, null, 2) }}</pre>
            </div>
          </div>
        </el-collapse-item>
      </el-collapse>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
import { Goods, List, Box, User, ChatDotRound } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const stats = ref({
  productCount: 1250,
  orderCount: 8560,
  inventoryCount: 45230,
  supplierCount: 156
})

const alerts = ref([
  {
    warehouseName: '青岛中心仓',
    skuName: '砂糖橘-5kg/箱',
    availableQuantity: 5,
    safetyStock: 10
  },
  {
    warehouseName: '北京前置仓',
    skuName: '鲜鸡蛋-30枚/盒',
    availableQuantity: 0,
    safetyStock: 20
  }
])

const orderChartRef = ref<HTMLDivElement>()
const inventoryChartRef = ref<HTMLDivElement>()

const aiQuestion = ref('')
const aiResult = ref<any>(null)
const aiLoading = ref(false)
const activeCollapse = ref<string[]>([]) // 控制折叠面板展开状态

// 格式化时间
const formatTime = (timestamp: string) => {
  if (!timestamp) return '-'
  const date = new Date(timestamp)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// AI分析
const handleAIAnalyze = async () => {
  if (!aiQuestion.value.trim()) {
    ElMessage.warning('请输入问题')
    return
  }
  
  aiLoading.value = true
  try {
    // 调用秒杀服务的AI接口（通过Gateway）- GET方法，增加超时时间到120秒
    // 注意：request实例已有baseURL='/api'，所以这里只需要相对路径
    const res: any = await request.get('/seckill/ai/advice', {
      params: { question: aiQuestion.value },
      timeout: 120000  // 120秒超时，适应AI模型加载和处理时间
    })
    
    // request拦截器已经返回了res.data，所以res就是后端返回的Result对象
    if (res && res.code === 200) {
      // 构建完整的AI响应格式
      aiResult.value = {
        answer: res.data || 'AI分析完成',
        confidence: 0.85,  // 默认置信度
        reflection_applied: false,
        data_snapshot: {
          statistics: stats.value,
          alerts_count: alerts.value.length,
          timestamp: new Date().toISOString()
        }
      }
      // 自动展开折叠面板显示结果
      activeCollapse.value = ['1']
      ElMessage.success('AI分析完成')
    } else {
      ElMessage.error(res?.message || 'AI分析失败')
    }
  } catch (error: any) {
    console.error('AI分析错误:', error)
    // 更详细的错误提示
    if (error.code === 'ECONNABORTED' || error.message?.includes('timeout')) {
      ElMessage.error('请求超时，请稍后重试或检查网络连接')
    } else {
      ElMessage.error(error.message || 'AI服务暂不可用')
    }
  } finally {
    aiLoading.value = false
  }
}

// 初始化订单趋势图
const initOrderChart = () => {
  if (!orderChartRef.value) return
  
  const chart = echarts.init(orderChartRef.value)
  const option = {
    title: {
      text: '近7天订单趋势',
      left: 'center'
    },
    tooltip: {
      trigger: 'axis'
    },
    xAxis: {
      type: 'category',
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: '订单数',
        type: 'line',
        smooth: true,
        data: [120, 132, 101, 134, 90, 230, 210],
        itemStyle: {
          color: '#409EFF'
        }
      }
    ]
  }
  chart.setOption(option)
}

// 初始化库存分布图
const initInventoryChart = () => {
  if (!inventoryChartRef.value) return
  
  const chart = echarts.init(inventoryChartRef.value)
  const option = {
    title: {
      text: '各仓库库存占比',
      left: 'center'
    },
    tooltip: {
      trigger: 'item'
    },
    series: [
      {
        name: '库存分布',
        type: 'pie',
        radius: '50%',
        data: [
          { value: 1048, name: '青岛中心仓' },
          { value: 735, name: '北京前置仓' },
          { value: 580, name: '上海前置仓' },
          { value: 484, name: '黄岛前置仓' }
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  }
  chart.setOption(option)
}

onMounted(() => {
  initOrderChart()
  initInventoryChart()
})
</script>

<style scoped>
.dashboard {
  padding: 20px;
}

.stat-card {
  margin-bottom: 20px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 28px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ai-card {
  border: 2px solid #409EFF;
}

.ai-result-content {
  padding: 10px;
}

.ai-answer {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 15px;
  border-radius: 8px;
  line-height: 1.6;
}

.ai-answer p {
  margin: 0;
  white-space: pre-wrap;
}

.ai-metadata {
  margin-top: 10px;
}

.ai-data-snapshot {
  margin-top: 10px;
}

.ai-data-snapshot pre {
  background: #f5f7fa;
  padding: 12px;
  border-radius: 6px;
  overflow-x: auto;
  font-size: 12px;
  line-height: 1.5;
  max-height: 300px;
  overflow-y: auto;
}
</style>