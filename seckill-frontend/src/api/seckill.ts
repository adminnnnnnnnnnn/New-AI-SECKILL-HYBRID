import request from './request'

/**
 * 秒杀管理API
 */

export function getSeckillSessionList(params: any) {
  return request({
    url: '/api/seckill/session/list',
    method: 'get',
    params
  })
}

export function createSeckillSession(data: any) {
  return request({
    url: '/api/seckill/session',
    method: 'post',
    data
  })
}

export function updateSeckillSession(id: number, data: any) {
  return request({
    url: `/api/seckill/session/${id}`,
    method: 'put',
    data
  })
}

export function deleteSeckillSession(id: number) {
  return request({
    url: `/api/seckill/session/${id}`,
    method: 'delete'
  })
}

export function warmupStock(sessionId: number) {
  return request({
    url: `/api/seckill/session/${sessionId}/warmup`,
    method: 'post'
  })
}
