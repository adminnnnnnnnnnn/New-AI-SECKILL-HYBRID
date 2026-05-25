package com.seckill.material.service;

import java.util.List;

/**
 * 物资服务接口
 */
public interface MaterialService {
    
    /**
     * 创建采购计划
     */
    String createPurchasePlan(Long applicantId, List<Object> items);
    
    /**
     * 审批采购计划
     */
    void approvePurchasePlan(String planNo, Long approverId, boolean approved, String remark);
    
    /**
     * 创建入库单
     */
    String createInboundOrder(String inboundType, Long warehouseId, List<Object> items);
    
    /**
     * 完成质检
     */
    void completeInspection(String inboundNo, Long inspectorId, String result);
    
    /**
     * 确认入库上架
     */
    void confirmInbound(String inboundNo, Long operatorId);
    
    /**
     * 创建出库单
     */
    String createOutboundOrder(String outboundType, Long warehouseId, String relatedOrderNo, List<Object> items);
    
    /**
     * 创建调拨单
     */
    String createTransferOrder(Long fromWarehouseId, Long toWarehouseId, List<Object> items, Long applicantId);
    
    /**
     * 审批调拨单
     */
    void approveTransferOrder(String transferNo, Long approverId, boolean approved);
}
