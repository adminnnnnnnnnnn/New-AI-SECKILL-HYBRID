import request from './request'

/**
 * 订单管理API
 */

export function getOrderList(params: any) {
  return request({
    url: '/api/order/list',
    method: 'get',
    params
  })
}

export function getOrderDetail(orderNo: string) {
  return request({
    url: `/api/order/${orderNo}`,
    method: 'get'
  })
}

export function createOrder(data: any) {
  return request({
    url: '/api/order',
    method: 'post',
    data
  })
}

export function cancelOrder(orderNo: string) {
  return request({
    url: `/api/order/${orderNo}/cancel`,
    method: 'post'
  })
}

export function confirmReceipt(orderNo: string) {
  return request({
    url: `/api/order/${orderNo}/confirm`,
    method: 'post'
  })
}
