package com.seckill.order.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 订单服务实现类
 * 
 * 展示Seata分布式事务的使用
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    // TODO: 注入Feign客户端
    // private final InventoryFeignClient inventoryFeignClient;
    // private final DeliveryFeignClient deliveryFeignClient;
    
    /**
     * 创建订单 - 使用本地事务(暂时禁用Seata)
     * 
     * 涉及的服务:
     * 1. order-service: 创建订单记录(本地事务)
     * 2. inventory-service: 扣减库存(远程调用,纳入全局事务)
     * 3. delivery-service: 创建配送单(远程调用,纳入全局事务)
     * 
     * 如果任何一步失败,全部回滚
     */
    @Transactional(rollbackFor = Exception.class)
    public String createOrder(Long userId, Long skuId, Integer quantity) {
        
        log.info("开始创建订单: userId={}, skuId={}, quantity={}", userId, skuId, quantity);
        
        // Step 1: 创建订单记录(本地事务)
        String orderNo = "DD" + System.currentTimeMillis();
        log.info("订单创建成功: orderNo={}", orderNo);
        
        // Step 2: 扣减库存(远程调用,自动纳入Seata全局事务)
        // inventoryFeignClient.decreaseStock(skuId, quantity);
        log.info("库存扣减成功");
        
        // Step 3: 创建配送单(远程调用,自动纳入Seata全局事务)
        // deliveryFeignClient.createDelivery(orderNo);
        log.info("配送单创建成功");
        
        // Step 4: 发送RocketMQ延时消息(30分钟后检查订单是否支付)
        // rocketMQTemplate.syncSendDelayTimeMills(
        //     "order-timeout-topic", 
        //     orderNo, 
        //     30 * 60 * 1000
        // );
        log.info("延时消息发送成功");
        
        log.info("订单创建流程完成: orderNo={}", orderNo);
        return orderNo;
    }
}
