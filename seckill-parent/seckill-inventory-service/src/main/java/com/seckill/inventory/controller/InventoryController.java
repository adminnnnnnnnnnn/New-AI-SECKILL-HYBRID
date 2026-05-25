package com.seckill.inventory.controller;

import com.seckill.inventory.service.InventoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
@Tag(name = "库存管理", description = "库存扣减、预占、查询")
public class InventoryController {

    private final InventoryService inventoryService;

    @PostMapping("/seckill/decrease")
    @Operation(summary = "秒杀库存扣减")
    public boolean decreaseSeckillStock(
            @RequestParam Long sessionId,
            @RequestParam Long skuId,
            @RequestParam Integer quantity) {
        return inventoryService.decreaseSeckillStock(sessionId, skuId, quantity);
    }

    @PostMapping("/occupy")
    @Operation(summary = "预占库存")
    public String preOccupyStock(
            @RequestParam Long userId,
            @RequestParam Long skuId,
            @RequestParam Integer quantity) {
        return inventoryService.preOccupyStock(userId, skuId, quantity);
    }

    @PostMapping("/confirm/{occupyNo}")
    @Operation(summary = "确认扣减库存")
    public void confirmStockDeduction(@PathVariable String occupyNo) {
        inventoryService.confirmStockDeduction(occupyNo);
    }

    @PostMapping("/release/{occupyNo}")
    @Operation(summary = "释放预占库存")
    public void releaseOccupiedStock(@PathVariable String occupyNo) {
        inventoryService.releaseOccupiedStock(occupyNo);
    }

    @GetMapping("/stock")
    @Operation(summary = "查询库存")
    public Integer getStock(
            @RequestParam Long warehouseId,
            @RequestParam Long skuId) {
        return inventoryService.getStock(warehouseId, skuId);
    }

    @PostMapping("/alert/check")
    @Operation(summary = "库存预警检查")
    public void checkInventoryAlert() {
        inventoryService.checkInventoryAlert();
    }
}
