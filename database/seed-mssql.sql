-- ============================================================
--  iyzico Entegrasyon - Örnek Seed Verisi (MSSQL)
--  dummy_users tablosuna yazılır, users tablosu yoktur
-- ============================================================

USE iyzico;
GO

-- dummy_users
IF NOT EXISTS (SELECT 1 FROM dbo.dummy_users WHERE email = 'ahmet@test.com')
    INSERT INTO dbo.dummy_users (id, name, surname, email, gsm_number, identity_number, ip_address, city, country, address, zip_code)
    VALUES
        ('11111111-0000-0000-0000-000000000001', N'Ahmet',  N'Yılmaz', 'ahmet@test.com',  N'+905350000001', N'74300864791', N'85.34.78.112', N'Istanbul', N'Turkey', N'Test Mahallesi, Test Sokak No:1',         N'34000'),
        ('11111111-0000-0000-0000-000000000002', N'Ayşe',   N'Kaya',   'ayse@test.com',   N'+905350000002', N'74300864792', N'85.34.78.113', N'Ankara',   N'Turkey', N'Örnek Mahallesi, Örnek Caddesi No:5',    N'06000'),
        ('11111111-0000-0000-0000-000000000003', N'Mehmet', N'Demir',  'mehmet@test.com', N'+905350000003', N'74300864793', N'85.34.78.114', N'Izmir',    N'Turkey', N'Deneme Mahallesi, Deneme Sokak No:3',    N'35000');
GO

-- subscription_products
IF NOT EXISTS (SELECT 1 FROM dbo.subscription_products WHERE name = N'Premium Üyelik')
    INSERT INTO dbo.subscription_products (id, name, description, status)
    VALUES
        ('22222222-0000-0000-0000-000000000001', N'Premium Üyelik', N'Aylık premium içerik paketi', N'ACTIVE'),
        ('22222222-0000-0000-0000-000000000002', N'İş Üyeliği',     N'Kurumsal üyelik paketi',      N'ACTIVE');
GO

-- subscription_plans
IF NOT EXISTS (SELECT 1 FROM dbo.subscription_plans WHERE name = N'Aylık Premium')
    INSERT INTO dbo.subscription_plans (id, product_id, name, price, currency_code, payment_interval, payment_interval_count, trial_period_days)
    VALUES
        ('33333333-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001', N'Aylık Premium',  49.99,  N'TRY', N'MONTHLY', 1, 7),
        ('33333333-0000-0000-0000-000000000002', '22222222-0000-0000-0000-000000000001', N'Yıllık Premium', 499.99, N'TRY', N'YEARLY',  1, 14),
        ('33333333-0000-0000-0000-000000000003', '22222222-0000-0000-0000-000000000002', N'Aylık İş',       199.99, N'TRY', N'MONTHLY', 1, 0);
GO

-- sub_merchants
IF NOT EXISTS (SELECT 1 FROM dbo.sub_merchants WHERE external_id = 'merchant-001')
    INSERT INTO dbo.sub_merchants (id, external_id, name, email, gsm_number, iban, currency, sub_merchant_type, identity_number, contact_name, contact_surname, address, status)
    VALUES
        ('44444444-0000-0000-0000-000000000001', N'merchant-001', N'Kitap Dünyası',    'kitap@test.com',      N'+905350001001', N'TR180006200119000006672315', N'TRY', N'PERSONAL', N'74300864791', N'Ali',   N'Çelik',  N'Beyoğlu, İstanbul', N'ACTIVE'),
        ('44444444-0000-0000-0000-000000000002', N'merchant-002', N'Elektronik Store', 'elektronik@test.com', N'+905350001002', N'TR180006200119000006672316', N'TRY', N'PERSONAL', N'74300864792', N'Fatma', N'Şahin',  N'Kadıköy, İstanbul', N'ACTIVE'),
        ('44444444-0000-0000-0000-000000000003', N'merchant-003', N'Moda Butik',       'moda@test.com',       N'+905350001003', N'TR180006200119000006672317', N'TRY', N'PERSONAL', N'74300864793', N'Hasan', N'Yıldız', N'Şişli, İstanbul',   N'ACTIVE');
GO

PRINT 'Seed verisi basariyla eklendi.';
GO
