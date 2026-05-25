package com.seckill.inventory.listener;

import com.seckill.inventory.service.InventoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.springframework.stereotype.Component;

/**
 * 订单超时取消监听器
 * 
 * 监听RocketMQ延时消息,自动释放预占库存
 */
@Slf4j
@Component
@RequiredArgsConstructor
@RocketMQMessageListener(
    topic = "order-timeout-topic",
    consumerGroup = "inventory-timeout-consumer-group"
)
public class OrderTimeoutListener implements RocketMQListener<String> {

    private final InventoryService inventoryService;

    @Override
    public void onMessage(String occupyNo) {
        log.info("收到订单超时消息,准备释放预占库存: occupyNo={}", occupyNo);
        
        try {
            // 释放预占库存
            inventoryService.releaseOccupiedStock(occupyNo);
            log.info("预占库存释放成功: occupyNo={}", occupyNo);
            
        } catch (Exception e) {
            log.error("预占库存释放失败: occupyNo={}", occupyNo, e);
            // TODO: 重试机制或人工介入
        }
    }
}
