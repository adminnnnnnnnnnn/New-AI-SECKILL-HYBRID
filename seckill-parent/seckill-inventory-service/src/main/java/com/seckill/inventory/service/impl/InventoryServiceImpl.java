package com.seckill.inventory.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.seckill.inventory.entity.SkuInventory;
import com.seckill.inventory.mapper.SkuInventoryMapper;
import com.seckill.inventory.service.InventoryService;
import io.seata.spring.annotation.GlobalTransactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.concurrent.TimeUnit;

/**
 * 库存服务实现类
 * 
 * 核心技术:
 * 1. Redis Lua脚本 - 原子扣减库存,防止超卖
 * 2. Redisson分布式锁 - 防止并发冲突
 * 3. Seata分布式事务 - 跨服务一致性
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class InventoryServiceImpl implements InventoryService {

    private final StringRedisTemplate redisTemplate;
    private final RedissonClient redissonClient;
    private final SkuInventoryMapper skuInventoryMapper;

    /**
     * 秒杀库存扣减 - 使用Redis Lua脚本保证原子性
     * 
     * @param sessionId 秒杀场次ID
     * @param skuId SKU ID
     * @param quantity 扣减数量
     * @return true-扣减成功, false-库存不足
     */
    @Override
    public boolean decreaseSeckillStock(Long sessionId, Long skuId, Integer quantity) {
        String stockKey = "stock:seckill:" + sessionId + ":" + skuId;
        
        // Lua脚本: 原子扣减库存
        String luaScript = 
            "local stock = tonumber(redis.call('get', KEYS[1])) " +
            "if stock and stock >= tonumber(ARGV[1]) then " +
            "   redis.call('decrby', KEYS[1], ARGV[1]) " +
            "   return 1 " +
            "end " +
            "return 0";
        
        try {
            Long result = redisTemplate.execute(
                new DefaultRedisScript<>(luaScript, Long.class),
                Collections.singletonList(stockKey),
                quantity.toString()
            );
            
            boolean success = result != null && result == 1;
            log.info("秒杀库存扣减: sessionId={}, skuId={}, quantity={}, result={}", 
                    sessionId, skuId, quantity, success);
            return success;
            
        } catch (Exception e) {
            log.error("秒杀库存扣减失败", e);
            return false;
        }
    }

    /**
     * 预占库存 - 使用Redisson分布式锁防止并发冲突
     * 
     * @param userId 用户ID
     * @param skuId SKU ID
     * @param quantity 预占数量
     * @return 预占编号
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public String preOccupyStock(Long userId, Long skuId, Integer quantity) {
        String lockKey = "lock:stock:" + userId + ":" + skuId;
        RLock lock = redissonClient.getLock(lockKey);
        
        try {
            // 尝试加锁,最多等待5秒,锁定10秒后自动释放
            if (lock.tryLock(5, 10, TimeUnit.SECONDS)) {
                
                // 1. 查询库存
                SkuInventory inventory = skuInventoryMapper.selectOne(
                    new LambdaQueryWrapper<SkuInventory>()
                        .eq(SkuInventory::getSkuId, skuId)
                );
                
                if (inventory == null || inventory.getAvailableQuantity() < quantity) {
                    throw new RuntimeException("库存不足");
                }
                
                // 2. 扣减可用库存,增加预占库存
                inventory.setAvailableQuantity(inventory.getAvailableQuantity() - quantity);
                inventory.setOccupiedQuantity(inventory.getOccupiedQuantity() + quantity);
                skuInventoryMapper.updateById(inventory);
                
                // 3. 生成预占编号
                String occupyNo = "OCC" + System.currentTimeMillis();
                
                // 4. 保存预占记录到Redis(30分钟过期)
                String occupyKey = "occupy:" + occupyNo;
                redisTemplate.opsForValue().set(occupyKey, userId.toString(), 30, TimeUnit.MINUTES);
                
                log.info("预占库存成功: occupyNo={}, userId={}, skuId={}, quantity={}", 
                        occupyNo, userId, skuId, quantity);
                
                return occupyNo;
                
            } else {
                throw new RuntimeException("系统繁忙,请稍后重试");
            }
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("系统异常");
        } finally {
            // 释放锁
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
    }

    /**
     * 确认扣减 - 支付成功后正式扣减库存
     * 
     * @param occupyNo 预占编号
     */
    @Override
    @GlobalTransactional(name = "confirm-stock-deduction-tx", rollbackFor = Exception.class)
    public void confirmStockDeduction(String occupyNo) {
        // 1. 从Redis获取预占信息
        String occupyKey = "occupy:" + occupyNo;
        String userId = redisTemplate.opsForValue().get(occupyKey);
        
        if (userId == null) {
            throw new RuntimeException("预占记录不存在或已过期");
        }
        
        // 2. 删除预占记录
        redisTemplate.delete(occupyKey);
        
        // 3. 更新数据库: 减少预占库存,减少总库存
        // TODO: 根据实际业务逻辑实现
        
        log.info("确认扣减库存成功: occupyNo={}", occupyNo);
    }

    /**
     * 释放预占库存 - 超时取消或用户主动取消
     * 
     * @param occupyNo 预占编号
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void releaseOccupiedStock(String occupyNo) {
        // 1. 从Redis获取预占信息
        String occupyKey = "occupy:" + occupyNo;
        String userId = redisTemplate.opsForValue().get(occupyKey);
        
        if (userId == null) {
            log.warn("预占记录不存在: occupyNo={}", occupyNo);
            return;
        }
        
        // 2. 删除预占记录
        redisTemplate.delete(occupyKey);
        
        // 3. 回滚库存: 增加可用库存,减少预占库存
        // TODO: 根据实际业务逻辑实现
        
        log.info("释放预占库存成功: occupyNo={}", occupyNo);
    }

    /**
     * 查询库存
     * 
     * @param warehouseId 仓库ID
     * @param skuId SKU ID
     * @return 库存数量
     */
    @Override
    public Integer getStock(Long warehouseId, Long skuId) {
        SkuInventory inventory = skuInventoryMapper.selectOne(
            new LambdaQueryWrapper<SkuInventory>()
                .eq(SkuInventory::getWarehouseId, warehouseId)
                .eq(SkuInventory::getSkuId, skuId)
        );
        
        return inventory != null ? inventory.getAvailableQuantity() : 0;
    }

    /**
     * 库存预警检查 - 定时任务调用
     */
    @Override
    public void checkInventoryAlert() {
        // 查询所有库存低于安全阈值的商品
        java.util.List<SkuInventory> lowStockList = skuInventoryMapper.selectList(
            new LambdaQueryWrapper<SkuInventory>()
                .le(SkuInventory::getAvailableQuantity, 10)
        );
        
        for (SkuInventory inventory : lowStockList) {
            log.warn("库存预警: warehouseId={}, skuId={}, availableQuantity={}", 
                    inventory.getWarehouseId(), 
                    inventory.getSkuId(), 
                    inventory.getAvailableQuantity());
            
            // TODO: 发送MQ消息通知采购员
            // rocketMQTemplate.convertAndSend("inventory-alert-topic", inventory);
        }
    }
}
