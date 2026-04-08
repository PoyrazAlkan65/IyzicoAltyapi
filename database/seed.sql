-- ============================================================
--  iyzico Entegrasyon - Örnek Seed Verisi (PostgreSQL)
--  Sandbox testleri için hazır veriler
-- ============================================================

-- Örnek kullanıcılar
INSERT INTO users (id, name, surname, email, gsm_number, identity_number, ip_address, city, country, address, zip_code)
VALUES
    ('11111111-0000-0000-0000-000000000001', 'Ahmet',   'Yılmaz', 'ahmet@test.com',  '+905350000001', '74300864791', '85.34.78.112', 'Istanbul', 'Turkey', 'Test Mahallesi, Test Sokak No:1', '34000'),
    ('11111111-0000-0000-0000-000000000002', 'Ayşe',    'Kaya',   'ayse@test.com',   '+905350000002', '74300864792', '85.34.78.113', 'Ankara',   'Turkey', 'Örnek Mahallesi, Örnek Caddesi No:5', '06000'),
    ('11111111-0000-0000-0000-000000000003', 'Mehmet',  'Demir',  'mehmet@test.com', '+905350000003', '74300864793', '85.34.78.114', 'Izmir',    'Turkey', 'Deneme Mahallesi, Deneme Sokak No:3', '35000')
ON CONFLICT (email) DO NOTHING;

-- Örnek üyelik ürünü (iyzico sandbox'a kaydettikten sonra reference_code güncellenecek)
INSERT INTO subscription_products (id, name, description, status)
VALUES
    ('22222222-0000-0000-0000-000000000001', 'Premium Üyelik',  'Aylık premium içerik paketi',  'ACTIVE'),
    ('22222222-0000-0000-0000-000000000002', 'İş Üyeliği',      'Kurumsal üyelik paketi',        'ACTIVE')
ON CONFLICT DO NOTHING;

-- Örnek planlar
INSERT INTO subscription_plans (id, product_id, name, price, currency_code, payment_interval, payment_interval_count, trial_period_days)
VALUES
    ('33333333-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001', 'Aylık Premium',  49.99, 'TRY', 'MONTHLY', 1, 7),
    ('33333333-0000-0000-0000-000000000002', '22222222-0000-0000-0000-000000000001', 'Yıllık Premium', 499.99,'TRY', 'YEARLY',  1, 14),
    ('33333333-0000-0000-0000-000000000003', '22222222-0000-0000-0000-000000000002', 'Aylık İş',       199.99,'TRY', 'MONTHLY', 1, 0)
ON CONFLICT DO NOTHING;

-- Örnek alt satıcılar
INSERT INTO sub_merchants (id, external_id, name, email, gsm_number, iban, currency, sub_merchant_type, identity_number, contact_name, contact_surname, address, status)
VALUES
    ('44444444-0000-0000-0000-000000000001', 'merchant-001', 'Kitap Dünyası',    'kitap@test.com',   '+905350001001', 'TR180006200119000006672315', 'TRY', 'PERSONAL',        '74300864791', 'Ali',   'Çelik',  'Beyoğlu, İstanbul', 'ACTIVE'),
    ('44444444-0000-0000-0000-000000000002', 'merchant-002', 'Elektronik Store', 'elektronik@test.com','+905350001002','TR180006200119000006672316', 'TRY', 'PRIVATE_COMPANY',  NULL,          'Fatma', 'Şahin',  'Kadıköy, İstanbul', 'ACTIVE'),
    ('44444444-0000-0000-0000-000000000003', 'merchant-003', 'Moda Butik',       'moda@test.com',    '+905350001003', 'TR180006200119000006672317', 'TRY', 'PERSONAL',        '74300864793', 'Hasan', 'Yıldız', 'Şişli, İstanbul',   'ACTIVE')
ON CONFLICT DO NOTHING;
