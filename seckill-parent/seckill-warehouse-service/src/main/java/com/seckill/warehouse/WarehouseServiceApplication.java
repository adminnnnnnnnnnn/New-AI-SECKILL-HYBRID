package com.seckill.warehouse;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan("com.seckill.warehouse.mapper")
public class WarehouseServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(WarehouseServiceApplication.class, args);
        System.out.println("========================================");
        System.out.println("仓储服务启动成功! 端口: 8088");
        System.out.println("Swagger文档: http://localhost:8088/swagger-ui.html");
        System.out.println("========================================");
    }
}
