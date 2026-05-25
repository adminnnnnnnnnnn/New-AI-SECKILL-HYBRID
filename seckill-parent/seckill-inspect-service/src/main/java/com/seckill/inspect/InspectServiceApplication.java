package com.seckill.inspect;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan("com.seckill.inspect.mapper")
public class InspectServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(InspectServiceApplication.class, args);
        System.out.println("========================================");
        System.out.println("验收服务启动成功! 端口: 8086");
        System.out.println("Swagger文档: http://localhost:8086/swagger-ui.html");
        System.out.println("========================================");
    }
}
