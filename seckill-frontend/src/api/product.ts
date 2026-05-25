import request from './request'

/**
 * 商品管理API
 */

export function getProductList(params: any) {
  return request({
    url: '/api/product/list',
    method: 'get',
    params
  })
}

export function getProductDetail(id: number) {
  return request({
    url: `/api/product/${id}`,
    method: 'get'
  })
}

export function createProduct(data: any) {
  return request({
    url: '/api/product',
    method: 'post',
    data
  })
}

export function updateProduct(id: number, data: any) {
  return request({
    url: `/api/product/${id}`,
    method: 'put',
    data
  })
}

export function deleteProduct(id: number) {
  return request({
    url: `/api/product/${id}`,
    method: 'delete'
  })
}

export function publishProduct(id: number) {
  return request({
    url: `/api/product/${id}/publish`,
    method: 'post'
  })
}

export function offlineProduct(id: number) {
  return request({
    url: `/api/product/${id}/offline`,
    method: 'post'
  })
}
