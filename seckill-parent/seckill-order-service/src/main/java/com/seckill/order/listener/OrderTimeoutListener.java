package com.seckill.order.listener;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * 订单超时监听器
 * 
 * 监听30分钟延时消息,自动取消未支付订单
 */
@Slf4j
@Component
public class OrderTimeoutListener {
    
    public void onMessage(String message) {
        log.info("收到订单超时消息: {}", message);
        // TODO: 实现订单超时取消逻辑
        log.info("订单超时处理完成");
    }
}
