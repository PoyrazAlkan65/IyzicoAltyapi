-- ============================================================
--  iyzico Entegrasyon - Veritabanı Şeması (MySQL 8+)
-- ============================================================

SET NAMES utf8mb4;
SET foreign_key_checks = 0;

-- ------------------------------------------------------------
-- TABLO: users
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
    `id`              CHAR(36)     NOT NULL DEFAULT (UUID()),
    `name`            VARCHAR(100) NOT NULL,
    `surname`         VARCHAR(100) NOT NULL,
    `email`           VARCHAR(255) NOT NULL,
    `gsm_number`      VARCHAR(20),
    `identity_number` VARCHAR(11),
    `ip_address`      VARCHAR(45),
    `city`            VARCHAR(100) DEFAULT 'Istanbul',
    `country`         VARCHAR(100) DEFAULT 'Turkey',
    `address`         TEXT,
    `zip_code`        VARCHAR(10),
    `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLO: subscription_products
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `subscription_products` (
    `id`             CHAR(36)     NOT NULL DEFAULT (UUID()),
    `reference_code` VARCHAR(255),
    `name`           VARCHAR(255) NOT NULL,
    `description`    TEXT,
    `status`         VARCHAR(50)  NOT NULL DEFAULT 'ACTIVE',
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_product_ref` (`reference_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLO: subscription_plans
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `subscription_plans` (
    `id`                     CHAR(36)       NOT NULL DEFAULT (UUID()),
    `product_id`             CHAR(36)       NOT NULL,
    `reference_code`         VARCHAR(255),
    `name`                   VARCHAR(255)   NOT NULL,
    `price`                  DECIMAL(12,2)  NOT NULL,
    `currency_code`          VARCHAR(10)    NOT NULL DEFAULT 'TRY',
    `payment_interval`       VARCHAR(20)    NOT NULL,
    `payment_interval_count` INT            NOT NULL DEFAULT 1,
    `trial_period_days`      INT            NOT NULL DEFAULT 0,
    `plan_payment_type`      VARCHAR(50)    NOT NULL DEFAULT 'RECURRING',
    `status`                 VARCHAR(50)    NOT NULL DEFAULT 'ACTIVE',
    `created_at`             DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`             DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_plan_ref` (`reference_code`),
    KEY `idx_plans_product` (`product_id`),
    CONSTRAINT `fk_plans_product` FOREIGN KEY (`product_id`) REFERENCES `subscription_products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLO: subscriptions
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `subscriptions` (
    `id`                  CHAR(36)     NOT NULL DEFAULT (UUID()),
    `user_id`             CHAR(36)     NOT NULL,
    `plan_id`             CHAR(36)     NOT NULL,
    `reference_code`      VARCHAR(255),
    `status`              VARCHAR(50)  NOT NULL DEFAULT 'ACTIVE',
    `start_date`          DATETIME,
    `end_date`            DATETIME,
    `trial_start_date`    DATETIME,
    `trial_end_date`      DATETIME,
    `next_payment_date`   DATETIME,
    `cancelled_at`        DATETIME,
    `cancel_reason`       TEXT,
    `iyzico_customer_ref` VARCHAR(255),
    `created_at`          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_subscription_ref` (`reference_code`),
    KEY `idx_subscriptions_user`   (`user_id`),
    KEY `idx_subscriptions_plan`   (`plan_id`),
    KEY `idx_subscriptions_status` (`status`),
    CONSTRAINT `fk_subscriptions_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
    CONSTRAINT `fk_subscriptions_plan` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLO: sub_merchants
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sub_merchants` (
    `id`                  CHAR(36)     NOT NULL DEFAULT (UUID()),
    `external_id`         VARCHAR(255) NOT NULL,
    `sub_merchant_key`    VARCHAR(255),
    `name`                VARCHAR(255) NOT NULL,
    `email`               VARCHAR(255) NOT NULL,
    `gsm_number`          VARCHAR(20),
    `address`             TEXT,
    `iban`                VARCHAR(34),
    `currency`            VARCHAR(10)  NOT NULL DEFAULT 'TRY',
    `sub_merchant_type`   VARCHAR(50)  NOT NULL DEFAULT 'PERSONAL',
    `identity_number`     VARCHAR(11),
    `tax_number`          VARCHAR(20),
    `tax_office`          VARCHAR(255),
    `legal_company_title` VARCHAR(255),
    `contact_name`        VARCHAR(100),
    `contact_surname`     VARCHAR(100),
    `status`              VARCHAR(50)  NOT NULL DEFAULT 'ACTIVE',
    `created_at`          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_external_id`       (`external_id`),
    UNIQUE KEY `uq_sub_merchant_key`  (`sub_merchant_key`),
    KEY `idx_sub_merchants_email`  (`email`),
    KEY `idx_sub_merchants_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLO: payments
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `payments` (
    `id`               CHAR(36)      NOT NULL DEFAULT (UUID()),
    `user_id`          CHAR(36),
    `basket_id`        VARCHAR(255)  NOT NULL,
    `payment_id`       VARCHAR(255),
    `conversation_id`  VARCHAR(255),
    `price`            DECIMAL(12,2) NOT NULL,
    `paid_price`       DECIMAL(12,2) NOT NULL,
    `currency`         VARCHAR(10)   NOT NULL DEFAULT 'TRY',
    `installment`      INT           NOT NULL DEFAULT 1,
    `payment_channel`  VARCHAR(50)   DEFAULT 'WEB',
    `payment_group`    VARCHAR(50)   DEFAULT 'PRODUCT',
    `payment_status`   VARCHAR(50)   NOT NULL DEFAULT 'PENDING',
    `is_3d`            TINYINT(1)    NOT NULL DEFAULT 0,
    `fraud_status`     INT,
    `bin_number`       VARCHAR(10),
    `card_family`      VARCHAR(50),
    `card_type`        VARCHAR(50),
    `card_association` VARCHAR(50),
    `card_last4`       VARCHAR(4),
    `error_code`       VARCHAR(50),
    `error_message`    TEXT,
    `auth_code`        VARCHAR(50),
    `host_reference`   VARCHAR(50),
    `raw_response`     JSON,
    `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_payment_id` (`payment_id`),
    KEY `idx_payments_user_id`   (`user_id`),
    KEY `idx_payments_basket_id` (`basket_id`),
    KEY `idx_payments_status`    (`payment_status`),
    KEY `idx_payments_created`   (`created_at`),
    CONSTRAINT `fk_payments_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLO: payment_items
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `payment_items` (
    `id`                     CHAR(36)      NOT NULL DEFAULT (UUID()),
    `payment_id`             CHAR(36)      NOT NULL,
    `sub_merchant_id`        CHAR(36),
    `payment_transaction_id` VARCHAR(255),
    `item_id`                VARCHAR(255)  NOT NULL,
    `item_name`              VARCHAR(255)  NOT NULL,
    `category`               VARCHAR(255),
    `item_type`              VARCHAR(50)   DEFAULT 'PHYSICAL',
    `price`                  DECIMAL(12,2) NOT NULL,
    `sub_merchant_price`     DECIMAL(12,2),
    `merchant_commission`    DECIMAL(12,2),
    `iyzico_commission`      DECIMAL(12,2),
    `transaction_status`     VARCHAR(50)   DEFAULT 'PENDING',
    `blockage_rate`          DECIMAL(5,2),
    `blockage_resolved_date` DATETIME,
    `created_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_transaction_id` (`payment_transaction_id`),
    KEY `idx_payment_items_payment`  (`payment_id`),
    KEY `idx_payment_items_merchant` (`sub_merchant_id`),
    CONSTRAINT `fk_items_payment`  FOREIGN KEY (`payment_id`)      REFERENCES `payments`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_items_merchant` FOREIGN KEY (`sub_merchant_id`) REFERENCES `sub_merchants`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLO: refunds
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `refunds` (
    `id`                     CHAR(36)      NOT NULL DEFAULT (UUID()),
    `payment_item_id`        CHAR(36)      NOT NULL,
    `payment_transaction_id` VARCHAR(255),
    `refund_id`              VARCHAR(255),
    `price`                  DECIMAL(12,2) NOT NULL,
    `currency`               VARCHAR(10)   NOT NULL DEFAULT 'TRY',
    `status`                 VARCHAR(50)   NOT NULL DEFAULT 'PENDING',
    `description`            TEXT,
    `error_code`             VARCHAR(50),
    `error_message`          TEXT,
    `ip`                     VARCHAR(45),
    `created_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_refunds_payment_item` (`payment_item_id`),
    KEY `idx_refunds_status`       (`status`),
    CONSTRAINT `fk_refunds_item` FOREIGN KEY (`payment_item_id`) REFERENCES `payment_items`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- TABLO: iyzico_webhook_logs
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `iyzico_webhook_logs` (
    `id`            CHAR(36)     NOT NULL DEFAULT (UUID()),
    `event_type`    VARCHAR(100) NOT NULL,
    `payload`       JSON         NOT NULL,
    `processed`     TINYINT(1)   NOT NULL DEFAULT 0,
    `error_message` TEXT,
    `received_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `processed_at`  DATETIME,
    PRIMARY KEY (`id`),
    KEY `idx_webhook_event`     (`event_type`),
    KEY `idx_webhook_processed` (`processed`),
    KEY `idx_webhook_received`  (`received_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET foreign_key_checks = 1;
