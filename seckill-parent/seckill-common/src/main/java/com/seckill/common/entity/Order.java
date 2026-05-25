
package com.seckill.common.entity;

import lombok.Data;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单实体类
 */
@Data
public class Order implements Serializable {
    private static final long serialVersionUID = 1L;
    private Long id;                //订单ID
    private String orderNo;         //订单号
    private Long userId;            //用户ID
    private Long productId;         //商品ID
    private Integer quantity;       //数量
    private BigDecimal amount;      //订单金额
    private Integer status;         //状态:0-待支付,1-已支付,2-已取消
    private LocalDateTime createdAt;  //创建时间
    private LocalDateTime updatedAt;  //更新时间  
}
