package com.seckill.supplier.service;

/**
 * 供应商服务接口
 */
public interface SupplierService {
    
    /**
     * 供应商入驻申请
     */
    String registerSupplier(Object dto);
    
    /**
     * 审核供应商资质
     */
    void auditSupplier(String supplierCode, Long auditorId, boolean approved, String remark);
    
    /**
     * 查询供应商详情
     */
    Object getSupplier(String supplierCode);
    
    /**
     * 评价供应商
     */
    void evaluateSupplier(String supplierCode, Object evaluation);
    
    /**
     * 查询供应商绩效
     */
    Object getPerformance(String supplierCode);
    
    /**
     * 加入黑名单
     */
    void addToBlacklist(String supplierCode, String reason);
    
    /**
     * 按评级查询供应商
     */
    Object getSuppliersByRating(String rating);
}
