package com.seckill.seckill.feign;

import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.time.Duration;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Supplier;

/**
 * 使用 Resilience4j 对 Feign 客户端进行包裹，提供熔断与降级逻辑。
 */
@Component
@Slf4j
public class AIAgentCircuitService {

    private final AIAgentFeignClient feignClient;
    private final CircuitBreaker circuitBreaker;

    @Autowired
    public AIAgentCircuitService(AIAgentFeignClient feignClient) {
        this.feignClient = feignClient;

        CircuitBreakerConfig config = CircuitBreakerConfig.custom()
                .failureRateThreshold(50)
                .waitDurationInOpenState(Duration.ofSeconds(30))
                .slidingWindowSize(10)
                .build();

        CircuitBreakerRegistry registry = CircuitBreakerRegistry.of(config);
        this.circuitBreaker = registry.circuitBreaker("ai-agent-cb");
    }

    private <T> T runWithFallback(Supplier<T> supplier, Supplier<T> fallback) {
        try {
            Supplier<T> decorated = io.github.resilience4j.circuitbreaker.CircuitBreaker.decorateSupplier(circuitBreaker, supplier);
            return decorated.get();
        } catch (Exception ex) {
            log.warn("AI Agent 调用触发降级: {}", ex.getMessage());
            return fallback.get();
        }
    }

    public Map<String, Object> analyze(Map<String, Object> request) {
        return runWithFallback(() -> feignClient.analyze(request), () -> {
            Map<String, Object> fallback = new HashMap<>();
            fallback.put("code", 503);
            fallback.put("message", "AI服务暂不可用，请稍后重试");
            Map<String, Object> data = new HashMap<>();
            data.put("answer", "抱歉，AI分析服务当前不可用，建议您稍后再试或直接查看控制台数据显示。");
            data.put("confidence", 0.3);
            data.put("fallback", true);
            fallback.put("data", data);
            return fallback;
        });
    }

    public Map<String, Object> getStats() {
        return runWithFallback(() -> feignClient.getStats(), () -> {
            Map<String, Object> fallback = new HashMap<>();
            fallback.put("code", 503);
            fallback.put("message", "AI服务暂不可用");
            Map<String, Object> data = new HashMap<>();
            data.put("fallback", true);
            fallback.put("data", data);
            return fallback;
        });
    }

    public Map<String, Object> predictPeakTime() {
        return runWithFallback(() -> feignClient.predictPeakTime(), () -> {
            Map<String, Object> fallback = new HashMap<>();
            fallback.put("code", 503);
            fallback.put("message", "AI服务暂不可用");
            Map<String, Object> data = new HashMap<>();
            data.put("predicted_peak_time", "无法预测（AI服务离线）");
            data.put("predicted_qps", 0);
            data.put("confidence", 0);
            data.put("fallback", true);
            fallback.put("data", data);
            return fallback;
        });
    }

    public Map<String, Object> analyzeProduct(MultipartFile file) {
        return runWithFallback(() -> feignClient.analyzeProduct(file), () -> {
            Map<String, Object> fallback = new HashMap<>();
            fallback.put("code", 503);
            fallback.put("message", "AI图像分析服务暂不可用");
            Map<String, Object> data = new HashMap<>();
            data.put("analyzed", false);
            data.put("fallback", true);
            fallback.put("data", data);
            return fallback;
        });
    }

    public Map<String, String> health() {
        return runWithFallback(() -> feignClient.health(), () -> {
            Map<String, String> fallback = new HashMap<>();
            fallback.put("status", "unavailable");
            fallback.put("reason", "AI Agent service is down");
            fallback.put("fallback", "true");
            return fallback;
        });
    }
}
