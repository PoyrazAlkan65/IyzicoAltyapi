# iyzico Sandbox Entegrasyon Kiti

Node.js tabanlı, hazır kullanımlı iyzico **Üyelik (Subscription)** ve **Pazaryeri (Marketplace)** entegrasyon projesi. Sandbox ortamında hızlıca test edebilmeniz için REST API, interaktif arayüz ve veritabanı şemaları içerir.

---

## İçindekiler

- [Özellikler](#özellikler)
- [Gereksinimler](#gereksinimler)
- [Kurulum](#kurulum)
- [Yapılandırma](#yapılandırma)
- [Proje Yapısı](#proje-yapısı)
- [API Referansı](#api-referansı)
- [Veritabanı Şeması](#veritabanı-şeması)
- [Test Arayüzü](#test-arayüzü)
- [Sandbox Test Kartları](#sandbox-test-kartları)

---

## Özellikler

| Modül | Özellikler |
|---|---|
| **Üyelik** | Ürün & plan oluşturma, müşteri kaydı, abonelik başlatma/sorgulama/iptal |
| **Pazaryeri** | Alt satıcı yönetimi (oluştur/güncelle/sorgula), komisyon bölüşümlü ödeme, 3D Secure, iade |
| **Arayüz** | Tüm endpoint'leri test edebileceğiniz interaktif web paneli |
| **Veritabanı** | PostgreSQL ve MySQL şemaları, örnek seed verisi |
| **Kurulum** | Node.js, Bash ve Windows `.bat` kurulum scriptleri |

---

## Gereksinimler

- **Node.js** v16 veya üzeri
- **npm** v8 veya üzeri
- iyzico sandbox hesabı → [sandbox.iyzipay.com](https://sandbox.iyzipay.com)
- *(İsteğe bağlı)* PostgreSQL 13+ veya MySQL 8+

---

## Kurulum

### Otomatik Kurulum (Önerilen)

```bash
# Linux / macOS
bash scripts/setup.sh

# Windows
scripts\setup.bat

# Platform bağımsız (Node.js ile)
node scripts/setup.js
```

Kurulum scripti şunları yapar:
1. Node.js sürüm kontrolü
2. `npm install`
3. `.env` dosyasını interaktif olarak oluşturur
4. İstediğiniz veritabanına şemayı kurar
5. Seed verisi ekler (isteğe bağlı)

---

### Manuel Kurulum

```bash
# 1. Bağımlılıkları yükle
npm install

# 2. .env dosyasını oluştur
cp .env.example .env
# .env içindeki değerleri kendi sandbox bilgilerinizle doldurun

# 3. Veritabanı şemasını kur (PostgreSQL)
psql postgresql://user:pass@localhost/iyzico -f database/schema.sql

# 3b. MySQL için
mysql -u root -p iyzico < database/schema-mysql.sql

# 4. Örnek veri ekle (isteğe bağlı)
psql postgresql://user:pass@localhost/iyzico -f database/seed.sql

# 5. Sunucuyu başlat
npm start
```

---

## Yapılandırma

`.env` dosyası:

```env
IYZICO_API_KEY=sandbox-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
IYZICO_SECRET_KEY=sandbox-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
IYZICO_BASE_URL=https://sandbox-api.iyzipay.com
PORT=65430
```

API anahtarlarını almak için:
1. [sandbox.iyzipay.com](https://sandbox.iyzipay.com) adresine gidin
2. Hesap oluşturun veya giriş yapın
3. **Ayarlar → API Bilgileri** menüsünden `API Key` ve `Secret Key`'i kopyalayın

---

## Proje Yapısı

```
iyzico-odeme/
│
├── index.js                        # Express uygulaması giriş noktası
├── .env                            # Ortam değişkenleri (git'e ekleme!)
│
├── src/
│   ├── config/
│   │   └── iyzico.js               # iyzipay bağlantı konfigürasyonu
│   ├── services/
│   │   ├── membership.js           # Üyelik iş mantığı
│   │   └── marketplace.js          # Pazaryeri iş mantığı
│   └── routes/
│       ├── membership.js           # /api/membership/* route'ları
│       └── marketplace.js          # /api/marketplace/* route'ları
│
├── public/
│   └── index.html                  # İnteraktif test arayüzü
│
├── database/
│   ├── schema.sql                  # PostgreSQL şeması
│   ├── schema-mysql.sql            # MySQL şeması
│   └── seed.sql                    # Örnek veriler
│
├── scripts/
│   ├── setup.js                    # Node.js kurulum scripti
│   ├── setup.sh                    # Bash kurulum scripti
│   └── setup.bat                   # Windows kurulum scripti
│
└── examples/
    ├── test-membership.js          # Üyelik akışı test scripti
    └── test-marketplace.js         # Pazaryeri akışı test scripti
```

---

## API Referansı

Sunucu varsayılan olarak `http://localhost:65430` adresinde çalışır.

### Üyelik Endpoint'leri

#### `POST /api/membership/product`
Yeni bir subscription ürünü oluşturur. Planlar bu ürüne bağlanır.

```json
{
  "name": "Premium Üyelik",
  "description": "Aylık premium içerik paketi"
}
```

---

#### `POST /api/membership/plan`
Ürüne bağlı fiyatlandırma planı oluşturur.

```json
{
  "name": "Aylık Plan",
  "productReferenceCode": "iyzico-ürün-referans-kodu",
  "price": "49.99",
  "currencyCode": "TRY",
  "paymentInterval": "MONTHLY",
  "paymentIntervalCount": 1,
  "trialPeriodDays": 7
}
```

`paymentInterval` değerleri: `WEEKLY` · `MONTHLY` · `YEARLY`

---

#### `POST /api/membership/customer`
Abonelik sistemine müşteri kaydeder.

```json
{
  "name": "Ahmet",
  "surname": "Yılmaz",
  "email": "ahmet@ornek.com",
  "identityNumber": "74300864791",
  "gsmNumber": "+905350000000"
}
```

---

#### `POST /api/membership/subscribe`
Kart bilgisiyle abonelik başlatır.

```json
{
  "planReferenceCode": "iyzico-plan-referans-kodu",
  "customer": {
    "name": "Ahmet",
    "surname": "Yılmaz",
    "email": "ahmet@ornek.com",
    "gsmNumber": "+905350000000",
    "address": "Test Mah. No:1",
    "city": "Istanbul"
  },
  "card": {
    "holderName": "Ahmet Yılmaz",
    "number": "5528790000000008",
    "expireMonth": "12",
    "expireYear": "2030",
    "cvc": "123"
  }
}
```

---

#### `GET /api/membership/:referenceCode`
Abonelik detaylarını sorgular.

---

#### `DELETE /api/membership/:referenceCode`
Aktif aboneliği iptal eder.

---

### Pazaryeri Endpoint'leri

#### `POST /api/marketplace/merchant`
Yeni alt satıcı ekler.

```json
{
  "name": "Örnek Mağaza",
  "email": "magaza@ornek.com",
  "gsmNumber": "+905350000000",
  "subMerchantType": "PERSONAL",
  "identityNumber": "74300864791",
  "iban": "TR180006200119000006672315",
  "address": "Test Mah. No:1 İstanbul",
  "currency": "TRY",
  "contactName": "Ali",
  "contactSurname": "Veli"
}
```

`subMerchantType` değerleri:

| Değer | Açıklama | Zorunlu Alan |
|---|---|---|
| `PERSONAL` | Bireysel satıcı | `identityNumber` |
| `PRIVATE_COMPANY` | Şahıs şirketi | `taxNumber` |
| `LIMITED_OR_JOINT_STOCK_COMPANY` | Ltd. / A.Ş. | `taxNumber` |

---

#### `PUT /api/marketplace/merchant`
Alt satıcı bilgilerini günceller.

```json
{
  "subMerchantKey": "iyzico-merchant-key",
  "name": "Güncellenmiş Mağaza",
  "iban": "TR180006200119000006672315"
}
```

---

#### `GET /api/marketplace/merchant/:externalId`
External ID ile alt satıcı bilgilerini getirir.

---

#### `POST /api/marketplace/payment`
Komisyon bölüşümlü pazaryeri ödemesi oluşturur.

```json
{
  "price": "100.00",
  "paidPrice": "100.00",
  "currency": "TRY",
  "installment": 1,
  "card": {
    "holderName": "Ahmet Yılmaz",
    "number": "5528790000000008",
    "expireMonth": "12",
    "expireYear": "2030",
    "cvc": "123"
  },
  "buyer": {
    "id": "buyer-001",
    "name": "Ahmet",
    "surname": "Yılmaz",
    "email": "ahmet@ornek.com",
    "ip": "85.34.78.112"
  },
  "basketItems": [
    {
      "id": "item-001",
      "name": "Ürün Adı",
      "price": "100.00",
      "subMerchantKey": "iyzico-merchant-key",
      "subMerchantPrice": "90.00"
    }
  ]
}
```

> `subMerchantPrice`: Satıcıya aktarılacak tutar. `price - subMerchantPrice` farkı platform komisyonunuzdur.

---

#### `POST /api/marketplace/payment/3d/init`
3D Secure akışını başlatır. Yanıtta dönen HTML banka 3DS sayfasına yönlendirme için kullanılır.

Gövde `/api/marketplace/payment` ile aynıdır, ek olarak:

```json
{
  "callbackUrl": "https://siteniz.com/odeme/3d-callback"
}
```

---

#### `POST /api/marketplace/payment/3d/complete`
Bankadan geri dönen bilgilerle ödemeyi tamamlar.

```json
{
  "paymentId": "iyzico-payment-id",
  "conversationData": "conversation-data"
}
```

---

#### `POST /api/marketplace/refund`
İşlem bazlı kısmi veya tam iade oluşturur.

```json
{
  "paymentTransactionId": "iyzico-transaction-id",
  "price": "50.00",
  "currency": "TRY",
  "ip": "85.34.78.112"
}
```

---

## Veritabanı Şeması

### Tablolar ve İlişkiler

```
users
  └── subscriptions ──── subscription_plans ──── subscription_products
  └── payments
        └── payment_items ──── sub_merchants
              └── refunds

iyzico_webhook_logs  (bağımsız log tablosu)
```

### Desteklenen Veritabanları

| Dosya | Veritabanı |
|---|---|
| `database/schema.sql` | PostgreSQL 13+ |
| `database/schema-mysql.sql` | MySQL 8+ |
| `database/schema-mssql.sql` | SQL Server 2016+ / MSSQL |
| `database/seed.sql` | PostgreSQL & MySQL seed verisi |
| `database/seed-mssql.sql` | MSSQL seed verisi |

### Tablo Özeti

| Tablo | Açıklama | MSSQL notu |
|---|---|---|
| `dummy_users` | Test/dummy kullanıcılar | MSSQL'de `users` yerine bu tablo kullanılır |
| `subscription_products` | iyzico üyelik ürünleri | |
| `subscription_plans` | Fiyatlandırma planları (aylık, yıllık…) | |
| `subscriptions` | Kullanıcı abonelikleri ve durumları | FK: `dummy_user_id` |
| `sub_merchants` | Pazaryeri alt satıcıları | |
| `payments` | Tüm ödeme kayıtları | FK: `dummy_user_id` |
| `payment_items` | Ödeme içindeki ürün kalemleri ve bölüşüm detayları | |
| `refunds` | İade kayıtları | |
| `iyzico_webhook_logs` | iyzico webhook bildirim logları | |

> **MSSQL'de `users` tablosu oluşturulmaz.** Mevcut projenizde zaten bir `users` tablonuz varsa, `subscriptions` ve `payments` tablolarındaki `dummy_user_id` alanını kendi tablonuza FK olarak bağlayabilirsiniz.

#### MSSQL Manuel Kurulum

```bash
# Şema kur
sqlcmd -S localhost,1433 -U sa -P "SifreniZ" -d iyzico -i database/schema-mssql.sql

# Seed verisi ekle
sqlcmd -S localhost,1433 -U sa -P "SifreniZ" -d iyzico -i database/seed-mssql.sql
```

---

## Test Arayüzü

Sunucu çalışırken `http://localhost:65430` adresini tarayıcıda açın.

**Özellikler:**
- Sol panelden endpoint seçimi
- Sandbox varsayılan değerleriyle hazır formlar
- Syntax highlight'lı JSON yanıt görüntüleme
- `success` / `failure` durum badge'i

---

## Sandbox Test Kartları

| Kart No | Tip | Son Kullanma | CVC | Sonuç |
|---|---|---|---|---|
| `5528790000000008` | Mastercard | 12/2030 | 123 | Başarılı |
| `4766620000000001` | Visa | 07/2032 | 000 | Başarılı |
| `4603450000000000` | Visa | 01/2030 | 000 | Başarılı |
| `5406670000000009` | Mastercard | 07/2032 | 000 | Başarısız |
| `4000000000000002` | Visa | 01/2030 | 000 | Çalıntı kart |

> Sandbox'ta gerçek kart bilgisi kullanmayın. Tüm işlemler test ortamında gerçekleşir, para transferi olmaz.

---

## npm Komutları

```bash
npm start                  # Sunucuyu başlat (port 65430)
npm run test:membership    # Üyelik akışı test scripti
npm run test:marketplace   # Pazaryeri akışı test scripti
node scripts/setup.js      # Kurulum sihirbazı
```

---

## Lisans

MIT
