/**
 * Pazaryeri (Marketplace) Test Örnekleri
 * Çalıştır: node examples/test-marketplace.js
 */
require('dotenv').config();
const marketplace = require('../src/services/marketplace');

async function run() {
  console.log('--- Pazaryeri Testi Başlıyor ---\n');

  // 1. Alt satıcı oluştur
  console.log('1. Alt satıcı oluşturuluyor...');
  const externalId = `merchant-${Date.now()}`;
  const merchant = await marketplace.createSubMerchant({
    name: 'Test Mağaza',
    email: 'magaza@test.com',
    gsmNumber: '+905350000000',
    address: 'Test Mahallesi, Test Sokak No:1, İstanbul',
    iban: 'TR180006200119000006672315',
    currency: 'TRY',
    taxOffice: 'Kadıköy',
    contactName: 'Mehmet',
    contactSurname: 'Öztürk',
    legalCompanyTitle: 'Test Mağaza Ltd. Şti.',
    subMerchantType: 'PERSONAL',
    identityNumber: '74300864791', // Sandbox test TC
    externalId,
  });
  console.log('Alt Satıcı:', JSON.stringify(merchant, null, 2));

  if (merchant.status !== 'success') {
    console.error('Alt satıcı oluşturulamadı, test durduruluyor.');
    return;
  }

  const subMerchantKey = merchant.data?.subMerchantKey;
  console.log('\nAlt satıcı key:', subMerchantKey);

  // 2. Pazaryeri ödemesi oluştur
  console.log('\n2. Pazaryeri ödemesi oluşturuluyor...');
  const payment = await marketplace.createPayment({
    price: '100.00',
    paidPrice: '100.00',
    currency: 'TRY',
    installment: 1,
    basketId: `basket-${Date.now()}`,
    card: {
      holderName: 'Ahmet Yılmaz',
      number: '5528790000000008', // Sandbox test kartı
      expireMonth: '12',
      expireYear: '2030',
      cvc: '123',
    },
    buyer: {
      id: 'buyer-001',
      name: 'Ahmet',
      surname: 'Yılmaz',
      email: 'ahmet@test.com',
      gsmNumber: '+905350000000',
      address: 'Test Mahallesi, Test Sokak No:1',
      ip: '85.34.78.112',
      city: 'Istanbul',
      country: 'Turkey',
      zipCode: '34000',
    },
    basketItems: [
      {
        id: 'item-001',
        name: 'Test Ürün',
        category: 'Elektronik',
        itemType: 'PHYSICAL',
        price: '100.00',
        subMerchantKey: subMerchantKey,
        subMerchantPrice: '90.00', // Satıcıya gidecek tutar (platform komisyon: 10 TL)
      },
    ],
  });
  console.log('Ödeme:', JSON.stringify(payment, null, 2));
}

run().catch(console.error);
