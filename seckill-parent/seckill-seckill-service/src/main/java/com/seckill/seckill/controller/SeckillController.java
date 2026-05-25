package com.seckill.seckill.controller;

import com.seckill.common.vo.Result;
import com.seckill.common.vo.SeckillRequest;
import com.seckill.common.vo.SeckillResult;
import com.seckill.seckill.service.SeckillService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/seckill")
@Slf4j
public class SeckillController {
    
    @Autowired
    private SeckillService seckillService;
    
    @PostMapping("/do")
    public Result<SeckillResult> doSeckill(@Valid @RequestBody SeckillRequest request) {
        log.info("收到秒杀请求: userId={}, productId={}, quantity={}", 
            request.getUserId(), request.getProductId(), request.getQuantity());
        SeckillResult result = seckillService.seckill(request);
        if (result.isSuccess()) {
            return Result.success(result);
        } else {
            return Result.error(result.getMessage());
        }
    }
    
    @GetMapping("/health")
    public Result<String> health() {
        return Result.success("秒杀服务正常");
    }
    
    @GetMapping("/stats")
    public Result<Object> getStats() {
        log.info("获取秒杀统计信息");
        try {
            // 从Redis获取AI统计信息
            Object stats = seckillService.getAIStats();
            return Result.success(stats);
        } catch (Exception e) {
            log.error("获取统计信息失败", e);
            return Result.error("获取统计信息失败: " + e.getMessage());
        }
    }
}