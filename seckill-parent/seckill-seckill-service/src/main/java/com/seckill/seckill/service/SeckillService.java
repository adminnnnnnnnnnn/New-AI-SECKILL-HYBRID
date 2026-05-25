package com.seckill.seckill.service;
//======导入语句解析==================
import com.seckill.common.vo.SeckillRequest;  //秒杀请求参数对象
import com.seckill.common.vo.SeckillResult;   //秒杀结果对象
import com.seckill.common.vo.Result;  // 添加 Result 导入
import com.seckill.seckill.feign.OrderFeignClient;  //Feign客户端,用于调用订单服务
import lombok.extern.slf4j.Slf4j;                   //Lombok日志注解,生成Log对象
import org.springframework.beans.factory.annotation.Autowired;  //依赖注入
import com.seckill.seckill.feign.AIAgentCircuitService; // AI Agent 调用服务
import org.springframework.beans.factory.annotation.Value;      //读取配置文件的值
import org.springframework.data.redis.core.RedisTemplate;       //Redis操作模板
import org.springframework.stereotype.Service;                  //标记为Service层组件   

import jakarta.annotation.PostConstruct;//构造方法执行后调用的初始化注解
import java.math.BigDecimal;          //精确小数运算(金额必须用这个,不能用double) 
import java.util.concurrent.*;        //线程池、阻塞队列、异步编程
import java.util.concurrent.atomic.AtomicLong;       //原子Long,线程安全的计数器
import java.util.Map;

/**
 * 秒杀服务类
 * 
 * @author seckill
 * @date 2026-04-25
 */
//标记为Spring Bean,会被组件扫描发现  
@Service
//生成一个Log对象,等价于private static final Logger log = LoggerFactory.getLogger
@Slf4j
public class SeckillService {
    /**
     * RedisTemplate:Spring Data Redis提供的核心操作类 
     * 泛型<String,Object>:Key是String类型,Value是Object类型 
     * 
     * 常见操作:
     * -opsForValue():String类型操作(get/set/increment/decrement)
     * -opsForList():List类型操作(leftPush/rightPop等)
     * -opsForHash():Hash类型操作
     */
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    /**
     * OrderFeignClient:声明式HTTP客户端
     * 用于调用订单服务的/order/create接口
     * 底层使用Ribbon做负载均衡,支持熔断降级
     */

    @Autowired
    private OrderFeignClient orderFeignClient;

    @Autowired
    private AIAgentCircuitService aiAgentClient;
    
    // ==================胚子文件注入 ==============

    @Value("${seckill.queue.capacity:10000}")
    private int queueCapacity;            //内存队列最大容量,防止内存溢出
    
    @Value("${seckill.queue.consumer-threads:10}")
    private int consumerThreads;      //消费者线程数,决定并发处理能力
    
    private BlockingQueue<SeckillTask> queue;
    private static final String STOCK_KEY = "seckill:stock:";
   /**
    *用户限流Key前缀
    *seckill:user:123:1 表示用户123对商品1的限流记录
    *配合TTL(过期时间)使用,实现10秒内只能请求一次
   
   */

    private static final String USER_LIMIT_KEY = "seckill:user:";
    /**
     * AtomicLong:原子操作类
     * 相比普通的long,AtomicLong的incrementAndGet()是线程安全的
     * 无需加synchronized关键字
     */
    private final AtomicLong successCount = new AtomicLong(0);           //成功次数
    private final AtomicLong failCount = new AtomicLong(0);              //失败次数
    
    @PostConstruct
    public void init() {
        //创建有界阻塞队列,容量从配置文件读取
        //为什么用有界队列？防止突发流量导致内存溢出(OOM)
        queue = new ArrayBlockingQueue<>(queueCapacity);
        /**
         * 创建固定大小的线程池
         * Executors.newFixedThreadPool(10)等价于:
         */
        ExecutorService consumerPool = Executors.newFixedThreadPool(consumerThreads);
        for (int i = 0; i < consumerThreads; i++) {
            consumerPool.submit(new Consumer());
        }
        
        initStockToRedis();

        // 异步调用 AI 服务获取初始统计/建议，写入 Redis 供前端使用
        try {
            new Thread(() -> {
                try {
                    Map<String, Object> stats = aiAgentClient.getStats();
                    // 将统计信息写入Redis用于前端读取（key: seckill:ai:stats）
                    if (stats != null && stats.containsKey("data")) {
                        redisTemplate.opsForValue().set("seckill:ai:stats", stats.get("data"));
                    }
                    log.info("已加载 AI 分析统计到 Redis");
                } catch (Exception e) {
                    log.warn("初始化时调用 AI 服务失败，采用本地数据: {}", e.getMessage());
                }
            }).start();
        } catch (Exception e) {
            log.warn("触发 AI 初始化调用失败: {}", e.getMessage());
        }
        
        log.info("秒杀服务初始化完成，队列容量: {}, 消费者线程数: {}", queueCapacity, consumerThreads);
    }
    
    private void initStockToRedis() {
        log.info("开始加载库存到Redis...");
        redisTemplate.opsForValue().set(STOCK_KEY + 1, 100);
        redisTemplate.opsForValue().set(STOCK_KEY + 2, 100);
        log.info("库存加载完成: 商品1=100, 商品2=100");
    }
    
