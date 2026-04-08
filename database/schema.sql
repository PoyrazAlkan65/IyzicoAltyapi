-- ============================================================
--  iyzico Entegrasyon - Veritabanı Şeması (PostgreSQL)
--  Oluşturma tarihi: 2026-04-08
-- ============================================================

-- Uzantılar
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------
-- TABLO: users
-- Sisteme kayıtlı son kullanıcılar
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL,
    surname         VARCHAR(100) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    gsm_number      VARCHAR(20),
    identity_number VARCHAR(11),
    ip_address      VARCHAR(45),
    city            VARCHAR(100)    DEFAULT 'Istanbul',
    country         VARCHAR(100)    DEFAULT 'Turkey',
    address         TEXT,
    zip_code        VARCHAR(10),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

-- ------------------------------------------------------------
-- TABLO: subscription_products
-- iyzico üyelik ürünleri (product → planların üst nesnesi)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subscription_products (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_code VARCHAR(255) UNIQUE,          -- iyzico referans kodu
    name           VARCHAR(255) NOT NULL,
    description    TEXT,
    status         VARCHAR(50)  NOT NULL DEFAULT 'ACTIVE', -- ACTIVE | PASSIVE
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- TABLO: subscription_plans
-- Fiyatlandırma planları (aylık, yıllık vb.)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subscription_plans (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id              UUID NOT NULL REFERENCES subscription_products(id) ON DELETE CASCADE,
    reference_code          VARCHAR(255) UNIQUE,
    name                    VARCHAR(255) NOT NULL,
    price                   NUMERIC(12, 2) NOT NULL,
    currency_code           VARCHAR(10)  NOT NULL DEFAULT 'TRY',
    payment_interval        VARCHAR(20)  NOT NULL,       -- WEEKLY | MONTHLY | YEARLY
    payment_interval_count  INT          NOT NULL DEFAULT 1,
    trial_period_days       INT          NOT NULL DEFAULT 0,
    plan_payment_type       VARCHAR(50)  NOT NULL DEFAULT 'RECURRING',
    status                  VARCHAR(50)  NOT NULL DEFAULT 'ACTIVE',
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_plans_product ON subscription_plans(product_id);

-- ------------------------------------------------------------
-- TABLO: subscriptions
-- Kullanıcıların aktif/pasif abonelikleri
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS subscriptions (
    id                       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id                  UUID NOT NULL REFERENCES users(id),
    plan_id                  UUID NOT NULL REFERENCES subscription_plans(id),
    reference_code           VARCHAR(255) UNIQUE,         -- iyzico referans kodu
    status                   VARCHAR(50)  NOT NULL DEFAULT 'ACTIVE',
    -- ACTIVE | PENDING | UPGRADED | CANCELLED | EXPIRED | UNPAID | PAUSED
    start_date               TIMESTAMPTZ,
    end_date                 TIMESTAMPTZ,
    trial_start_date         TIMESTAMPTZ,
    trial_end_date           TIMESTAMPTZ,
    next_payment_date        TIMESTAMPTZ,
    cancelled_at             TIMESTAMPTZ,
    cancel_reason            TEXT,
    iyzico_customer_ref      VARCHAR(255),
    created_at               TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user   ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_plan   ON subscriptions(plan_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- ------------------------------------------------------------
-- TABLO: sub_merchants
-- Pazaryeri alt satıcıları
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sub_merchants (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id          VARCHAR(255) UNIQUE NOT NULL,   -- bizim verdiğimiz ID
    sub_merchant_key     VARCHAR(255) UNIQUE,             -- iyzico'nun verdiği key
    name                 VARCHAR(255) NOT NULL,
    email                VARCHAR(255) NOT NULL,
    gsm_number           VARCHAR(20),
    address              TEXT,
    iban                 VARCHAR(34),
    currency             VARCHAR(10)  NOT NULL DEFAULT 'TRY',
    sub_merchant_type    VARCHAR(50)  NOT NULL DEFAULT 'PERSONAL',
    -- PERSONAL | PRIVATE_COMPANY | LIMITED_OR_JOINT_STOCK_COMPANY
    identity_number      VARCHAR(11),   -- bireysel için TC
    tax_number           VARCHAR(20),   -- şirket için vergi no
    tax_office           VARCHAR(255),
    legal_company_title  VARCHAR(255),
    contact_name         VARCHAR(100),
    contact_surname      VARCHAR(100),
    status               VARCHAR(50)  NOT NULL DEFAULT 'ACTIVE',
    created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sub_merchants_email  ON sub_merchants(email);
CREATE INDEX idx_sub_merchants_status ON sub_merchants(status);

-- ------------------------------------------------------------
-- TABLO: payments
-- Tüm ödeme kayıtları (pazaryeri + direkt)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID REFERENCES users(id),
    basket_id           VARCHAR(255)    NOT NULL,
    payment_id          VARCHAR(255) UNIQUE,          -- iyzico payment ID
    conversation_id     VARCHAR(255),
    price               NUMERIC(12, 2)  NOT NULL,
    paid_price          NUMERIC(12, 2)  NOT NULL,
    currency            VARCHAR(10)     NOT NULL DEFAULT 'TRY',
    installment         INT             NOT NULL DEFAULT 1,
    payment_channel     VARCHAR(50)     DEFAULT 'WEB',
    payment_group       VARCHAR(50)     DEFAULT 'PRODUCT',
    payment_status      VARCHAR(50)     NOT NULL DEFAULT 'PENDING',
    -- PENDING | SUCCESS | FAILURE | CANCELLED | REFUNDED | PARTIAL_REFUNDED
    is_3d               BOOLEAN         NOT NULL DEFAULT FALSE,
    fraud_status        INT,
    bin_number          VARCHAR(10),
    card_family         VARCHAR(50),
    card_type           VARCHAR(50),
    card_association    VARCHAR(50),
    card_last4          VARCHAR(4),
    error_code          VARCHAR(50),
    error_message       TEXT,
    auth_code           VARCHAR(50),
    host_reference      VARCHAR(50),
    phase               VARCHAR(50),
    raw_response        JSONB,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_user_id    ON payments(user_id);
CREATE INDEX idx_payments_basket_id  ON payments(basket_id);
CREATE INDEX idx_payments_status     ON payments(payment_status);
CREATE INDEX idx_payments_created    ON payments(created_at DESC);

-- ------------------------------------------------------------
-- TABLO: payment_items
-- Ödeme içindeki kalem detayları (alt satıcı bölüşümü dahil)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payment_items (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id              UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    sub_merchant_id         UUID REFERENCES sub_merchants(id),
    payment_transaction_id  VARCHAR(255) UNIQUE,          -- iyzico transaction ID
    item_id                 VARCHAR(255) NOT NULL,
    item_name               VARCHAR(255) NOT NULL,
    category                VARCHAR(255),
    item_type               VARCHAR(50)  DEFAULT 'PHYSICAL',
    price                   NUMERIC(12, 2) NOT NULL,
    sub_merchant_price      NUMERIC(12, 2),               -- satıcıya aktarılacak
    merchant_commission     NUMERIC(12, 2),               -- platform komisyonu
    iyzico_commission       NUMERIC(12, 2),               -- iyzico komisyonu
    transaction_status      VARCHAR(50)  DEFAULT 'PENDING',
    blockage_rate           NUMERIC(5, 2),
    blockage_resolved_date  TIMESTAMPTZ,
    created_at              TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payment_items_payment     ON payment_items(payment_id);
CREATE INDEX idx_payment_items_merchant    ON payment_items(sub_merchant_id);
CREATE INDEX idx_payment_items_transaction ON payment_items(payment_transaction_id);

-- ------------------------------------------------------------
-- TABLO: refunds
-- İade kayıtları
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS refunds (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_item_id         UUID NOT NULL REFERENCES payment_items(id),
    payment_transaction_id  VARCHAR(255),
    refund_id               VARCHAR(255),                -- iyzico refund ID
    price                   NUMERIC(12, 2) NOT NULL,
    currency                VARCHAR(10)    NOT NULL DEFAULT 'TRY',
    status                  VARCHAR(50)    NOT NULL DEFAULT 'PENDING',
    -- PENDING | SUCCESS | FAILURE
    description             TEXT,
    error_code              VARCHAR(50),
    error_message           TEXT,
    ip                      VARCHAR(45),
    created_at              TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refunds_payment_item ON refunds(payment_item_id);
CREATE INDEX idx_refunds_status       ON refunds(status);

-- ------------------------------------------------------------
-- TABLO: iyzico_webhook_logs
-- iyzico'dan gelen webhook bildirimlerinin logları
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS iyzico_webhook_logs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type      VARCHAR(100) NOT NULL,
    -- SUBSCRIPTION_CREATED | SUBSCRIPTION_CANCELLED | PAYMENT_SUCCESS vb.
    payload         JSONB        NOT NULL,
    processed       BOOLEAN      NOT NULL DEFAULT FALSE,
    error_message   TEXT,
    received_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    processed_at    TIMESTAMPTZ
);

CREATE INDEX idx_webhook_logs_event     ON iyzico_webhook_logs(event_type);
CREATE INDEX idx_webhook_logs_processed ON iyzico_webhook_logs(processed);
CREATE INDEX idx_webhook_logs_received  ON iyzico_webhook_logs(received_at DESC);

-- ------------------------------------------------------------
-- TRIGGER: updated_at otomatik güncelleme
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_subscription_products_updated_at
    BEFORE UPDATE ON subscription_products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_subscription_plans_updated_at
    BEFORE UPDATE ON subscription_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_sub_merchants_updated_at
    BEFORE UPDATE ON sub_merchants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_refunds_updated_at
    BEFORE UPDATE ON refunds
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
