package com.seckill.inventory.vo;

import lombok.Data;
import java.io.Serializable;

/**
 * 库存信息VO
 */
@Data
public class InventoryVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 仓库ID
     */
    private Long warehouseId;

    /**
     * 仓库名称
     */
    private String warehouseName;

    /**
     * SKU ID
     */
    private Long skuId;

    /**
     * 商品名称
     */
    private String skuName;

    /**
     * 总库存
     */
    private Integer totalQuantity;

    /**
     * 可用库存
     */
    private Integer availableQuantity;

    /**
     * 预占库存
     */
    private Integer occupiedQuantity;

    /**
     * 锁定库存
     */
    private Integer lockedQuantity;

    /**
     * 安全库存阈值
     */
    private Integer safetyStock;
}
