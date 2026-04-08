-- ============================================================
--  iyzico Entegrasyon - Veritabanı Şeması (SQL Server / MSSQL)
--  Oluşturma tarihi: 2026-04-08
--
--  NOT: users tablosu kasıtlı olarak oluşturulmamıştır.
--       Bunun yerine dummy_users tablosu kullanılmaktadır.
--       Gerçek projede dummy_users yerine kendi users
--       tablonuzu FK olarak bağlayabilirsiniz.
-- ============================================================

USE iyzico;
GO

-- ------------------------------------------------------------
-- TABLO: dummy_users
-- Gerçek bir users tablosu olmadığı için test/dummy kullanıcı
-- verilerini tutan yardımcı tablo
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.dummy_users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dummy_users (
        id               UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        name             NVARCHAR(100)    NOT NULL,
        surname          NVARCHAR(100)    NOT NULL,
        email            NVARCHAR(255)    NOT NULL,
        gsm_number       NVARCHAR(20)     NULL,
        identity_number  NVARCHAR(11)     NULL,
        ip_address       NVARCHAR(45)     NULL,
        city             NVARCHAR(100)    NOT NULL DEFAULT N'Istanbul',
        country          NVARCHAR(100)    NOT NULL DEFAULT N'Turkey',
        address          NVARCHAR(MAX)    NULL,
        zip_code         NVARCHAR(10)     NULL,
        created_at       DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at       DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_dummy_users        PRIMARY KEY (id),
        CONSTRAINT UQ_dummy_users_email  UNIQUE      (email)
    );

    CREATE NONCLUSTERED INDEX IX_dummy_users_email
        ON dbo.dummy_users(email);

    PRINT 'dummy_users tablosu oluşturuldu.';
END
GO

-- ------------------------------------------------------------
-- TABLO: subscription_products
-- iyzico üyelik ürünleri (product → planların üst nesnesi)
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.subscription_products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.subscription_products (
        id              UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        reference_code  NVARCHAR(255)    NULL,         -- iyzico referans kodu
        name            NVARCHAR(255)    NOT NULL,
        description     NVARCHAR(MAX)    NULL,
        status          NVARCHAR(50)     NOT NULL DEFAULT N'ACTIVE',  -- ACTIVE | PASSIVE
        created_at      DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at      DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_subscription_products           PRIMARY KEY (id),
        CONSTRAINT UQ_subscription_products_ref       UNIQUE      (reference_code)
    );

    PRINT 'subscription_products tablosu oluşturuldu.';
END
GO

-- ------------------------------------------------------------
-- TABLO: subscription_plans
-- Fiyatlandırma planları (aylık, yıllık vb.)
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.subscription_plans', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.subscription_plans (
        id                      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        product_id              UNIQUEIDENTIFIER NOT NULL,
        reference_code          NVARCHAR(255)    NULL,
        name                    NVARCHAR(255)    NOT NULL,
        price                   DECIMAL(12, 2)   NOT NULL,
        currency_code           NVARCHAR(10)     NOT NULL DEFAULT N'TRY',
        payment_interval        NVARCHAR(20)     NOT NULL,  -- WEEKLY | MONTHLY | YEARLY
        payment_interval_count  INT              NOT NULL DEFAULT 1,
        trial_period_days       INT              NOT NULL DEFAULT 0,
        plan_payment_type       NVARCHAR(50)     NOT NULL DEFAULT N'RECURRING',
        status                  NVARCHAR(50)     NOT NULL DEFAULT N'ACTIVE',
        created_at              DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at              DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_subscription_plans         PRIMARY KEY (id),
        CONSTRAINT UQ_subscription_plans_ref     UNIQUE      (reference_code),
        CONSTRAINT FK_plans_product              FOREIGN KEY (product_id)
            REFERENCES dbo.subscription_products(id) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX IX_plans_product_id
        ON dbo.subscription_plans(product_id);

    PRINT 'subscription_plans tablosu oluşturuldu.';
