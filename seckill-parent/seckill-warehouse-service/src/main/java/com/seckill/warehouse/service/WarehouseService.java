package com.seckill.warehouse.service;

/**
 * 仓储服务接口
 */
public interface WarehouseService {
    
    /**
     * 创建仓库
     */
    String createWarehouse(Object dto);
    
    /**
     * 查询仓库详情
     */
    Object getWarehouse(Long warehouseId);
    
    /**
     * 创建库位
     */
    String createLocation(Object dto);
    
    /**
     * 创建盘点任务
     */
    String createCheckTask(Object dto);
    
    /**
     * 提交盘点结果
     */
    void submitCheckResult(String checkNo, java.util.List<Object> results);
    
    /**
     * 审批盘点差异
     */
    void approveCheckDifference(String checkNo, Long approverId, boolean approved);
    
    /**
     * 查询仓库库存
     */
    Object getWarehouseInventory(Long warehouseId);
    
    /**
     * 查询库存预警
     */
    Object getInventoryAlerts();
}
