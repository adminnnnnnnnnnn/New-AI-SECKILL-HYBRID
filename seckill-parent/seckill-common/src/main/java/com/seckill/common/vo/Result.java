package com.seckill.common.vo;

import lombok.Data;
import java.io.Serializable;

/**
 * 统一相应结果封装
 * 作用:让所有的接口返回相同格式的JSON,方便前端统一处理
 * 这样前端只需要写一套相应拦截代码,而不是每个接口单独处理
 * 
 * 实际返回的JSON格式实例:
 * {
 *     "code":200,
 *     "message":"success",
 *     "data":{...}
 *    "timestamp":1705491234567
 * }
 * 
 * @param<T> 数据类型(泛型),可以是Order、Product、List、String等任意类型
 * 
 */
@Data
public class Result<T> implements Serializable{
    private static final long serialVersionUID = 1L;

    /**
     *200:请求成功
     *400：客户端参数错误(如缺少必填字段、格式错误)
     *401:未认证/未登录
     *403:w无权限访问
     *404:资源不存在
     *500:服务器内部错误 
    *
    */
   private int code;
   /**
    * 提示信息
    * 用于给前端展示给用户的文案,如'秒杀成功'、'库存不足''
    *  */   
   private String message;

   /**
    * 业务数据
    * 泛型T表示可以是任意类型:
    * -查询单个对象:Result<User>
    * -查询列表:Result<List<Product>>
    * -操作成功无数据:Result<Void>
    * 
    */
   private T data;

   /**
    * 时间戳(毫秒级)
    * 作用:
    * 1.前端可以据此计算请求耗时
    * 2.避免前端缓存同一个请求的结果
    * 3.便于排查请求响应时间问题
    * 
    */
   private Long timestamp;
   
   /**
    * 全参构造函数
    * 
    */
   public Result(int code,String message,T data){
    this.code = code;
    this.message = message;
    this.data = data;
    this.timestamp = System.currentTimeMillis();     //自动生成当前时间戳
   }

   /**
    * 成功响应(无自定义消息)
    * 使用默认消息"success"
    * 
    * @param data 要返回的业务数据
    * @return Result对象
    * 
    */
   public static <T> Result<T> success(T data){
    return new Result<>(200,"success",data);
   }


   /**
    * 成功响应(带自定义消息)
    * 
    * @param message 自定义成功消息，如"创建订单成功"
    * @param data    要返回的业务数据
    * @return Result 对象"
    */
   public static <T> Result<T> success(String message,T data){
    return new Result<>(200,message,data);
   }

   /**
    * 错误响应(默认500服务器错误)
    * 
    * @param message 错误提示,如系统繁忙,请稍后再试
    * @return Result对象
    */
   public static <T> Result<T> error(String message){
      return new Result<>(400,message,null);
   }

   /**
    * 错误响应(自定义状态码)
    * @param code 自定义错误码,如400表示参数错误
    * @param message 错误提示
    * @return Result对象
    * 
    */
   public static <T> Result<T> error(int code,String message){
     return new Result<>(code,message,null);
   }
}