END
GO

-- ------------------------------------------------------------
-- TABLO: subscriptions
-- Kullanıcıların aktif/pasif abonelikleri
-- dummy_users tablosuna FK bağlantısı vardır
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.subscriptions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.subscriptions (
        id                   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        dummy_user_id        UNIQUEIDENTIFIER NOT NULL,
        plan_id              UNIQUEIDENTIFIER NOT NULL,
        reference_code       NVARCHAR(255)    NULL,     -- iyzico referans kodu
        status               NVARCHAR(50)     NOT NULL DEFAULT N'ACTIVE',
        -- ACTIVE | PENDING | UPGRADED | CANCELLED | EXPIRED | UNPAID | PAUSED
        start_date           DATETIME2        NULL,
        end_date             DATETIME2        NULL,
        trial_start_date     DATETIME2        NULL,
        trial_end_date       DATETIME2        NULL,
        next_payment_date    DATETIME2        NULL,
        cancelled_at         DATETIME2        NULL,
        cancel_reason        NVARCHAR(MAX)    NULL,
        iyzico_customer_ref  NVARCHAR(255)    NULL,
        created_at           DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at           DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_subscriptions          PRIMARY KEY (id),
        CONSTRAINT UQ_subscriptions_ref      UNIQUE      (reference_code),
        CONSTRAINT FK_subscriptions_user     FOREIGN KEY (dummy_user_id)
            REFERENCES dbo.dummy_users(id),
        CONSTRAINT FK_subscriptions_plan     FOREIGN KEY (plan_id)
            REFERENCES dbo.subscription_plans(id)
    );

    CREATE NONCLUSTERED INDEX IX_subscriptions_user_id ON dbo.subscriptions(dummy_user_id);
    CREATE NONCLUSTERED INDEX IX_subscriptions_plan_id ON dbo.subscriptions(plan_id);
    CREATE NONCLUSTERED INDEX IX_subscriptions_status  ON dbo.subscriptions(status);

    PRINT 'subscriptions tablosu oluşturuldu.';
END
GO

-- ------------------------------------------------------------
-- TABLO: sub_merchants
-- Pazaryeri alt satıcıları
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.sub_merchants', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.sub_merchants (
        id                   UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        external_id          NVARCHAR(255)    NOT NULL,  -- bizim verdiğimiz ID
        sub_merchant_key     NVARCHAR(255)    NULL,      -- iyzico'nun verdiği key
        name                 NVARCHAR(255)    NOT NULL,
        email                NVARCHAR(255)    NOT NULL,
        gsm_number           NVARCHAR(20)     NULL,
        address              NVARCHAR(MAX)    NULL,
        iban                 NVARCHAR(34)     NULL,
        currency             NVARCHAR(10)     NOT NULL DEFAULT N'TRY',
        sub_merchant_type    NVARCHAR(50)     NOT NULL DEFAULT N'PERSONAL',
        -- PERSONAL | PRIVATE_COMPANY | LIMITED_OR_JOINT_STOCK_COMPANY
        identity_number      NVARCHAR(11)     NULL,   -- bireysel için TC
        tax_number           NVARCHAR(20)     NULL,   -- şirket için vergi no
        tax_office           NVARCHAR(255)    NULL,
        legal_company_title  NVARCHAR(255)    NULL,
        contact_name         NVARCHAR(100)    NULL,
        contact_surname      NVARCHAR(100)    NULL,
        status               NVARCHAR(50)     NOT NULL DEFAULT N'ACTIVE',
        created_at           DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at           DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_sub_merchants              PRIMARY KEY (id),
        CONSTRAINT UQ_sub_merchants_external_id  UNIQUE      (external_id),
        CONSTRAINT UQ_sub_merchants_key          UNIQUE      (sub_merchant_key)
    );

    CREATE NONCLUSTERED INDEX IX_sub_merchants_email  ON dbo.sub_merchants(email);
    CREATE NONCLUSTERED INDEX IX_sub_merchants_status ON dbo.sub_merchants(status);

    PRINT 'sub_merchants tablosu oluşturuldu.';
