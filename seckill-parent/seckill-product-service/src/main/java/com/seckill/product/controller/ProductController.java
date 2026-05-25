package com.seckill.product.controller;

import com.seckill.common.entity.Product;
import com.seckill.common.vo.Result;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/product")
public class ProductController {

    private static List<Product> productList = new ArrayList<>();
    
    static {
        Product p1 = new Product();
        p1.setId(1L);
        p1.setProductName("iPhone 15 Pro");
        p1.setPrice(new BigDecimal("8999.00"));
        p1.setSeckillPrice(new BigDecimal("6999.00"));
        p1.setStatus(1);
        productList.add(p1);
        
        Product p2 = new Product();
        p2.setId(2L);
        p2.setProductName("华为 Mate 60 Pro");
        p2.setPrice(new BigDecimal("6999.00"));
        p2.setSeckillPrice(new BigDecimal("4999.00"));
        p2.setStatus(1);
        productList.add(p2);
    }

    @GetMapping("/{productId}")
    public Result<Product> getProduct(@PathVariable Long productId) {
        return productList.stream()
            .filter(p -> p.getId().equals(productId))
            .findFirst()
            .map(Result::success)
            .orElse(Result.error("商品不存在"));
    }

    @GetMapping("/list")
    public Result<List<Product>> listProducts() {
        return Result.success(productList);
    }
}