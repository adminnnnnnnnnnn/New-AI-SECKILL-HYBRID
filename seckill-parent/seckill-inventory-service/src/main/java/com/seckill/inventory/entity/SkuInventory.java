package com.seckill.inventory.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * SKU库存实体
 */
@Data
@TableName("sku_inventory")
public class SkuInventory implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 仓库ID
     */
    private Long warehouseId;

    /**
     * SKU ID
     */
    private Long skuId;

    /**
     * 总库存
     */
    private Integer totalQuantity;

    /**
     * 可用库存
     */
    private Integer availableQuantity;

    /**
     * 预占库存(待支付订单占用)
     */
    private Integer occupiedQuantity;

    /**
     * 锁定库存(已支付待发货)
     */
    private Integer lockedQuantity;

    /**
     * 安全库存阈值
     */
    private Integer safetyStock;

    /**
     * 版本号(乐观锁)
     */
    @Version
    private Integer version;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
