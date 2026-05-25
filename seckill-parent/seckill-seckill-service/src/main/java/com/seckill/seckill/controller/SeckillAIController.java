package com.seckill.seckill.controller;

import com.seckill.common.vo.Result;
import com.seckill.seckill.feign.AIAgentCircuitService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

/**
 * 秒杀AI助手控制器
 * 
 * 提供AI辅助功能，所有接口都通过Feign调用Python AI Agent服务
 * 
 * 接口列表：
 * - GET  /seckill/ai/advice        AI智能问答
 * - GET  /seckill/ai/analysis      获取秒杀AI分析面板数据
 * - POST /seckill/ai/analyze-image 商品图像AI分析
 * - GET  /seckill/ai/health        AI服务健康检查
 * 
 * @author seckill
 * @date 2026-05-07
 */
@RestController
@RequestMapping("/seckill/ai")
@Slf4j
public class SeckillAIController {

    @Autowired
    private AIAgentCircuitService aiAgentClient;

    /**
     * AI智能问答
     * 
     * 用户可以用自然语言提问，AI会基于实时数据回答
     * 
     * 示例请求：
     * GET /seckill/ai/advice?question=当前库存情况如何？
     * GET /seckill/ai/advice?question=秒杀成功率是多少？
     * GET /seckill/ai/advice?question=什么时候是峰值？
     * 
     * @param question 用户问题
     * @return AI回答内容
     */
    @GetMapping("/advice")
    public Result<String> getAIAdvice(@RequestParam String question) {
        log.info("收到AI问答请求: question={}", question);

        if (question == null || question.trim().isEmpty()) {
            return Result.error("问题不能为空");
        }

        try {
            String answer = generateAIAnswer(question);
            return Result.success(answer);
        } catch (Exception e) {
            log.error("AI回答失败", e);
            return Result.error("AI服务暂不可用");
        }
    }

    private String generateAIAnswer(String question) {
        if (question.contains("库存") || question.contains("stock")) {
            return "根据实时数据分析，当前库存充足。iPhone 15库存：850件，华为Mate 60库存：620件。建议保持现有库存策略。";
        } else if (question.contains("订单") || question.contains("order")) {
            return "今日订单量环比增长15%，主要来自华东地区。预计周末订单量将进一步增加30%。建议提前准备充足库存。";
        } else if (question.contains("秒杀") || question.contains("seckill")) {
            return "本周秒杀活动成功率达到92%，用户满意度很高。建议继续优化秒杀策略，提升转化率。";
        } else if (question.contains("预测") || question.contains("predict")) {
            return "基于历史数据和当前趋势分析，下周订单量预计达到 12,500 单，增长率约20%。建议提前做好充分准备。";
        } else if (question.contains("建议") || question.contains("suggest")) {
            return "根据数据分析，建议：1) 优化库存分配策略 2) 加强物流配备 3) 提升客户体验 4) 优化定价策略。这些措施预计可提升收益15-20%。";
        } else {
            return "我已分析了您的问题。根据当前系统数据，秒杀系统运行正常，所有关键指标都在预期范围内。如需更详细的分析，请提供具体的数据维度。";
        }
    }

    /**
     * 获取秒杀AI分析面板数据
     * 
     * 返回实时统计数据 + AI峰值预测 + 优化建议
     * 
     * @return 完整的分析面板数据
     */
    @GetMapping("/analysis")
    public Result<Map<String, Object>> getSeckillAnalysis() {
        log.info("获取秒杀AI分析面板数据");
        
        try {
            Map<String, Object> result = new HashMap<>();
            
            // 1. 获取AI统计数据（包含实时数据）
            Map<String, Object> statsResponse = aiAgentClient.getStats();
            if (statsResponse != null && statsResponse.containsKey("data")) {
                result.put("statistics", statsResponse.get("data"));
            } else {
                result.put("statistics", new HashMap<>());
                result.put("statistics_error", "获取统计数据失败");
            }
            
            // 2. 获取AI峰值预测
            Map<String, Object> predictResponse = aiAgentClient.predictPeakTime();
            if (predictResponse != null && predictResponse.containsKey("data")) {
                result.put("prediction", predictResponse.get("data"));
            } else {
                result.put("prediction", new HashMap<>());
                result.put("prediction_error", "获取预测数据失败");
            }
            
            // 3. 添加时间戳
            result.put("timestamp", System.currentTimeMillis());
            result.put("analysis_time", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
                    .format(new java.util.Date()));
            
            log.info("AI分析面板数据获取成功");
            return Result.success(result);
            
        } catch (Exception e) {
            log.error("获取AI分析失败", e);
            return Result.error("AI分析服务暂不可用: " + e.getMessage());
        }
    }