    public SeckillResult seckill(SeckillRequest request) {
        Long userId = request.getUserId();
        Long productId = request.getProductId();
        Integer quantity = request.getQuantity();
        
        log.info("用户{}开始秒杀商品{}, 数量{}", userId, productId, quantity);
        
        // ========== 第一步：Redis预检库存 ==========
        Integer currentStock = (Integer) redisTemplate.opsForValue().get(STOCK_KEY + productId);
        if (currentStock == null || currentStock < quantity) {
            log.warn("库存不足，当前库存: {}", currentStock);
            failCount.incrementAndGet();
            return SeckillResult.fail("库存不足");
        }
        
        // ========== 第二步：用户限流 ==========
        String userLimitKey = USER_LIMIT_KEY + userId + ":" + productId;
        Boolean setIfAbsent = redisTemplate.opsForValue().setIfAbsent(userLimitKey, "1", 10, TimeUnit.SECONDS);
        if (setIfAbsent == null || !setIfAbsent) {
            log.warn("用户请求过于频繁, userId: {}", userId);
            failCount.incrementAndGet();
            return SeckillResult.fail("请勿重复提交");
        }
        
        // ========== 第三步：Redis原子递减库存 ==========
        Long newStock = redisTemplate.opsForValue().decrement(STOCK_KEY + productId, quantity);
        if (newStock == null || newStock < 0) {
            redisTemplate.opsForValue().increment(STOCK_KEY + productId, quantity);
            log.warn("库存不足（二次校验）");
            failCount.incrementAndGet();
            return SeckillResult.fail("库存不足");
        }
        
        // ========== 第四步：异步处理 ==========
        SeckillTask task = new SeckillTask(userId, productId, quantity);
        try {
            boolean offered = queue.offer(task, 100, TimeUnit.MILLISECONDS);
            if (!offered) {
                redisTemplate.opsForValue().increment(STOCK_KEY + productId, quantity);
                failCount.incrementAndGet();
                return SeckillResult.fail("系统繁忙，请稍后重试");
            }
            
            SeckillResult result = task.getFuture().get(3, TimeUnit.SECONDS);
            if (result.isSuccess()) {
                successCount.incrementAndGet();
            } else {
                failCount.incrementAndGet();
                redisTemplate.opsForValue().increment(STOCK_KEY + productId, quantity);
            }
            return result;
        } catch (Exception e) {
            log.error("秒杀处理异常", e);
            redisTemplate.opsForValue().increment(STOCK_KEY + productId, quantity);
            failCount.incrementAndGet();
            return SeckillResult.fail("系统异常");
        } finally {
            redisTemplate.delete(userLimitKey);
        }
    }
    
    /**
     * 获取成功数量
     */
    public long getSuccessCount() {
        return successCount.get();
    }
    
    /**
     * 获取失败数量
     */
    public long getFailCount() {
        return failCount.get();
    }
    
    /**
     * 获取队列大小
     */
    public int getQueueSize() {
        return queue.size();
    }
    
    /**
     * 获取AI统计信息
     */
    public Object getAIStats() {
        return redisTemplate.opsForValue().get("seckill:ai:stats");
    }
    
    /**
     * 消费者线程类
     */
    private class Consumer implements Runnable {
        @Override
        public void run() {
            while (true) {
                try {
                    SeckillTask task = queue.take();
                    processTask(task);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        }
        
        /**
         * 处理秒杀任务
         */
        private void processTask(SeckillTask task) {
            try {
                // 根据商品ID确定秒杀价格
                BigDecimal amount;
                if (task.getProductId() == 1) {
                    amount = new BigDecimal("6999.00");  // iPhone 15 Pro 秒杀价
                } else if (task.getProductId() == 2) {
                    amount = new BigDecimal("4999.00");  // 华为 Mate 60 Pro 秒杀价
                } else {
                    amount = new BigDecimal("5999.00");  // 默认价格
                }
                
                // 使用 Result 类型（项目中已有的类）
                Result<String> result = orderFeignClient.createOrder(
                    task.getUserId(), task.getProductId(), task.getQuantity(), amount.toString());
                
                if (result != null && result.getCode() == 200 && result.getData() != null) {
                    task.getFuture().complete(SeckillResult.success(result.getData()));
                } else {
                    String errorMsg = result != null ? result.getMessage() : "创建订单失败";
                    task.getFuture().complete(SeckillResult.fail(errorMsg));
                }
            } catch (Exception e) {
                log.error("处理任务失败", e);
                task.getFuture().complete(SeckillResult.fail("处理失败"));
            }
        }
    }
    
    /**
     * 秒杀任务内部类
     */
    private static class SeckillTask {
        private final Long userId;
        private final Long productId;
        private final Integer quantity;
        private final CompletableFuture<SeckillResult> future;
        
        public SeckillTask(Long userId, Long productId, Integer quantity) {
            this.userId = userId;
            this.productId = productId;
            this.quantity = quantity;
            this.future = new CompletableFuture<>();
        }
        
        public Long getUserId() { return userId; }
        public Long getProductId() { return productId; }
        public Integer getQuantity() { return quantity; }
        public CompletableFuture<SeckillResult> getFuture() { return future; }
    }
}