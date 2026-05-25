package com.seckill.inspect.service;

/**
 * 验收服务接口
 */
public interface InspectService {
    
    /**
     * 查询验收任务
     */
    Object getInspectTask(String orderNo);
    
    /**
     * 完成验收
     */
    void completeInspection(String taskNo, Object dto);
    
    /**
     * 拒收商品
     */
    void rejectGoods(String taskNo, String reason);
    
    /**
     * 批次追溯查询
     */
    Object getTraceInfo(String batchNo);
    
    /**
     * 生成追溯二维码
     */
    String generateTraceQRCode(Object dto);
    
    /**
     * 查询商品标准
     */
    Object getProductStandard(Long skuId);
}
