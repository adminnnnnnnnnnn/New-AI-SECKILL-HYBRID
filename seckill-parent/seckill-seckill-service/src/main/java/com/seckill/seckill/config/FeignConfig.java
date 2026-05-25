package com.seckill.seckill.config;

import feign.Logger;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import feign.codec.ErrorDecoder;
import feign.codec.Decoder;
import feign.codec.Encoder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Enumeration;
import java.util.concurrent.TimeUnit;

/**
 * Feign客户端配置类
 * 
 * 作用：配置所有Feign客户端的调用行为（日志、超时、拦截器、错误处理）
 * 与RedisConfig的区别：
 * - RedisConfig：配置Redis序列化，用于数据存储
 * - FeignConfig：配置HTTP远程调用，用于服务间通信
 * 
 * @author seckill
 * @date 2026-05-07
 */
@Configuration
public class FeignConfig {

    /**
     * Feign日志级别配置
     * 
     * NONE: 不记录任何日志（默认，性能最好）
     * BASIC: 记录请求方法、URL、响应状态码、执行时间
     * HEADERS: BASIC基础上 + 请求和响应头
     * FULL: 记录所有（请求头、请求体、响应头、响应体）
     * 
     * 推荐：开发环境用FULL，生产环境用BASIC
     */
    @Bean
    Logger.Level feignLoggerLevel() {
        // 返回BASIC级别，记录关键信息，避免日志过多
        return Logger.Level.BASIC;
    }

    /**
     * 请求拦截器：在发送HTTP请求前添加公共请求头
     * 
     * 常见用途：
     * 1. 透传链路追踪ID（traceId）
     * 2. 透传认证Token
     * 3. 添加固定请求头（如User-Agent）
     */
    @Bean
    public RequestInterceptor requestInterceptor() {
        return new RequestInterceptor() {
            @Override
            public void apply(RequestTemplate requestTemplate) {
                // 获取当前HTTP请求（从Java服务收到的请求）
                ServletRequestAttributes attributes = 
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
                
                if (attributes != null) {
                    HttpServletRequest request = attributes.getRequest();
                    
                    // 1. 透传链路追踪ID（用于全链路日志追踪）
                    String traceId = request.getHeader("X-Trace-Id");
                    if (traceId != null && !traceId.isEmpty()) {
                        requestTemplate.header("X-Trace-Id", traceId);
                    } else {
                        // 如果没有，可以生成一个（可选）
                        // requestTemplate.header("X-Trace-Id", UUID.randomUUID().toString());
                    }
                    
                    // 2. 透传认证Token（如果需要）
                    String authorization = request.getHeader("Authorization");
                    if (authorization != null && !authorization.isEmpty()) {
                        requestTemplate.header("Authorization", authorization);
                    }
                    
                    // 3. 添加客户端标识（方便Python服务识别调用来源）
                    requestTemplate.header("X-Caller", "seckill-java-service");
                    requestTemplate.header("X-Caller-Version", "1.0.0");
                }
                
                // 4. 设置通用请求头
                requestTemplate.header("Accept", "application/json");
                requestTemplate.header("Content-Type", "application/json");
            }
        };
    }

    /**
     * Feign错误解码器：统一处理远程调用失败的情况
     * 
     * 当Python服务返回非200状态码时，可以在这里做统一处理
     */
    @Bean
    public ErrorDecoder errorDecoder() {
        return new ErrorDecoder.Default() {
            @Override
            public Exception decode(String methodKey, feign.Response response) {
                // 记录错误日志
                String errorMessage = String.format(
                    "Feign调用失败 [%s]，状态码: %d，原因: %s",
                    methodKey,
                    response.status(),
                    response.reason()
                );
                
                // 可以根据状态码做不同处理
                if (response.status() == 404) {
                    return new RuntimeException("AI服务接口不存在: " + errorMessage);
                } else if (response.status() == 500) {
                    return new RuntimeException("AI服务内部错误: " + errorMessage);
                } else if (response.status() >= 400 && response.status() < 500) {
                    return new RuntimeException("AI服务请求错误: " + errorMessage);
                } else if (response.status() >= 500) {
                    return new RuntimeException("AI服务不可用: " + errorMessage);
                }
                
                // 使用默认解码器
                return super.decode(methodKey, response);
            }
        };
    }

    /**
     * 自定义编码器（可选，通常不需要）
     * 
     * 如果需要自定义请求体序列化方式，可以重写此Bean
     * 默认使用Spring Boot的Jackson编码器，已满足大部分需求
     */
    // @Bean
    // public Encoder feignEncoder() {
    //     return new SpringEncoder(...);
    // }

    /**
     * 自定义解码器（可选，通常不需要）
     * 
     * 如果需要自定义响应体反序列化方式，可以重写此Bean
     */
    // @Bean
    // public Decoder feignDecoder() {
    //     return new SpringDecoder(...);
    // }
}