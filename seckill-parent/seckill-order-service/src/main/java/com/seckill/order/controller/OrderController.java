package com.seckill.order.controller;

import com.seckill.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/order")
@RequiredArgsConstructor
@Tag(name = "订单管理", description = "订单创建、查询、取消")
public class OrderController {

    private final OrderService orderService;

    @PostMapping("/create")
    @Operation(summary = "创建订单")
    public String createOrder(
            @RequestParam Long userId,
            @RequestParam Long skuId,
            @RequestParam Integer quantity) {
        return orderService.createOrder(userId, skuId, quantity);
    }

    @GetMapping("/{orderNo}")
    @Operation(summary = "查询订单详情")
    public Object getOrderDetail(@PathVariable String orderNo) {
        // TODO: 实现订单详情查询
        return null;
    }

    @PostMapping("/{orderNo}/cancel")
    @Operation(summary = "取消订单")
    public void cancelOrder(@PathVariable String orderNo) {
        // TODO: 实现订单取消逻辑
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "查询用户订单列表")
    public Object getUserOrders(@PathVariable Long userId) {
        // TODO: 查询用户订单列表
        return null;
    }
}

