/**
 * Üyelik (Subscription) Test Örnekleri
 * Çalıştır: node examples/test-membership.js
 */
require('dotenv').config();
const membership = require('../src/services/membership');

async function run() {
  console.log('--- Üyelik Testi Başlıyor ---\n');

  // 1. Ürün oluştur
  console.log('1. Ürün oluşturuluyor...');
  const product = await membership.createProduct({
    name: 'Premium Üyelik',
    description: 'Aylık premium üyelik paketi',
  });
  console.log('Ürün:', JSON.stringify(product, null, 2));

  if (product.status !== 'success') {
    console.error('Ürün oluşturulamadı, test durduruluyor.');
    return;
  }

  const productCode = product.data?.referenceCode;
  console.log('\nÜrün referans kodu:', productCode);

  // 2. Plan oluştur
  console.log('\n2. Plan oluşturuluyor...');
  const plan = await membership.createPlan({
    name: 'Aylık Plan',
    paymentInterval: 'MONTHLY',
    paymentIntervalCount: 1,
    price: '49.99',
    currencyCode: 'TRY',
    productReferenceCode: productCode,
    trialPeriodDays: 7,
  });
  console.log('Plan:', JSON.stringify(plan, null, 2));

  if (plan.status !== 'success') {
    console.error('Plan oluşturulamadı.');
    return;
  }

  const planCode = plan.data?.referenceCode;
  console.log('\nPlan referans kodu:', planCode);

  // 3. Abonelik başlat (sandbox test kartı)
  console.log('\n3. Abonelik başlatılıyor...');
  const subscription = await membership.createSubscription({
    planReferenceCode: planCode,
    customer: {
      name: 'Ahmet',
      surname: 'Yılmaz',
      email: 'ahmet@test.com',
      gsmNumber: '+905350000000',
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Test Mahallesi, Test Sokak No:1',
      zipCode: '34000',
    },
    card: {
      holderName: 'Ahmet Yılmaz',
      number: '5528790000000008', // Sandbox test kartı
      expireMonth: '12',
      expireYear: '2030',
      cvc: '123',
    },
  });
  console.log('Abonelik:', JSON.stringify(subscription, null, 2));
}

run().catch(console.error);
