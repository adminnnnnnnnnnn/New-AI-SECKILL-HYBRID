package com.seckill.inventory.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.seckill.inventory.entity.SkuInventory;
import org.apache.ibatis.annotations.Mapper;

/**
 * SKU库存Mapper接口
 */
@Mapper
public interface SkuInventoryMapper extends BaseMapper<SkuInventory> {
}
