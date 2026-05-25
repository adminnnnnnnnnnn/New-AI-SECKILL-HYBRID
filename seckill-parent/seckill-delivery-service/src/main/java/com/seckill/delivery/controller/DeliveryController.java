package com.seckill.delivery.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/delivery")
@RequiredArgsConstructor
@Tag(name = "配送管理", description = "配送单管理、物流轨迹追踪")
public class DeliveryController {

    @PostMapping("/order")
    @Operation(summary = "创建配送单")
    public String createDeliveryOrder(@RequestBody DeliveryOrderCreateDTO dto) {
        // TODO: 实现创建逻辑
        return "DO" + System.currentTimeMillis();
    }

    @PostMapping("/{deliveryNo}/status")
    @Operation(summary = "更新配送状态")
    public void updateDeliveryStatus(
            @PathVariable String deliveryNo,
            @RequestParam Integer status,
            @RequestParam(required = false) String remark) {
        // TODO: 实现状态更新逻辑,发送MQ消息通知前端
    }

    @GetMapping("/{deliveryNo}/trajectory")
    @Operation(summary = "查询物流轨迹")
    public Object getTrajectory(@PathVariable String deliveryNo) {
        // TODO: 查询轨迹列表
        return null;
    }

    @PostMapping("/{deliveryNo}/sign")
    @Operation(summary = "签收确认")
    public void confirmSign(
            @PathVariable String deliveryNo,
            @RequestParam String signProofImage,
            @RequestParam(required = false) String signature) {
        // TODO: 实现签收逻辑
    }

    @PostMapping("/{deliveryNo}/exception")
    @Operation(summary = "上报异常")
    public void reportException(
            @PathVariable String deliveryNo,
            @RequestParam String reason) {
        // TODO: 实现异常上报逻辑
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "按状态查询配送单")
    public Object getDeliveryByStatus(@PathVariable Integer status) {
        // TODO: 查询指定状态的配送单列表
        return null;
    }
}
