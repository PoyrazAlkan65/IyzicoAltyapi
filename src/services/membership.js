const iyzipay = require('../config/iyzico');

/**
 * iyzico Üyelik (Subscription) Servisi
 */

// Ürün oluştur (subscription plan)
function createProduct(params) {
  return new Promise((resolve, reject) => {
    const request = {
      locale: params.locale || 'tr',
      conversationId: params.conversationId || `conv-${Date.now()}`,
      name: params.name,
      description: params.description || '',
    };

    iyzipay.subscriptionProduct.create(request, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
}

// Plan oluştur (fiyatlandırma planı)
function createPlan(params) {
  return new Promise((resolve, reject) => {
    const request = {
      locale: params.locale || 'tr',
      conversationId: params.conversationId || `conv-${Date.now()}`,
      name: params.name,
      paymentInterval: params.paymentInterval, // WEEKLY, MONTHLY, YEARLY
      paymentIntervalCount: params.paymentIntervalCount || 1,
      trialPeriodDays: params.trialPeriodDays || 0,
      price: params.price,
      currencyCode: params.currencyCode || 'TRY',
      productReferenceCode: params.productReferenceCode,
      planPaymentType: params.planPaymentType || 'RECURRING', // RECURRING veya RECURRING_WITH_PERIOD
    };

    iyzipay.subscriptionPlan.create(request, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
}

// Müşteri oluştur
function createCustomer(params) {
  return new Promise((resolve, reject) => {
    const request = {
      locale: params.locale || 'tr',
      conversationId: params.conversationId || `conv-${Date.now()}`,
      name: params.name,
      surname: params.surname,
      identityNumber: params.identityNumber || '74300864791',
      email: params.email,
      gsmNumber: params.gsmNumber || '',
      billingAddress: params.billingAddress || {
        contactName: `${params.name} ${params.surname}`,
        city: 'Istanbul',
        country: 'Turkey',
        address: 'Adres bilgisi',
        zipCode: '34000',
      },
      shippingAddress: params.shippingAddress || {
        contactName: `${params.name} ${params.surname}`,
        city: 'Istanbul',
        country: 'Turkey',
        address: 'Adres bilgisi',
        zipCode: '34000',
      },
    };

    iyzipay.subscriptionCustomer.create(request, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
}

// Abonelik başlat (kart bilgisiyle)
function createSubscription(params) {
  return new Promise((resolve, reject) => {
    const request = {
      locale: params.locale || 'tr',
      conversationId: params.conversationId || `conv-${Date.now()}`,
      pricingPlanReferenceCode: params.planReferenceCode,
      subscriptionInitialStatus: params.initialStatus || 'ACTIVE',
      customer: {
        name: params.customer.name,
        surname: params.customer.surname,
        identityNumber: params.customer.identityNumber || '74300864791',
        email: params.customer.email,
        gsmNumber: params.customer.gsmNumber || '',
        billingAddress: {
          contactName: `${params.customer.name} ${params.customer.surname}`,
          city: params.customer.city || 'Istanbul',
          country: params.customer.country || 'Turkey',
          address: params.customer.address || 'Adres bilgisi',
          zipCode: params.customer.zipCode || '34000',
        },
        shippingAddress: {
          contactName: `${params.customer.name} ${params.customer.surname}`,
          city: params.customer.city || 'Istanbul',
          country: params.customer.country || 'Turkey',
          address: params.customer.address || 'Adres bilgisi',
          zipCode: params.customer.zipCode || '34000',
        },
      },
      paymentCard: {
        cardHolderName: params.card.holderName,
        cardNumber: params.card.number,
        expireMonth: params.card.expireMonth,
        expireYear: params.card.expireYear,
        cvc: params.card.cvc,
      },
    };

    iyzipay.subscriptionCheckoutForm.initialize(request, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
}

// Aboneliği iptal et
function cancelSubscription(subscriptionReferenceCode, locale = 'tr') {
  return new Promise((resolve, reject) => {
    iyzipay.subscriptionCancel.update(
      {
        locale,
        conversationId: `conv-${Date.now()}`,
        subscriptionReferenceCode,
      },
      (err, result) => {
        if (err) return reject(err);
        resolve(result);
      }
    );
  });
}

// Aboneliği sorgula
function getSubscription(subscriptionReferenceCode, locale = 'tr') {
  return new Promise((resolve, reject) => {
    iyzipay.subscriptionExistingCustomer.retrieve(
      {
        locale,
        conversationId: `conv-${Date.now()}`,
        subscriptionReferenceCode,
      },
      (err, result) => {
        if (err) return reject(err);
        resolve(result);
      }
    );
  });
}

module.exports = {
  createProduct,
  createPlan,
  createCustomer,
  createSubscription,
  cancelSubscription,
  getSubscription,
};