END
GO

-- ------------------------------------------------------------
-- TABLO: payments
-- Tüm ödeme kayıtları (pazaryeri + direkt)
-- dummy_users tablosuna FK bağlantısı vardır
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.payments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.payments (
        id               UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        dummy_user_id    UNIQUEIDENTIFIER NULL,
        basket_id        NVARCHAR(255)    NOT NULL,
        payment_id       NVARCHAR(255)    NULL,      -- iyzico payment ID
        conversation_id  NVARCHAR(255)    NULL,
        price            DECIMAL(12, 2)   NOT NULL,
        paid_price       DECIMAL(12, 2)   NOT NULL,
        currency         NVARCHAR(10)     NOT NULL DEFAULT N'TRY',
        installment      INT              NOT NULL DEFAULT 1,
        payment_channel  NVARCHAR(50)     NULL DEFAULT N'WEB',
        payment_group    NVARCHAR(50)     NULL DEFAULT N'PRODUCT',
        payment_status   NVARCHAR(50)     NOT NULL DEFAULT N'PENDING',
        -- PENDING | SUCCESS | FAILURE | CANCELLED | REFUNDED | PARTIAL_REFUNDED
        is_3d            BIT              NOT NULL DEFAULT 0,
        fraud_status     INT              NULL,
        bin_number       NVARCHAR(10)     NULL,
        card_family      NVARCHAR(50)     NULL,
        card_type        NVARCHAR(50)     NULL,
        card_association NVARCHAR(50)     NULL,
        card_last4       NVARCHAR(4)      NULL,
        error_code       NVARCHAR(50)     NULL,
        error_message    NVARCHAR(MAX)    NULL,
        auth_code        NVARCHAR(50)     NULL,
        host_reference   NVARCHAR(50)     NULL,
        phase            NVARCHAR(50)     NULL,
        raw_response     NVARCHAR(MAX)    NULL,  -- JSON string olarak sakla
        created_at       DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at       DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_payments           PRIMARY KEY (id),
        CONSTRAINT UQ_payments_id        UNIQUE      (payment_id),
        CONSTRAINT FK_payments_user      FOREIGN KEY (dummy_user_id)
            REFERENCES dbo.dummy_users(id)
    );

    CREATE NONCLUSTERED INDEX IX_payments_dummy_user_id ON dbo.payments(dummy_user_id);
    CREATE NONCLUSTERED INDEX IX_payments_basket_id     ON dbo.payments(basket_id);
    CREATE NONCLUSTERED INDEX IX_payments_status        ON dbo.payments(payment_status);
    CREATE NONCLUSTERED INDEX IX_payments_created_at    ON dbo.payments(created_at DESC);

    PRINT 'payments tablosu oluşturuldu.';
END
GO

