package com.seckill.material;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan("com.seckill.material.mapper")
public class MaterialServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(MaterialServiceApplication.class, args);
        System.out.println("========================================");
        System.out.println("物资服务启动成功! 端口: 8087");
        System.out.println("Swagger文档: http://localhost:8087/swagger-ui.html");
        System.out.println("========================================");
    }
}
