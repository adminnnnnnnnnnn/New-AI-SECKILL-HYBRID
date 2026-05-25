import request from './request'

export function getDeliveryList(params: any) {
  return request({ url: '/api/delivery/list', method: 'get', params })
}

export function getDeliveryTrajectory(deliveryNo: string) {
  return request({ url: `/api/delivery/${deliveryNo}/trajectory`, method: 'get' })
}

export function updateDeliveryStatus(id: number, status: number) {
  return request({ url: `/api/delivery/${id}/status`, method: 'put', data: { status } })
}
