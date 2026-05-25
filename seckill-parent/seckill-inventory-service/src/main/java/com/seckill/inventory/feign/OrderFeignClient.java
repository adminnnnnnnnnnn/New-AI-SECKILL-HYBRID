package com.seckill.inventory.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 订单服务Feign客户端
 * 
 * 用于分布式事务场景下的远程调用
 */
@FeignClient(name = "seckill-order-service", path = "/api/order")
public interface OrderFeignClient {

    /**
     * 创建订单(纳入Seata全局事务)
     */
    @PostMapping("/create")
    String createOrder(
        @RequestParam Long userId,
        @RequestParam Long skuId,
        @RequestParam Integer quantity,
        @RequestParam String occupyNo
    );
}