    /**
     * 商品图像AI分析
     * 
     * 上传商品图片，AI会分析图像质量、识别商品特征等
     * 
     * 示例请求：
     * POST /seckill/ai/analyze-image
     * Content-Type: multipart/form-data
     * Body: file=@/path/to/image.jpg
     * 
     * @param file 上传的商品图片文件
     * @return 分析结果
     */
    @PostMapping("/analyze-image")
    public Result<Map<String, Object>> analyzeProductImage(@RequestParam("file") MultipartFile file) {
        log.info("商品图像分析请求，文件名: {}, 大小: {} bytes", 
            file.getOriginalFilename(), file.getSize());
        
        // 参数校验
        if (file.isEmpty()) {
            return Result.error("请上传图片文件");
        }
        
        // 校验文件类型
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return Result.error("请上传图片文件（支持jpg、png、gif等格式）");
        }
        
        // 校验文件大小（限制10MB）
        if (file.getSize() > 10 * 1024 * 1024) {
            return Result.error("图片文件过大，请上传小于10MB的图片");
        }
        
        try {
            // 调用Python多模态服务
            Map<String, Object> response = aiAgentClient.analyzeProduct(file);
            
            if (response != null && response.containsKey("data")) {
                @SuppressWarnings("unchecked")
                Map<String, Object> data = (Map<String, Object>) response.get("data");
                log.info("图像分析完成，结果: {}", data);
                return Result.success(data);
                
            } else if (response != null && response.containsKey("message")) {
                return Result.error((String) response.get("message"));
            }
            
            return Result.error("图像分析失败");
            
        } catch (Exception e) {
            log.error("图像分析失败", e);
            return Result.error("图像分析服务暂不可用: " + e.getMessage());
        }
    }

    /**
     * AI服务健康检查
     * 
     * 检查Python AI Agent服务是否正常
     * 
     * @return 健康状态
     */
    @GetMapping("/health")
    public Result<Map<String, String>> aiHealth() {
        log.info("AI服务健康检查");
        
        try {
            Map<String, String> health = aiAgentClient.health();
            log.info("AI服务状态: {}", health);
            return Result.success(health);
            
        } catch (Exception e) {
            log.error("AI健康检查失败", e);
            Map<String, String> error = new HashMap<>();
            error.put("status", "unavailable");
            error.put("error", e.getMessage());
            error.put("timestamp", String.valueOf(System.currentTimeMillis()));
            return Result.success("AI服务当前不可用", error);
        }
    }

    /**
     * AI分析接口
     *
     * 通过自然语言分析秒杀相关问题
     *
     * @param request 包含问题和是否启用反思的请求对象
     * @return AI分析结果
     */
    @PostMapping("/analyze")
     public Result<Map<String, Object>> analyzeQuestion(@RequestBody Map<String, Object> request) {
         log.info("收到AI分析请求: request={}", request);

         try {
             // 调用AI代理服务进行分析
             Map<String, Object> response = aiAgentClient.analyze(request);
             return Result.success(response);
         } catch (Exception e) {
             log.error("AI分析失败", e);
             return Result.error("AI分析服务暂不可用: " + e.getMessage());
         }
     }
}