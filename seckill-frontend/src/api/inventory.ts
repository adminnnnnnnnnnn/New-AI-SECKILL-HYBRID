import request from './request'

/**
 * 库存管理API
 */

// 查询库存列表
export function getInventoryList(params: any) {
  return request({
    url: '/api/inventory/list',
    method: 'get',
    params
  })
}

// 查询库存详情
export function getInventoryDetail(id: number) {
  return request({
    url: `/api/inventory/${id}`,
    method: 'get'
  })
}

// 秒杀库存扣减
export function decreaseSeckillStock(params: {
  sessionId: number
  skuId: number
  quantity: number
}) {
  return request({
    url: '/api/inventory/seckill/decrease',
    method: 'post',
    params
  })
}

// 预占库存
export function occupyStock(params: {
  userId: number
  skuId: number
  quantity: number
}) {
  return request({
    url: '/api/inventory/occupy',
    method: 'post',
    params
  })
}

// 确认扣减
export function confirmStock(occupyNo: string) {
  return request({
    url: `/api/inventory/confirm/${occupyNo}`,
    method: 'post'
  })
}

// 释放预占
export function releaseStock(occupyNo: string) {
  return request({
    url: `/api/inventory/release/${occupyNo}`,
    method: 'post'
  })
}

// 查询库存预警
export function getInventoryAlerts() {
  return request({
    url: '/api/inventory/alerts',
    method: 'get'
  })
}

// 调整库存
export function adjustStock(data: any) {
  return request({
    url: '/api/inventory/adjust',
    method: 'post',
    data
  })
}
