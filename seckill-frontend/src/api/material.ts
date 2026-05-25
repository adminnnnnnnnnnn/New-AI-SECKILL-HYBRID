import request from './request'

export function getMaterialList(params: any) {
  return request({ url: '/api/material/list', method: 'get', params })
}

export function createMaterial(data: any) {
  return request({ url: '/api/material', method: 'post', data })
}

export function updateMaterial(id: number, data: any) {
  return request({ url: `/api/material/${id}`, method: 'put', data })
}

export function deleteMaterial(id: number) {
  return request({ url: `/api/material/${id}`, method: 'delete' })
}
