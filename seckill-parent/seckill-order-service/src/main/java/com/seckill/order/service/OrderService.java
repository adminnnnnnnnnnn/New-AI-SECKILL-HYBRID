package com.seckill.order.service;

/**
 * 订单服务接口
 */
public interface OrderService {
    
    /**
     * 创建订单
     */
    String createOrder(Long userId, Long skuId, Integer quantity);
}
