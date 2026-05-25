import request from './request'

export function getSupplierList(params: any) {
  return request({ url: '/api/supplier/list', method: 'get', params })
}

export function auditSupplier(id: number, approved: boolean, reason?: string) {
  return request({ url: `/api/supplier/${id}/audit`, method: 'post', data: { approved, reason } })
}

export function updateSupplierRating(id: number, rating: string, score: number) {
  return request({ url: `/api/supplier/${id}/rating`, method: 'put', data: { rating, score } })
}
