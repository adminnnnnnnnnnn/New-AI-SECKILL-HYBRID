package com.seckill.inventory.dto;

import lombok.Data;
import java.io.Serializable;

/**
 * 库存扣减DTO
 */
@Data
public class StockDecreaseDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 仓库ID
     */
    private Long warehouseId;

    /**
     * SKU ID
     */
    private Long skuId;

    /**
     * 扣减数量
     */
    private Integer quantity;

    /**
     * 业务类型: SECKILL-秒杀, ORDER-普通订单
     */
    private String businessType;
}