-- ------------------------------------------------------------
-- TABLO: payment_items
-- Ödeme içindeki kalem detayları (alt satıcı bölüşümü dahil)
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.payment_items', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.payment_items (
        id                      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        payment_id              UNIQUEIDENTIFIER NOT NULL,
        sub_merchant_id         UNIQUEIDENTIFIER NULL,
        payment_transaction_id  NVARCHAR(255)    NULL,     -- iyzico transaction ID
        item_id                 NVARCHAR(255)    NOT NULL,
        item_name               NVARCHAR(255)    NOT NULL,
        category                NVARCHAR(255)    NULL,
        item_type               NVARCHAR(50)     NULL DEFAULT N'PHYSICAL',
        price                   DECIMAL(12, 2)   NOT NULL,
        sub_merchant_price      DECIMAL(12, 2)   NULL,    -- satıcıya aktarılacak
        merchant_commission     DECIMAL(12, 2)   NULL,    -- platform komisyonu
        iyzico_commission       DECIMAL(12, 2)   NULL,    -- iyzico komisyonu
        transaction_status      NVARCHAR(50)     NULL DEFAULT N'PENDING',
        blockage_rate           DECIMAL(5, 2)    NULL,
        blockage_resolved_date  DATETIME2        NULL,
        created_at              DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_payment_items              PRIMARY KEY (id),
        CONSTRAINT UQ_payment_transaction_id     UNIQUE      (payment_transaction_id),
        CONSTRAINT FK_items_payment              FOREIGN KEY (payment_id)
            REFERENCES dbo.payments(id) ON DELETE CASCADE,
        CONSTRAINT FK_items_sub_merchant         FOREIGN KEY (sub_merchant_id)
            REFERENCES dbo.sub_merchants(id)
    );

    CREATE NONCLUSTERED INDEX IX_payment_items_payment_id      ON dbo.payment_items(payment_id);
    CREATE NONCLUSTERED INDEX IX_payment_items_sub_merchant_id ON dbo.payment_items(sub_merchant_id);
    CREATE NONCLUSTERED INDEX IX_payment_items_transaction_id  ON dbo.payment_items(payment_transaction_id);

    PRINT 'payment_items tablosu oluşturuldu.';
END
GO

-- ------------------------------------------------------------
-- TABLO: refunds
-- İade kayıtları
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.refunds', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.refunds (
        id                      UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        payment_item_id         UNIQUEIDENTIFIER NOT NULL,
        payment_transaction_id  NVARCHAR(255)    NULL,
        refund_id               NVARCHAR(255)    NULL,    -- iyzico refund ID
        price                   DECIMAL(12, 2)   NOT NULL,
        currency                NVARCHAR(10)     NOT NULL DEFAULT N'TRY',
        status                  NVARCHAR(50)     NOT NULL DEFAULT N'PENDING',
        -- PENDING | SUCCESS | FAILURE
        description             NVARCHAR(MAX)    NULL,
        error_code              NVARCHAR(50)     NULL,
        error_message           NVARCHAR(MAX)    NULL,
        ip                      NVARCHAR(45)     NULL,
        created_at              DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at              DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_refunds              PRIMARY KEY (id),
        CONSTRAINT FK_refunds_payment_item FOREIGN KEY (payment_item_id)
            REFERENCES dbo.payment_items(id)
    );

    CREATE NONCLUSTERED INDEX IX_refunds_payment_item_id ON dbo.refunds(payment_item_id);
    CREATE NONCLUSTERED INDEX IX_refunds_status          ON dbo.refunds(status);

    PRINT 'refunds tablosu oluşturuldu.';
END
GO

-- ------------------------------------------------------------
-- TABLO: iyzico_webhook_logs
-- iyzico'dan gelen webhook bildirimlerinin logları
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.iyzico_webhook_logs', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.iyzico_webhook_logs (
        id             UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        event_type     NVARCHAR(100)    NOT NULL,
        -- SUBSCRIPTION_CREATED | SUBSCRIPTION_CANCELLED | PAYMENT_SUCCESS vb.
        payload        NVARCHAR(MAX)    NOT NULL,  -- JSON string
        processed      BIT              NOT NULL DEFAULT 0,
        error_message  NVARCHAR(MAX)    NULL,
        received_at    DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        processed_at   DATETIME2        NULL,
        CONSTRAINT PK_iyzico_webhook_logs PRIMARY KEY (id)
    );

    CREATE NONCLUSTERED INDEX IX_webhook_logs_event_type  ON dbo.iyzico_webhook_logs(event_type);
    CREATE NONCLUSTERED INDEX IX_webhook_logs_processed   ON dbo.iyzico_webhook_logs(processed);
    CREATE NONCLUSTERED INDEX IX_webhook_logs_received_at ON dbo.iyzico_webhook_logs(received_at DESC);

    PRINT 'iyzico_webhook_logs tablosu oluşturuldu.';
END
GO

-- ============================================================
-- TRIGGER: updated_at otomatik güncelleme
-- ============================================================

