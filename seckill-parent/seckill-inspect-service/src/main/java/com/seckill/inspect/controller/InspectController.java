package com.seckill.inspect.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/inspect")
@RequiredArgsConstructor
@Tag(name = "验收管理", description = "验收任务、质检记录、批次追溯")
public class InspectController {

    @GetMapping("/task/{orderNo}")
    @Operation(summary = "查询验收任务")
    public Object getInspectTask(@PathVariable String orderNo) {
        // TODO: 根据订单号查询验收任务
        return null;
    }

    @PostMapping("/task/{taskNo}/complete")
    @Operation(summary = "完成验收")
    public void completeInspection(
            @PathVariable String taskNo,
            @RequestBody InspectionCompleteDTO dto) {
        // TODO: 实现验收完成逻辑,保存验收记录和照片
    }

    @PostMapping("/task/{taskNo}/reject")
    @Operation(summary = "拒收商品")
    public void rejectGoods(
            @PathVariable String taskNo,
            @RequestParam String reason) {
        // TODO: 实现拒收逻辑,通知供应商和生成售后单
    }

    @GetMapping("/trace/{batchNo}")
    @Operation(summary = "批次追溯查询")
    public Object getTraceInfo(@PathVariable String batchNo) {
        // TODO: 查询完整追溯链路(原料→生产→质检→包装→仓储→物流→验收)
        return null;
    }

    @PostMapping("/trace/qrcode")
    @Operation(summary = "生成追溯二维码")
    public String generateTraceQRCode(@RequestBody TraceQRCodeDTO dto) {
        // TODO: 生成追溯二维码图片URL
        return "https://example.com/trace/" + dto.getBatchNo();
    }

    @GetMapping("/standard/{skuId}")
    @Operation(summary = "查询商品标准")
    public Object getProductStandard(@PathVariable Long skuId) {
        // TODO: 查询商品质量标准(感官、理化、包装、温控等)
        return null;
    }
}
