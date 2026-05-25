package com.seckill.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.seckill.common.entity.Order;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 订单 Mapper 接口
 *
 * 约定：使用 MyBatis-Plus 的 `BaseMapper` 提供单表 CRUD，
 *       将复杂 SQL（例如 countUnpaidOrders）放在 XML 中实现。
 */
@Mapper
public interface OrderMapper extends BaseMapper<Order> {

    /**
     * 统计指定用户对指定商品的未支付订单数量（由 XML 实现）
     *
     * @param userId    用户 ID
     * @param productId 商品 ID
     * @return 未支付订单数量
     */
    int countUnpaidOrders(@Param("userId") Long userId, @Param("productId") Long productId);

}
