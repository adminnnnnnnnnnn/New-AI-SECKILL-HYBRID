package com.seckill.inventory.service;

/**
 * 库存服务接口
 */
public interface InventoryService {
    
    /**
     * 秒杀库存扣减(Redis原子操作)
     */
    boolean decreaseSeckillStock(Long sessionId, Long skuId, Integer quantity);
    
    /**
     * 预占库存(待支付订单)
     */
    String preOccupyStock(Long userId, Long skuId, Integer quantity);
    
    /**
     * 确认扣减(支付成功后)
     */
    void confirmStockDeduction(String occupyNo);
    
    /**
     * 释放预占库存(超时取消)
     */
    void releaseOccupiedStock(String occupyNo);
    
    /**
     * 查询库存
     */
    Integer getStock(Long warehouseId, Long skuId);
    
    /**
     * 库存预警检查
     */
    void checkInventoryAlert();
}
