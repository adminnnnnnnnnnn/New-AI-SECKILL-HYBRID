
package com.seckill.common.entity;

import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 商品实体类
 */
@Data
public class Product implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private Long id;                  //商品ID
    private String productName;        //商品名称 
    private BigDecimal price;         //商品原件
    private BigDecimal seckillPrice;  //秒杀价格
    private Integer status;          //状态:0-无效,1-有效
    private Integer version;         //乐观锁版本号
    private LocalDateTime createdAt;  //创建时间
    private LocalDateTime updatedAt;  //更新时间
}
