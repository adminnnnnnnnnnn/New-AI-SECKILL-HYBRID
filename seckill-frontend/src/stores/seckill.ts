import { defineStore } from 'pinia'
import { ref } from 'vue'
import request from '@/utils/request'

export const useSeckillStore = defineStore('seckill', () => {
  // 状态
  const products = ref<any[]>([])
  const currentStock = ref<{ product_1: number; product_2: number }>({ 
    product_1: 0, 
    product_2: 0 
  })
  const statistics = ref({
    success: 0,
    fail: 0,
    total: 0
  })
  const loading = ref(false)

  // 获取商品列表
  async function fetchProducts() {
    try {
      const res = await request.get('/product/list')
      products.value = res.data || []
    } catch (error) {
      console.error('获取商品列表失败:', error)
    }
  }

  // 获取实时库存和统计
  async function fetchStats() {
    try {
      const res = await request.get('/seckill/stats')
      if (res.data) {
        currentStock.value = res.data.inventory || { product_1: 0, product_2: 0 }
        statistics.value = res.data.statistics || { success: 0, fail: 0, total: 0 }
      }
    } catch (error) {
      console.error('获取统计数据失败:', error)
    }
  }

  // 执行秒杀
  async function doSeckill(userId: number, productId: number, quantity: number = 1) {
    loading.value = true
    try {
      const res = await request.post('/seckill/do', {
        userId,
        productId,
        quantity
      })
      return res.data
    } catch (error) {
      throw error
    } finally {
      loading.value = false
    }
  }

  // AI分析
  async function aiAnalyze(question: string) {
    try {
      const res = await request.post('/ai/analyze', {
        question,
        enable_reflection: true
      })
      return res.data
    } catch (error) {
      throw error
    }
  }

  return {
    products,
    currentStock,
    statistics,
    loading,
    fetchProducts,
    fetchStats,
    doSeckill,
    aiAnalyze
  }
})
