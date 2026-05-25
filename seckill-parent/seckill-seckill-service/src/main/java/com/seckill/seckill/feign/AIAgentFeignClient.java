package com.seckill.seckill.feign;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * Python AI Agent 服务 Feign 客户端
 * 
 * 作用：声明式调用 Python FastAPI 服务
 * 
 * 调用示例：
 * <pre>
 * Map<String, String> request = new HashMap<>();
 * request.put("question", "当前库存情况如何？");
 * Map<String, Object> response = aiAgentClient.analyze(request);
 * </pre>
 * 
 * @author seckill
 * @date 2026-05-07
 */
@FeignClient(
    name = "python-ai-agent",
    url = "${ai.agent.url:http://localhost:8000}"
)
public interface AIAgentFeignClient {

    /**
     * AI 秒杀问题分析
     * 
     * 调用 Python 服务的 /api/seckill/analyze 接口
     * 
     * @param request 请求参数，包含 question 和 enable_reflection 字段
     *                例如：{"question": "当前库存情况如何？", "enable_reflection": true}
     * @return AI 分析结果，格式：
     *         {
     *           "code": 200,
     *           "data": {
     *             "answer": "...",
     *             "confidence": 0.85,
     *             "data_snapshot": {...}
     *           }
     *         }
     */
    @PostMapping("/api/seckill/analyze")
    Map<String, Object> analyze(@RequestBody Map<String, Object> request);

    /**
     * 获取秒杀统计数据（AI分析的实时数据源）
     * 
     * @return 统计数据，包含库存、成功/失败次数等
     */
    @GetMapping("/api/seckill/stats")
    Map<String, Object> getStats();

    /**
     * AI 预测秒杀峰值时间
     * 
     * @return 预测结果，包含峰值时间段、预估QPS等
     */
    @PostMapping("/api/seckill/predict")
    Map<String, Object> predictPeakTime();

    /**
     * 多模态商品图像分析
     * 
     * 调用 Python 服务的多模态接口，分析商品图片
     * 
     * @param file 上传的商品图片文件
     * @return 分析结果，包含图像特征、质量评估等
     */
    @PostMapping(
        value = "/api/multimodal/analyze-product",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    Map<String, Object> analyzeProduct(@RequestPart("file") MultipartFile file);

    /**
     * AI 服务健康检查
     * 
     * @return 健康状态，例如：{"status": "healthy"}
     */
    @GetMapping("/health")
    Map<String, String> health();
}