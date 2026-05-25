package com.seckill.common.vo;

import lombok.Data;
import java.io.Serializable;

/**
 * 秒杀结果
 * 
 * 作用:专门用于秒杀接口的相应结果
 * 与Result的区别:
 * -Result是通用包装器,包裹所用类型的响应
 * -SeckillResult是具体的业务数据,被Result的data字段包裹
 * 
 * 最终返回给前端的完整JSON示例:
 * {
 *  "code":200,
 * "message":"success",
 * "data":{
 *   "success":true,
 *  "message":"秒杀成功",
 * "orderNo":"SK2024117123456789"
 * "timestamp":1705491234567
 * },
 * "timestamp":1705491234567
 * }
 */
@Data
public class SeckillResult implements Serializable{
    private static final long serialVersionUID = 1L;

    /**
     * 是否秒杀成功
     * true:成功,获得了订单
     * false:失败,原因看message字段
     * 
     */
    private boolean success;

    /**
     * 提示信息
     * 成功时:“秒杀成功”
     * 失败时:库存不足
     * 
     */
    private String message;


    /**
     * 订单号
     * 秒杀成功时返回,用于:
     * 1.前端展示给用户("您的订单号是xxxx")
     * 2.跳转订单详情页的凭证
     * 3.支付时关联订单
     * 
     * 失败时此字段为null
     */
    private String orderNo;


    /**
     * 结果时间戳
     * 记录秒杀结果生成的时间
     * 与Result中的timestamp不同
     * 
     */
    private Long timestamp;


    /**
     * 全参构造函数
     */
    public SeckillResult(boolean success, String message, String orderNo){
        this.success = success;
        this.message = message;
        this.orderNo = orderNo;
        this.timestamp = System.currentTimeMillis();
    }

    /**
     * 成功响应工厂方法
     * @param orderNo生产的订单号
     * @return SeckillResult对象
     * 
     * 
     */
    public static SeckillResult success(String orderNo){
        return new SeckillResult(true,"秒杀成功",orderNo);
    }

    /**
     * 失败响应工厂方法
     * @param message 失败原因
     * @return SeckillResult对象
     */
    public static SeckillResult fail(String message){
        return new SeckillResult(false,message,null);
    }
}
