package com.seckill.seckill.feign;

import com.seckill.common.vo.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "seckill-order-service", fallback = OrderFeignFallback.class)
public interface OrderFeignClient {
    
    @PostMapping("/order/create")
    Result<String> createOrder(@RequestParam Long userId,
                               @RequestParam Long productId,
                               @RequestParam Integer quantity,
                               @RequestParam String amount);
}

@Component
class OrderFeignFallback implements OrderFeignClient {
    @Override
    public Result<String> createOrder(Long userId, Long productId, Integer quantity, String amount) {
        return Result.error("订单服务暂时不可用，请稍后重试");
    }
}