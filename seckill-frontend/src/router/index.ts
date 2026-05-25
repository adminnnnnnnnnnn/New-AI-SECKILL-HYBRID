import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/login/Login.vue'),
    meta: { title: '登录', requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('@/layout/MainLayout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/Dashboard.vue'),
        meta: { title: '数据看板', icon: 'DataAnalysis' }
      },
      {
        path: 'product',
        name: 'Product',
        component: () => import('@/views/product/ProductManagement.vue'),
        meta: { title: '商品管理', icon: 'Goods' }
      },
      {
        path: 'seckill',
        name: 'Seckill',
        component: () => import('@/views/seckill/SeckillManagement.vue'),
        meta: { title: '秒杀管理', icon: 'Clock' }
      },
      {
        path: 'order',
        name: 'Order',
        component: () => import('@/views/order/OrderManagement.vue'),
        meta: { title: '订单管理', icon: 'List' }
      },
      {
        path: 'inventory',
        name: 'Inventory',
        component: () => import('@/views/inventory/InventoryManagement.vue'),
        meta: { title: '库存管理', icon: 'Box' }
      },
      {
        path: 'material',
        name: 'Material',
        component: () => import('@/views/material/MaterialManagement.vue'),
        meta: { title: '物资管理', icon: 'Document' }
      },
      {
        path: 'warehouse',
        name: 'Warehouse',
        component: () => import('@/views/warehouse/WarehouseManagement.vue'),
        meta: { title: '仓储管理', icon: 'OfficeBuilding' }
      },
      {
        path: 'delivery',
        name: 'Delivery',
        component: () => import('@/views/delivery/DeliveryTracking.vue'),
        meta: { title: '配送追踪', icon: 'Van' }
      },
      {
        path: 'supplier',
        name: 'Supplier',
        component: () => import('@/views/supplier/SupplierManagement.vue'),
        meta: { title: '供应商管理', icon: 'User' }
      },
      {
        path: 'inspect',
        name: 'Inspect',
        component: () => import('@/views/inspect/InspectManagement.vue'),
        meta: { title: '验收管理', icon: 'Checked' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  
  if (to.meta.requiresAuth !== false && !token) {
    next('/login')
  } else {
    next()
  }
})

export default router
