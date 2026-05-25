package com.seckill.order.lock;

import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * 基于 Redis 的分布式锁。优先使用 Redisson（更可靠），在 Redisson 不可用时回退到 StringRedisTemplate 的简单实现，保持与现有测试兼容。
 */
@Component
public class RedisDistributedLock {

    private final StringRedisTemplate redisTemplate;

    // Redisson 可选注入
    private final RedissonClient redissonClient;

    @Autowired
    public RedisDistributedLock(StringRedisTemplate redisTemplate, @Nullable RedissonClient redissonClient) {
        this.redisTemplate = redisTemplate;
        this.redissonClient = redissonClient;
    }

    /**
     * 尝试获取锁，成功返回锁标识（随机值），失败返回 null
     */
    public String tryLock(String key, long seconds) {
        if (redissonClient != null) {
            try {
                RLock lock = redissonClient.getLock(key);
                boolean acquired = lock.tryLock(0, seconds, TimeUnit.SECONDS);
                return acquired ? lock.getName() : null;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return null;
            }
        }

        String value = UUID.randomUUID().toString();
        Boolean ok = redisTemplate.opsForValue().setIfAbsent(key, value, seconds, TimeUnit.SECONDS);
        return Boolean.TRUE.equals(ok) ? value : null;
    }

    /**
     * 释放锁
     */
    public boolean unlock(String key, String value) {
        if (redissonClient != null) {
            RLock lock = redissonClient.getLock(key);
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
                return true;
            }
            return false;
        }

        String lua = "if redis.call('get',KEYS[1]) == ARGV[1] then return redis.call('del',KEYS[1]) else return 0 end";
        DefaultRedisScript<Long> script = new DefaultRedisScript<>(lua, Long.class);
        Long res = redisTemplate.execute(script, Collections.singletonList(key), value);
        return res != null && res > 0;
    }
}
