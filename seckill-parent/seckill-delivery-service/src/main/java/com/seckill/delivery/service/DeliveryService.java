package com.seckill.delivery.service;

/**
 * 配送服务接口
 */
public interface DeliveryService {
    
    /**
     * 创建配送单
     */
    String createDeliveryOrder(Object dto);
    
    /**
     * 更新配送状态
     */
    void updateDeliveryStatus(String deliveryNo, Integer status, String remark);
    
    /**
     * 查询物流轨迹
     */
    Object getTrajectory(String deliveryNo);
    
    /**
     * 签收确认
     */
    void confirmSign(String deliveryNo, String signProofImage, String signature);
    
    /**
     * 上报异常
     */
    void reportException(String deliveryNo, String reason);
    
    /**
     * 按状态查询配送单
     */
    Object getDeliveryByStatus(Integer status);
}
