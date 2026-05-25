package com.seckill.seckill;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.seckill")  // ✅ 确保这个注解存在
public class SeckillServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(SeckillServiceApplication.class, args);
        System.out.println("==========================================");
        System.out.println("秒杀服务启动成功！端口: 8084");
        System.out.println("Redis库存已加载");
        System.out.println("AI Agent已集成");
        System.out.println("==========================================");
    }
}