-- ========================================
-- 供应链集中筹措管理系统 - 完整数据库脚本 v4.0
-- 创建日期: 2026-05-20
-- ========================================

DROP DATABASE IF EXISTS seckill;
CREATE DATABASE seckill DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE seckill;

-- ========================================
-- 1. 用户与权限模块
-- ========================================

-- 用户表
CREATE TABLE `sys_user` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(64) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(128) NOT NULL COMMENT '密码(加密)',
    `real_name` VARCHAR(64) COMMENT '真实姓名',
    `phone` VARCHAR(20) COMMENT '手机号',
    `email` VARCHAR(128) COMMENT '邮箱',
    `role` VARCHAR(32) NOT NULL DEFAULT 'USER' COMMENT '角色: ADMIN/USER/SUPPLIER/INSPECTOR/WAREHOUSE/DELIVERY',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (`username`),
    INDEX idx_phone (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ========================================
-- 2. 商品管理模块 (SPU/SKU模型)
-- ========================================

-- 商品分类表(三级分类)
CREATE TABLE `product_category` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `parent_id` BIGINT DEFAULT 0 COMMENT '父分类ID, 0表示一级',
    `category_name` VARCHAR(64) NOT NULL COMMENT '分类名称',
    `level` TINYINT NOT NULL COMMENT '分类层级: 1/2/3',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_parent_id (`parent_id`),
    INDEX idx_level (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 商品SPU表(标准化产品单元)
CREATE TABLE `product_spu` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `spu_name` VARCHAR(128) NOT NULL COMMENT 'SPU名称',
    `category_id` BIGINT NOT NULL COMMENT '三级分类ID',
    `brand` VARCHAR(64) COMMENT '品牌',
    `origin` VARCHAR(128) COMMENT '产地',
    `description` TEXT COMMENT '商品描述',
    `main_image` VARCHAR(256) COMMENT '主图URL',
    `images` JSON COMMENT '商品图片列表(JSON数组)',
    `quality_standard` TEXT COMMENT '质量标准说明',
    `standard_images` JSON COMMENT '标准图片(正面/侧面/剖面/缺陷示例)',
    `supplier_id` BIGINT COMMENT '供应商ID',
    `status` TINYINT DEFAULT 0 COMMENT '状态: 0-待审核 1-已上架 2-已下架 3-审核驳回',
    `audit_remark` VARCHAR(256) COMMENT '审核备注',
    `auditor_id` BIGINT COMMENT '审核人ID',
    `audit_time` DATETIME COMMENT '审核时间',
    `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category_id (`category_id`),
    INDEX idx_supplier_id (`supplier_id`),
    INDEX idx_status (`status`),
    FOREIGN KEY (`category_id`) REFERENCES `product_category`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SPU表';

-- 商品SKU表(库存量单位)
CREATE TABLE `product_sku` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `spu_id` BIGINT NOT NULL COMMENT 'SPU ID',
    `sku_code` VARCHAR(64) NOT NULL UNIQUE COMMENT 'SKU编码',
    `sku_name` VARCHAR(128) NOT NULL COMMENT 'SKU名称(含规格)',
    `specifications` JSON COMMENT '规格属性(JSON)',
    `normal_price` DECIMAL(10,2) NOT NULL COMMENT '正常售价',
    `seckill_price` DECIMAL(10,2) COMMENT '秒杀价格',
    `unit` VARCHAR(16) DEFAULT '件' COMMENT '计量单位',
    `weight` DECIMAL(10,2) COMMENT '重量(kg)',
    `shelf_life_days` INT COMMENT '保质期(天)',
    `storage_condition` VARCHAR(32) COMMENT '存储条件: 常温/冷藏/冷冻',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_spu_id (`spu_id`),
    INDEX idx_sku_code (`sku_code`),
    FOREIGN KEY (`spu_id`) REFERENCES `product_spu`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SKU表';

-- ========================================
-- 3. 秒杀管理模块
-- ========================================

-- 秒杀场次表
CREATE TABLE `seckill_session` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `session_name` VARCHAR(128) NOT NULL COMMENT '场次名称',
    `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `seckill_price` DECIMAL(10,2) NOT NULL COMMENT '秒杀价格',
    `seckill_stock` INT NOT NULL COMMENT '秒杀库存',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME NOT NULL COMMENT '结束时间',
    `limit_per_user` INT DEFAULT 1 COMMENT '每人限购数量',
    `status` TINYINT DEFAULT 0 COMMENT '状态: 0-未开始 1-进行中 2-已结束 3-已取消',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_sku_id (`sku_id`),
    INDEX idx_start_time (`start_time`),
    INDEX idx_status (`status`),
    FOREIGN KEY (`sku_id`) REFERENCES `product_sku`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='秒杀场次表';

-- 秒杀记录表
CREATE TABLE `seckill_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `session_id` BIGINT NOT NULL COMMENT '秒杀场次ID',
    `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `quantity` INT NOT NULL DEFAULT 1 COMMENT '购买数量',
    `order_no` VARCHAR(64) COMMENT '关联订单号',
    `status` TINYINT DEFAULT 0 COMMENT '0-排队中 1-成功 2-失败 3-已取消',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_session (`user_id`, `session_id`),
    INDEX idx_session_id (`session_id`),
    INDEX idx_user_id (`user_id`),
    FOREIGN KEY (`session_id`) REFERENCES `seckill_session`(`id`),
    FOREIGN KEY (`sku_id`) REFERENCES `product_sku`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='秒杀记录表';

-- ========================================
-- 4. 库存管理模块(多仓库)
-- ========================================

-- 仓库表
CREATE TABLE `warehouse` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `warehouse_code` VARCHAR(32) NOT NULL UNIQUE COMMENT '仓库编码',
    `warehouse_name` VARCHAR(128) NOT NULL COMMENT '仓库名称',
    `warehouse_type` VARCHAR(32) COMMENT '仓库类型: 中心仓/区域仓/前置仓',
    `address` VARCHAR(256) COMMENT '仓库地址',
    `manager` VARCHAR(64) COMMENT '负责人',
    `phone` VARCHAR(20) COMMENT '联系电话',
    `capacity_volume` DECIMAL(10,2) COMMENT '最大存储体积(m³)',
    `capacity_weight` DECIMAL(10,2) COMMENT '最大存储重量(kg)',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0-停用 1-正常',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_warehouse_code (`warehouse_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库表';

-- 库位表
CREATE TABLE `warehouse_location` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `location_code` VARCHAR(32) NOT NULL UNIQUE COMMENT '库位编码',
    `warehouse_id` BIGINT NOT NULL COMMENT '所属仓库ID',
    `location_type` VARCHAR(32) COMMENT '库位类型: 货架区/地堆区/冷藏区/冷冻区',
    `max_capacity` DECIMAL(10,2) COMMENT '最大存储量',
    `current_usage` DECIMAL(10,2) DEFAULT 0 COMMENT '当前占用量',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0-维护中 1-可用 2-已满',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_warehouse_id (`warehouse_id`),
    INDEX idx_location_code (`location_code`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库位表';

-- SKU库存表(多仓库)
CREATE TABLE `sku_inventory` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID',
    `location_id` BIGINT COMMENT '库位ID',
    `total_quantity` INT NOT NULL DEFAULT 0 COMMENT '总库存数量',
    `locked_quantity` INT NOT NULL DEFAULT 0 COMMENT '锁定数量(预占)',
    `available_quantity` INT NOT NULL DEFAULT 0 COMMENT '可用数量',
    `batch_no` VARCHAR(64) COMMENT '批次号',
    `production_date` DATE COMMENT '生产日期',
    `expiry_date` DATE COMMENT '过期日期',
    `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_sku_warehouse_batch (`sku_id`, `warehouse_id`, `batch_no`),
    INDEX idx_sku_id (`sku_id`),
    INDEX idx_warehouse_id (`warehouse_id`),
    FOREIGN KEY (`sku_id`) REFERENCES `product_sku`(`id`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`),
    FOREIGN KEY (`location_id`) REFERENCES `warehouse_location`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='SKU库存表';

-- 库存流水表
CREATE TABLE `inventory_transaction` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `transaction_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '流水号',
    `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID',
    `change_type` VARCHAR(32) NOT NULL COMMENT '变更类型: PURCHASE_IN/SALE_OUT/TRANSFER_IN/TRANSFER_OUT/RETURN_IN/DAMAGE_OUT/CHECK_SURPLUS/CHECK_LOSS',
    `change_quantity` INT NOT NULL COMMENT '变更数量(+/-)',
    `before_quantity` INT NOT NULL COMMENT '变更前数量',
    `after_quantity` INT NOT NULL COMMENT '变更后数量',
    `related_order_no` VARCHAR(64) COMMENT '关联单据号',
    `operator_id` BIGINT COMMENT '操作人ID',
    `remark` VARCHAR(256) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sku_id (`sku_id`),
    INDEX idx_warehouse_id (`warehouse_id`),
    INDEX idx_created_at (`created_at`),
    FOREIGN KEY (`sku_id`) REFERENCES `product_sku`(`id`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存流水表';

-- ========================================
-- 5. 订单管理模块
-- ========================================

-- 订单表
CREATE TABLE `orders` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `order_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '订单号',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `session_id` BIGINT COMMENT '秒杀场次ID',
    `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `quantity` INT NOT NULL DEFAULT 1 COMMENT '购买数量',
    `unit_price` DECIMAL(10,2) NOT NULL COMMENT '单价快照',
    `total_amount` DECIMAL(10,2) NOT NULL COMMENT '订单总额',
    `order_status` TINYINT DEFAULT 0 COMMENT '订单状态: 0-待支付 1-已支付 2-待发货 3-配送中 4-已完成 5-已取消 6-售后中',
    `payment_time` DATETIME COMMENT '支付时间',
    `delivery_time` DATETIME COMMENT '发货时间',
    `receive_time` DATETIME COMMENT '收货时间',
    `cancel_time` DATETIME COMMENT '取消时间',
    `warehouse_id` BIGINT COMMENT '发货仓库ID',
    `delivery_no` VARCHAR(64) COMMENT '配送单号',
    `receiver_name` VARCHAR(64) NOT NULL COMMENT '收货人姓名',
    `receiver_phone` VARCHAR(20) NOT NULL COMMENT '收货人电话',
    `receiver_address` VARCHAR(256) NOT NULL COMMENT '收货地址',
    `remark` VARCHAR(256) COMMENT '订单备注',
    `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_no (`order_no`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_order_status (`order_status`),
    INDEX idx_created_at (`created_at`),
    FOREIGN KEY (`user_id`) REFERENCES `sys_user`(`id`),
    FOREIGN KEY (`session_id`) REFERENCES `seckill_session`(`id`),
    FOREIGN KEY (`sku_id`) REFERENCES `product_sku`(`id`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单表';

-- 订单超时任务表(RocketMQ延时消息补偿)
CREATE TABLE `order_timeout_task` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `order_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '订单号',
    `expire_time` DATETIME NOT NULL COMMENT '过期时间',
    `status` TINYINT DEFAULT 0 COMMENT '状态: 0-待处理 1-已处理 2-已取消',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_expire_time (`expire_time`),
    INDEX idx_status (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单超时任务表';

-- ========================================
-- 6. 物资管理模块
-- ========================================

-- 物资分类表
CREATE TABLE `material_category` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `parent_id` BIGINT DEFAULT 0 COMMENT '父分类ID',
    `category_name` VARCHAR(64) NOT NULL COMMENT '分类名称',
    `level` TINYINT NOT NULL COMMENT '分类层级: 1/2/3',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_parent_id (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物资分类表';

-- 物资档案表
CREATE TABLE `material` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `material_code` VARCHAR(32) NOT NULL UNIQUE COMMENT '物资编码(MT+8位数字)',
    `material_name` VARCHAR(128) NOT NULL COMMENT '物资名称',
    `category_id` BIGINT NOT NULL COMMENT '三级分类ID',
    `specification` VARCHAR(128) COMMENT '规格型号',
    `unit` VARCHAR(16) NOT NULL COMMENT '计量单位',
    `images` JSON COMMENT '物资图片',
    `shelf_life_days` INT COMMENT '保质期(天)',
    `storage_condition` VARCHAR(32) COMMENT '存储条件: 常温/冷藏/冷冻',
    `safety_stock` INT DEFAULT 0 COMMENT '安全库存(预警值)',
    `supplier_id` BIGINT COMMENT '主要供应商ID',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_material_code (`material_code`),
    INDEX idx_category_id (`category_id`),
    INDEX idx_supplier_id (`supplier_id`),
    FOREIGN KEY (`category_id`) REFERENCES `material_category`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物资档案表';

-- 采购计划表
CREATE TABLE `purchase_plan` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `plan_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '计划编号',
    `plan_name` VARCHAR(128) NOT NULL COMMENT '计划名称',
    `plan_type` VARCHAR(32) COMMENT '计划类型: REGULAR/URGENT/PROMOTION',
    `total_amount` DECIMAL(12,2) COMMENT '计划总金额',
    `status` TINYINT DEFAULT 0 COMMENT '状态: 0-草稿 1-待审批 2-已审批 3-已执行 4-已取消',
    `applicant_id` BIGINT NOT NULL COMMENT '申请人ID',
    `approver_id` BIGINT COMMENT '审批人ID',
    `approve_time` DATETIME COMMENT '审批时间',
    `approve_remark` VARCHAR(256) COMMENT '审批备注',
    `execute_time` DATETIME COMMENT '执行时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_plan_no (`plan_no`),
    INDEX idx_status (`status`),
    FOREIGN KEY (`applicant_id`) REFERENCES `sys_user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购计划表';

-- 采购计划明细表
CREATE TABLE `purchase_plan_item` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `plan_id` BIGINT NOT NULL COMMENT '采购计划ID',
    `material_id` BIGINT NOT NULL COMMENT '物资ID',
    `quantity` INT NOT NULL COMMENT '计划采购数量',
    `estimated_price` DECIMAL(10,2) COMMENT '预估单价',
    `supplier_id` BIGINT COMMENT '意向供应商ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_plan_id (`plan_id`),
    FOREIGN KEY (`plan_id`) REFERENCES `purchase_plan`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `material`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='采购计划明细表';

-- 入库单表
CREATE TABLE `inbound_order` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `inbound_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '入库单号',
    `inbound_type` VARCHAR(32) NOT NULL COMMENT '入库类型: PURCHASE/RETURN/TRANSFER/CHECK_SURPLUS',
    `warehouse_id` BIGINT NOT NULL COMMENT '入库仓库ID',
    `related_order_no` VARCHAR(64) COMMENT '关联单据号(采购单/调拨单)',
    `total_quantity` INT NOT NULL DEFAULT 0 COMMENT '总数量',
    `status` TINYINT DEFAULT 0 COMMENT '状态: 0-待质检 1-质检中 2-待上架 3-已完成 4-已取消',
    `inspector_id` BIGINT COMMENT '质检员ID',
    `inspect_time` DATETIME COMMENT '质检时间',
    `inspect_result` VARCHAR(32) COMMENT '质检结果: PASS/REJECT',
    `operator_id` BIGINT COMMENT '操作员ID',
    `complete_time` DATETIME COMMENT '完成时间',
    `remark` VARCHAR(256) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_inbound_no (`inbound_no`),
    INDEX idx_warehouse_id (`warehouse_id`),
    INDEX idx_status (`status`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入库单表';

-- 入库单明细表
CREATE TABLE `inbound_order_item` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `inbound_id` BIGINT NOT NULL COMMENT '入库单ID',
    `material_id` BIGINT NOT NULL COMMENT '物资ID',
    `batch_no` VARCHAR(64) COMMENT '批次号',
    `production_date` DATE COMMENT '生产日期',
    `expiry_date` DATE COMMENT '过期日期',
    `quantity` INT NOT NULL COMMENT '入库数量',
    `warehouse_id` BIGINT NOT NULL COMMENT '入库仓库ID',
    `location_id` BIGINT COMMENT '库位ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_inbound_id (`inbound_id`),
    FOREIGN KEY (`inbound_id`) REFERENCES `inbound_order`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `material`(`id`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`),
    FOREIGN KEY (`location_id`) REFERENCES `warehouse_location`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入库单明细表';

-- 出库单表
CREATE TABLE `outbound_order` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `outbound_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '出库单号',
    `outbound_type` VARCHAR(32) NOT NULL COMMENT '出库类型: SALE/TRANSFER/DAMAGE/CHECK_LOSS',
    `warehouse_id` BIGINT NOT NULL COMMENT '出库仓库ID',
    `related_order_no` VARCHAR(64) COMMENT '关联订单号/调拨单号',
    `total_quantity` INT NOT NULL DEFAULT 0 COMMENT '总数量',
    `status` TINYINT DEFAULT 0 COMMENT '状态: 0-待拣货 1-拣货中 2-已出库 3-已取消',
    `picker_id` BIGINT COMMENT '拣货员ID',
    `operator_id` BIGINT COMMENT '操作员ID',
    `complete_time` DATETIME COMMENT '完成时间',
    `remark` VARCHAR(256) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_outbound_no (`outbound_no`),
    INDEX idx_warehouse_id (`warehouse_id`),
    INDEX idx_status (`status`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库单表';

-- 出库单明细表
CREATE TABLE `outbound_order_item` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `outbound_id` BIGINT NOT NULL COMMENT '出库单ID',
    `material_id` BIGINT NOT NULL COMMENT '物资ID',
    `batch_no` VARCHAR(64) COMMENT '批次号',
    `quantity` INT NOT NULL COMMENT '出库数量',
    `warehouse_id` BIGINT NOT NULL COMMENT '出库仓库ID',
    `location_id` BIGINT COMMENT '库位ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_outbound_id (`outbound_id`),
    FOREIGN KEY (`outbound_id`) REFERENCES `outbound_order`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `material`(`id`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`),
    FOREIGN KEY (`location_id`) REFERENCES `warehouse_location`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库单明细表';

-- 调拨单表
CREATE TABLE `transfer_order` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `transfer_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '调拨单号',
    `from_warehouse_id` BIGINT NOT NULL COMMENT '调出仓库ID',
    `to_warehouse_id` BIGINT NOT NULL COMMENT '调入仓库ID',
    `total_quantity` INT NOT NULL DEFAULT 0 COMMENT '总数量',
    `status` TINYINT DEFAULT 0 COMMENT '状态: 0-待审批 1-已审批 2-调拨中 3-已完成 4-已取消',
    `applicant_id` BIGINT NOT NULL COMMENT '申请人ID',
    `approver_id` BIGINT COMMENT '审批人ID',
    `approve_time` DATETIME COMMENT '审批时间',
    `complete_time` DATETIME COMMENT '完成时间',
    `remark` VARCHAR(256) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_transfer_no (`transfer_no`),
    INDEX idx_status (`status`),
    FOREIGN KEY (`from_warehouse_id`) REFERENCES `warehouse`(`id`),
    FOREIGN KEY (`to_warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调拨单表';

-- 调拨单明细表
CREATE TABLE `transfer_order_item` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `transfer_id` BIGINT NOT NULL COMMENT '调拨单ID',
    `material_id` BIGINT NOT NULL COMMENT '物资ID',
    `batch_no` VARCHAR(64) COMMENT '批次号',
    `quantity` INT NOT NULL COMMENT '调拨数量',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_transfer_id (`transfer_id`),
    FOREIGN KEY (`transfer_id`) REFERENCES `transfer_order`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `material`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='调拨单明细表';

-- 盘点任务表
CREATE TABLE `inventory_check` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `check_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '盘点单号',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID',
    `check_type` VARCHAR(32) NOT NULL COMMENT '盘点类型: FULL/PARTIAL/MOVEMENT',
    `status` TINYINT DEFAULT 0 COMMENT '状态: 0-待盘点 1-盘点中 2-待审批 3-已完成 4-已取消',
    `checker_id` BIGINT COMMENT '盘点员ID',
    `approver_id` BIGINT COMMENT '审批人ID',
    `approve_time` DATETIME COMMENT '审批时间',
    `complete_time` DATETIME COMMENT '完成时间',
    `remark` VARCHAR(256) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_check_no (`check_no`),
    INDEX idx_warehouse_id (`warehouse_id`),
    INDEX idx_status (`status`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='盘点任务表';

-- 盘点明细表
CREATE TABLE `inventory_check_item` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `check_id` BIGINT NOT NULL COMMENT '盘点任务ID',
    `material_id` BIGINT NOT NULL COMMENT '物资ID',
    `batch_no` VARCHAR(64) COMMENT '批次号',
    `book_quantity` INT NOT NULL COMMENT '账面数量',
    `actual_quantity` INT COMMENT '实盘数量',
    `difference_quantity` INT COMMENT '差异数量',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID',
    `location_id` BIGINT COMMENT '库位ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_check_id (`check_id`),
    FOREIGN KEY (`check_id`) REFERENCES `inventory_check`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `material`(`id`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`),
    FOREIGN KEY (`location_id`) REFERENCES `warehouse_location`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='盘点明细表';

-- ========================================
-- 7. 配送追踪模块
-- ========================================

-- 配送单表
CREATE TABLE `delivery_order` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `delivery_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '配送单号',
    `order_no` VARCHAR(64) NOT NULL COMMENT '关联订单号',
    `warehouse_id` BIGINT NOT NULL COMMENT '发货仓库ID',
    `supplier_id` BIGINT COMMENT '供应商ID',
    `delivery_status` TINYINT DEFAULT 0 COMMENT '配送状态: 0-待接单 1-已接单 2-拣货中 3-已出库 4-配送中 5-派送中 6-已签收 7-异常',
    `driver_id` BIGINT COMMENT '配送员ID',
    `driver_name` VARCHAR(64) COMMENT '配送员姓名',
    `driver_phone` VARCHAR(20) COMMENT '配送员电话',
    `vehicle_no` VARCHAR(32) COMMENT '车牌号',
    `estimated_arrival` DATETIME COMMENT '预计送达时间',
    `actual_arrival` DATETIME COMMENT '实际送达时间',
    `sign_proof_image` VARCHAR(256) COMMENT '签收凭证图片',
    `exception_reason` VARCHAR(256) COMMENT '异常原因',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_delivery_no (`delivery_no`),
    INDEX idx_order_no (`order_no`),
    INDEX idx_delivery_status (`delivery_status`),
    FOREIGN KEY (`order_no`) REFERENCES `orders`(`order_no`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配送单表';

-- 物流轨迹表
CREATE TABLE `delivery_trajectory` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `trajectory_id` VARCHAR(64) NOT NULL UNIQUE COMMENT '轨迹ID',
    `delivery_no` VARCHAR(64) NOT NULL COMMENT '配送单号',
    `node_time` DATETIME NOT NULL COMMENT '节点时间',
    `node_name` VARCHAR(64) NOT NULL COMMENT '节点名称',
    `node_description` VARCHAR(256) COMMENT '节点描述',
    `operator` VARCHAR(64) COMMENT '操作人',
    `latitude` DECIMAL(10,6) COMMENT '纬度',
    `longitude` DECIMAL(10,6) COMMENT '经度',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_delivery_no (`delivery_no`),
    INDEX idx_node_time (`node_time`),
    FOREIGN KEY (`delivery_no`) REFERENCES `delivery_order`(`delivery_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物流轨迹表';

-- ========================================
-- 8. 供应商管理模块
-- ========================================

-- 供应商档案表
CREATE TABLE `supplier` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `supplier_code` VARCHAR(32) NOT NULL UNIQUE COMMENT '供应商编码',
    `supplier_name` VARCHAR(128) NOT NULL COMMENT '供应商名称',
    `unified_social_credit_code` VARCHAR(32) COMMENT '统一社会信用代码',
    `legal_representative` VARCHAR(64) COMMENT '法定代表人',
    `contact_phone` VARCHAR(20) COMMENT '联系电话',
    `contact_email` VARCHAR(128) COMMENT '电子邮箱',
    `address` VARCHAR(256) COMMENT '详细地址',
    `business_license_image` VARCHAR(256) COMMENT '营业执照图片',
    `food_license_image` VARCHAR(256) COMMENT '食品经营许可证图片',
    `bank_license_image` VARCHAR(256) COMMENT '开户许可证图片',
    `other_qualifications` JSON COMMENT '其他资质(JSON)',
    `supply_categories` JSON COMMENT '供应品类(JSON数组)',
    `cooperation_start_date` DATE COMMENT '合作开始日期',
    `cooperation_status` TINYINT DEFAULT 0 COMMENT '合作状态: 0-待审核 1-合作中 2-暂停 3-终止',
    `settlement_cycle` VARCHAR(32) COMMENT '结算周期: MONTHLY/QUARTERLY/HALF_YEARLY',
    `comprehensive_score` DECIMAL(5,2) DEFAULT 0 COMMENT '综合评分',
    `rating` VARCHAR(2) DEFAULT 'C' COMMENT '评级: A/B/C/D',
    `fulfillment_rate` DECIMAL(5,2) DEFAULT 0 COMMENT '履约率(%)',
    `qualification_rate` DECIMAL(5,2) DEFAULT 0 COMMENT '合格率(%)',
    `audit_status` TINYINT DEFAULT 0 COMMENT '审核状态: 0-待审核 1-已通过 2-已驳回',
    `auditor_id` BIGINT COMMENT '审核人ID',
    `audit_time` DATETIME COMMENT '审核时间',
    `audit_remark` VARCHAR(256) COMMENT '审核备注',
    `blacklist_reason` VARCHAR(256) COMMENT '黑名单原因',
    `blacklist_time` DATETIME COMMENT '加入黑名单时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_code (`supplier_code`),
    INDEX idx_cooperation_status (`cooperation_status`),
    INDEX idx_rating (`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商档案表';

-- 供应商评价记录表
CREATE TABLE `supplier_evaluation` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `supplier_id` BIGINT NOT NULL COMMENT '供应商ID',
    `evaluation_month` VARCHAR(7) NOT NULL COMMENT '评价月份(YYYY-MM)',
    `quality_score` DECIMAL(5,2) COMMENT '质量指标得分',
    `delivery_score` DECIMAL(5,2) COMMENT '交付指标得分',
    `service_score` DECIMAL(5,2) COMMENT '服务指标得分',
    `compliance_score` DECIMAL(5,2) COMMENT '合规指标得分',
    `comprehensive_score` DECIMAL(5,2) COMMENT '综合得分',
    `rating` VARCHAR(2) COMMENT '评级',
    `evaluator_id` BIGINT COMMENT '评价人ID',
    `evaluation_remark` VARCHAR(512) COMMENT '评价备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_supplier_month (`supplier_id`, `evaluation_month`),
    FOREIGN KEY (`supplier_id`) REFERENCES `supplier`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='供应商评价记录表';

-- ========================================
-- 9. 验收服务模块
-- ========================================

-- 验收任务表
CREATE TABLE `inspection_task` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `task_no` VARCHAR(64) NOT NULL UNIQUE COMMENT '任务编号',
    `order_no` VARCHAR(64) COMMENT '关联订单号',
    `inbound_no` VARCHAR(64) COMMENT '关联入库单号',
    `material_id` BIGINT COMMENT '物资ID',
    `batch_no` VARCHAR(64) COMMENT '批次号',
    `inspector_id` BIGINT NOT NULL COMMENT '质检员ID',
    `inspection_status` TINYINT DEFAULT 0 COMMENT '验收状态: 0-待验收 1-验收中 2-合格 3-降级 4-拒收',
    `inspection_items` JSON COMMENT '验收项(JSON): 标签/感官/理化/包装/温控/抽检',
    `inspection_result` VARCHAR(32) COMMENT '验收结论: PASS/DOWNGRADE/REJECT',
    `inspection_images` JSON COMMENT '验收照片(JSON数组)',
    `inspection_report` VARCHAR(256) COMMENT '质检报告文件',
    `reject_reason` VARCHAR(256) COMMENT '拒收原因',
    `complete_time` DATETIME COMMENT '完成时间',
    `remark` VARCHAR(256) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_task_no (`task_no`),
    INDEX idx_order_no (`order_no`),
    INDEX idx_inspection_status (`inspection_status`),
    FOREIGN KEY (`inspector_id`) REFERENCES `sys_user`(`id`),
    FOREIGN KEY (`material_id`) REFERENCES `material`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='验收任务表';

-- 批次追溯表
CREATE TABLE `batch_traceability` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `batch_no` VARCHAR(64) NOT NULL COMMENT '批次号',
    `material_id` BIGINT NOT NULL COMMENT '物资ID',
    `trace_step` VARCHAR(32) NOT NULL COMMENT '追溯环节: RAW_MATERIAL/PRODUCTION/QUALITY/PACKAGE/WAREHOUSE/LOGISTICS/INSPECTION',
    `step_description` VARCHAR(256) COMMENT '环节描述',
    `operator` VARCHAR(64) COMMENT '操作人',
    `operation_time` DATETIME COMMENT '操作时间',
    `attachments` JSON COMMENT '附件(图片/PDF)',
    `qr_code` VARCHAR(256) COMMENT '追溯二维码',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_batch_no (`batch_no`),
    INDEX idx_material_id (`material_id`),
    FOREIGN KEY (`material_id`) REFERENCES `material`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='批次追溯表';

-- ========================================
-- 10. 系统配置与日志
-- ========================================

-- 库存预警配置表
CREATE TABLE `inventory_alert_config` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `warehouse_id` BIGINT NOT NULL COMMENT '仓库ID',
    `lower_threshold` INT NOT NULL COMMENT '库存下限预警值',
    `upper_threshold` INT COMMENT '库存上限预警值',
    `near_expiry_days` INT DEFAULT 30 COMMENT '临期预警天数',
    `alert_enabled` TINYINT DEFAULT 1 COMMENT '预警开关: 0-关闭 1-开启',
    `notify_users` JSON COMMENT '通知用户ID列表(JSON)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_sku_warehouse (`sku_id`, `warehouse_id`),
    FOREIGN KEY (`sku_id`) REFERENCES `product_sku`(`id`),
    FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存预警配置表';

-- 操作日志表
CREATE TABLE `operation_log` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `operator_id` BIGINT COMMENT '操作人ID',
    `operator_name` VARCHAR(64) COMMENT '操作人姓名',
    `module` VARCHAR(64) COMMENT '操作模块',
    `action` VARCHAR(64) COMMENT '操作动作',
    `request_url` VARCHAR(256) COMMENT '请求URL',
    `request_method` VARCHAR(16) COMMENT '请求方法',
    `request_params` TEXT COMMENT '请求参数',
    `response_result` TEXT COMMENT '响应结果',
    `ip_address` VARCHAR(64) COMMENT 'IP地址',
    `execution_time` INT COMMENT '执行时长(ms)',
    `status` TINYINT DEFAULT 1 COMMENT '状态: 0-失败 1-成功',
    `error_message` VARCHAR(512) COMMENT '错误信息',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_operator_id (`operator_id`),
    INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- ========================================
-- 初始化测试数据
-- ========================================

-- 插入默认管理员用户
INSERT INTO `sys_user` (`username`, `password`, `real_name`, `role`, `status`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', '系统管理员', 'ADMIN', 1);

-- 插入商品分类(三级)
INSERT INTO `product_category` (`parent_id`, `category_name`, `level`, `sort_order`) VALUES
(0, '水果类', 1, 1),
(0, '蛋类', 1, 2),
(0, '粮油类', 1, 3),
(0, '肉类', 1, 4),
(0, '蔬菜类', 1, 5);

INSERT INTO `product_category` (`parent_id`, `category_name`, `level`, `sort_order`) VALUES
(1, '柑橘类', 2, 1),
(1, '瓜果类', 2, 2),
(2, '鸡蛋', 2, 1),
(2, '鸭蛋', 2, 2),
(3, '大米', 2, 1),
(3, '面粉', 2, 2),
(4, '猪肉类', 2, 1),
(4, '鸡肉类', 2, 2),
(5, '叶菜类', 2, 1),
(5, '根茎类', 2, 2);

INSERT INTO `product_category` (`parent_id`, `category_name`, `level`, `sort_order`) VALUES
(6, '砂糖橘', 3, 1),
(6, '沃柑', 3, 2),
(7, '西瓜', 3, 1),
(8, '鲜鸡蛋', 3, 1),
(9, '土鸡蛋', 3, 1),
(10, '东北大米', 3, 1),
(11, '高筋面粉', 3, 1),
(12, '五花肉', 3, 1),
(13, '鸡胸肉', 3, 1),
(14, '菠菜', 3, 1),
(15, '土豆', 3, 1);

-- 插入仓库
INSERT INTO `warehouse` (`warehouse_code`, `warehouse_name`, `warehouse_type`, `address`, `manager`, `phone`, `capacity_volume`, `capacity_weight`, `status`) VALUES
('WH01', '青岛中心仓', '中心仓', '山东省青岛市黄岛区XX路1号', '张三', '13800138001', 10000.00, 50000.00, 1),
('WH02', '济南区域仓', '区域仓', '山东省济南市历下区XX路2号', '李四', '13800138002', 5000.00, 25000.00, 1),
('WH03', '烟台前置仓', '前置仓', '山东省烟台市芝罘区XX路3号', '王五', '13800138003', 2000.00, 10000.00, 1);

-- 插入库位(示例:青岛中心仓)
INSERT INTO `warehouse_location` (`location_code`, `warehouse_id`, `location_type`, `max_capacity`, `current_usage`, `status`) VALUES
('A-01-01', 1, '货架区', 100.00, 0, 1),
('A-01-02', 1, '货架区', 100.00, 0, 1),
('B-01-01', 1, '冷藏区', 200.00, 0, 1),
('B-01-02', 1, '冷冻区', 200.00, 0, 1),
('C-01-01', 1, '地堆区', 500.00, 0, 1);
