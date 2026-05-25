package com.seckill.common.vo;

import lombok.Data;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.io.Serializable;

/**
 * 秒杀请求参数
 * 
 * 作用:封装前端调用秒杀接口时传递的参数
 * 配合@Valid 注解实现自动参数校验,减少Controller中的if-else代码
 * 
 * 前端传递的JSON示例:
 * {
 *    "userId":1001,
 *     "productId":2001,
 *     "quantity":1
 * }
 */
@Data
public class SeckillRequest implements Serializable{
    private static final long SerialVersionUID = 1L;
    
    /**
     * 用户ID
     * 标识那个用户发起的秒杀请求
     * 用于:
     * 1.检查用户是否已经秒杀过该商品(防止重复描述)
     * 2.记录订单时关联到具体用户
     */
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /**
     * 商品ID
     * 标识要秒杀那个商品
     * 用户:
     * 1.查询商品信息(价格、库存等)    
     * 2.扣减对应商品的库存
     * 3.生成订单时关联到具体商品
     *  * 
     */
    @NotNull(message = "商品ID不能为空")
    private Long productId;

    /**
     * 购买数量
     * 用户要买几个
     * @Min(1)确保数量至少为1,不能为0或者负数
     * 
     * 秒杀场景通常限制没人只能买1个(防止黄牛囤货)
     * 但这里设计为可配置,便于不同活动灵活调整
     */
    @NotNull(message = "数量不能为空")
    @Min(value = 1,message = "数量至少为1")
    private Integer quantity;
}