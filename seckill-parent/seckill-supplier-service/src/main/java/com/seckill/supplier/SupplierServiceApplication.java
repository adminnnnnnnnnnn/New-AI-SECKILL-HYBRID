package com.seckill.supplier;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@MapperScan("com.seckill.supplier.mapper")
public class SupplierServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(SupplierServiceApplication.class, args);
        System.out.println("========================================");
        System.out.println("供应商服务启动成功! 端口: 8090");
        System.out.println("Swagger文档: http://localhost:8090/swagger-ui.html");
        System.out.println("========================================");
    }
}