-- dummy_users
IF OBJECT_ID('dbo.trg_dummy_users_updated_at', 'TR') IS NULL
BEGIN
    EXEC('
    CREATE TRIGGER dbo.trg_dummy_users_updated_at
    ON dbo.dummy_users AFTER UPDATE AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.dummy_users
        SET updated_at = SYSUTCDATETIME()
        FROM dbo.dummy_users u
        INNER JOIN inserted i ON u.id = i.id;
    END');
    PRINT 'Trigger trg_dummy_users_updated_at oluşturuldu.';
END
GO

-- subscription_products
IF OBJECT_ID('dbo.trg_subscription_products_updated_at', 'TR') IS NULL
BEGIN
    EXEC('
    CREATE TRIGGER dbo.trg_subscription_products_updated_at
    ON dbo.subscription_products AFTER UPDATE AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.subscription_products
        SET updated_at = SYSUTCDATETIME()
        FROM dbo.subscription_products sp
        INNER JOIN inserted i ON sp.id = i.id;
    END');
    PRINT 'Trigger trg_subscription_products_updated_at oluşturuldu.';
END
GO

-- subscription_plans
IF OBJECT_ID('dbo.trg_subscription_plans_updated_at', 'TR') IS NULL
BEGIN
    EXEC('
    CREATE TRIGGER dbo.trg_subscription_plans_updated_at
    ON dbo.subscription_plans AFTER UPDATE AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.subscription_plans
        SET updated_at = SYSUTCDATETIME()
        FROM dbo.subscription_plans sp
        INNER JOIN inserted i ON sp.id = i.id;
    END');
    PRINT 'Trigger trg_subscription_plans_updated_at oluşturuldu.';
END
GO

-- subscriptions
IF OBJECT_ID('dbo.trg_subscriptions_updated_at', 'TR') IS NULL
BEGIN
    EXEC('
    CREATE TRIGGER dbo.trg_subscriptions_updated_at
    ON dbo.subscriptions AFTER UPDATE AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.subscriptions
        SET updated_at = SYSUTCDATETIME()
        FROM dbo.subscriptions s
        INNER JOIN inserted i ON s.id = i.id;
    END');
    PRINT 'Trigger trg_subscriptions_updated_at oluşturuldu.';
END
GO

-- sub_merchants
IF OBJECT_ID('dbo.trg_sub_merchants_updated_at', 'TR') IS NULL
BEGIN
    EXEC('
    CREATE TRIGGER dbo.trg_sub_merchants_updated_at
    ON dbo.sub_merchants AFTER UPDATE AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.sub_merchants
        SET updated_at = SYSUTCDATETIME()
        FROM dbo.sub_merchants sm
        INNER JOIN inserted i ON sm.id = i.id;
    END');
    PRINT 'Trigger trg_sub_merchants_updated_at oluşturuldu.';
END
GO

-- payments
IF OBJECT_ID('dbo.trg_payments_updated_at', 'TR') IS NULL
BEGIN
    EXEC('
    CREATE TRIGGER dbo.trg_payments_updated_at
    ON dbo.payments AFTER UPDATE AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.payments
        SET updated_at = SYSUTCDATETIME()
        FROM dbo.payments p
        INNER JOIN inserted i ON p.id = i.id;
    END');
    PRINT 'Trigger trg_payments_updated_at oluşturuldu.';
END
GO

-- refunds
IF OBJECT_ID('dbo.trg_refunds_updated_at', 'TR') IS NULL
BEGIN
    EXEC('
    CREATE TRIGGER dbo.trg_refunds_updated_at
    ON dbo.refunds AFTER UPDATE AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE dbo.refunds
        SET updated_at = SYSUTCDATETIME()
        FROM dbo.refunds r
        INNER JOIN inserted i ON r.id = i.id;
    END');
    PRINT 'Trigger trg_refunds_updated_at oluşturuldu.';
END
GO

PRINT '========================================';
PRINT 'Tum tablolar basariyla olusturuldu.';
PRINT '========================================';
