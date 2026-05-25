import request from './request'

export function getInspectTaskList(params: any) {
  return request({ url: '/api/inspect/list', method: 'get', params })
}

export function submitInspectRecord(taskId: number, data: any) {
  return request({ url: `/api/inspect/${taskId}/submit`, method: 'post', data })
}
