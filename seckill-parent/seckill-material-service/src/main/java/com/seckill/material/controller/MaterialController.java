package com.seckill.material.controller;

import com.seckill.material.service.MaterialService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/material")
@RequiredArgsConstructor
@Tag(name = "物资管理", description = "采购计划、出入库、调拨管理")
public class MaterialController {

    private final MaterialService materialService;

    @PostMapping("/purchase-plan")
    @Operation(summary = "创建采购计划")
    public String createPurchasePlan(@RequestBody PurchasePlanCreateDTO dto) {
        return materialService.createPurchasePlan(dto.getApplicantId(), dto.getItems());
    }

    @PostMapping("/purchase-plan/{planNo}/approve")
    @Operation(summary = "审批采购计划")
    public void approvePurchasePlan(
            @PathVariable String planNo,
            @RequestParam Long approverId,
            @RequestParam boolean approved,
            @RequestParam(required = false) String remark) {
        materialService.approvePurchasePlan(planNo, approverId, approved, remark);
    }

    @PostMapping("/inbound")
    @Operation(summary = "创建入库单")
    public String createInboundOrder(@RequestBody InboundOrderCreateDTO dto) {
        return materialService.createInboundOrder(dto.getInboundType(), dto.getWarehouseId(), dto.getItems());
    }

    @PostMapping("/inbound/{inboundNo}/inspect")
    @Operation(summary = "完成质检")
    public void completeInspection(
            @PathVariable String inboundNo,
            @RequestParam Long inspectorId,
            @RequestParam String result) {
        materialService.completeInspection(inboundNo, inspectorId, result);
    }

    @PostMapping("/inbound/{inboundNo}/confirm")
    @Operation(summary = "确认入库上架")
    public void confirmInbound(@PathVariable String inboundNo, @RequestParam Long operatorId) {
        materialService.confirmInbound(inboundNo, operatorId);
    }

    @PostMapping("/outbound")
    @Operation(summary = "创建出库单")
    public String createOutboundOrder(@RequestBody OutboundOrderCreateDTO dto) {
        return materialService.createOutboundOrder(
            dto.getOutboundType(), 
            dto.getWarehouseId(), 
            dto.getRelatedOrderNo(), 
            dto.getItems()
        );
    }

    @PostMapping("/transfer")
    @Operation(summary = "创建调拨单")
    public String createTransferOrder(@RequestBody TransferOrderCreateDTO dto) {
        return materialService.createTransferOrder(
            dto.getFromWarehouseId(),
            dto.getToWarehouseId(),
            dto.getItems(),
            dto.getApplicantId()
        );
    }

    @PostMapping("/transfer/{transferNo}/approve")
    @Operation(summary = "审批调拨单")
    public void approveTransferOrder(
            @PathVariable String transferNo,
            @RequestParam Long approverId,
            @RequestParam boolean approved) {
        materialService.approveTransferOrder(transferNo, approverId, approved);
    }
}
