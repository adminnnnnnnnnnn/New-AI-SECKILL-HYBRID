import request from './request'

export function getWarehouseList(params: any) {
  return request({ url: '/api/warehouse/list', method: 'get', params })
}

export function createWarehouse(data: any) {
  return request({ url: '/api/warehouse', method: 'post', data })
}

export function updateWarehouse(id: number, data: any) {
  return request({ url: `/api/warehouse/${id}`, method: 'put', data })
}

export function deleteWarehouse(id: number) {
  return request({ url: `/api/warehouse/${id}`, method: 'delete' })
}
