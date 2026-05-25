
package com.seckill.common.entity;

import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 库存实体类
 */
@Data
public class Stock implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private Long id;              //库存ID
    private Long productId;       //商品ID
    private Integer totalStock;   //总库存
    private Integer seckillStock;  //秒杀库存
    private Integer version;      //乐观锁版本号
    private LocalDateTime updatedAt;   //更新时间
}
