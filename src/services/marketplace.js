const iyzipay = require('../config/iyzico');

/**
 * iyzico Pazaryeri (Marketplace) Servisi
 * Alt satıcı yönetimi ve ödeme bölüşümü
 */

// Alt satıcı (sub-merchant) oluştur
function createSubMerchant(params) {
  return new Promise((resolve, reject) => {
    const request = {
      locale: params.locale || 'tr',
      conversationId: params.conversationId || `conv-${Date.now()}`,
      name: params.name,
      email: params.email,
      gsmNumber: params.gsmNumber || '',
      address: params.address || '',
      iban: params.iban,
      bankCode: params.bankCode || '',
      bankAccountNumber: params.bankAccountNumber || '',
      currency: params.currency || 'TRY',
      taxOffice: params.taxOffice || '',
      contactName: params.contactName || '',
      contactSurname: params.contactSurname || '',
      legalCompanyTitle: params.legalCompanyTitle || '',
      subMerchantType: params.subMerchantType || 'PERSONAL', // PERSONAL, PRIVATE_COMPANY, LIMITED_OR_JOINT_STOCK_COMPANY
      subMerchantExternalId: params.externalId || `merchant-${Date.now()}`,
    };

    // Şirket türüne göre vergi numarası veya TC kimlik no
    if (params.subMerchantType === 'PERSONAL') {
      request.identityNumber = params.identityNumber;
    } else {
      request.taxNumber = params.taxNumber;
    }

    iyzipay.subMerchant.create(request, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
}

// Alt satıcı bilgilerini güncelle
function updateSubMerchant(params) {
  return new Promise((resolve, reject) => {
    const request = {
      locale: params.locale || 'tr',
      conversationId: params.conversationId || `conv-${Date.now()}`,
      subMerchantKey: params.subMerchantKey,
      name: params.name,
      email: params.email,
      gsmNumber: params.gsmNumber || '',
      address: params.address || '',
      iban: params.iban,
      currency: params.currency || 'TRY',
      taxOffice: params.taxOffice || '',
      contactName: params.contactName || '',
      contactSurname: params.contactSurname || '',
      legalCompanyTitle: params.legalCompanyTitle || '',
    };

    if (params.identityNumber) request.identityNumber = params.identityNumber;
    if (params.taxNumber) request.taxNumber = params.taxNumber;

    iyzipay.subMerchant.update(request, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
}

// Alt satıcıyı sorgula
function getSubMerchant(subMerchantExternalId, locale = 'tr') {
  return new Promise((resolve, reject) => {
    iyzipay.subMerchant.retrieve(
      {
        locale,
        conversationId: `conv-${Date.now()}`,
        subMerchantExternalId,
      },
      (err, result) => {
        if (err) return reject(err);
        resolve(result);
      }
    );
  });
}

// Pazaryeri ödemesi oluştur (ödeme bölüşümüyle)
function createPayment(params) {
  return new Promise((resolve, reject) => {
    const request = {
      locale: params.locale || 'tr',
      conversationId: params.conversationId || `conv-${Date.now()}`,
      price: params.price,
      paidPrice: params.paidPrice,
      currency: params.currency || 'TRY',
      installment: params.installment || 1,
      basketId: params.basketId || `basket-${Date.now()}`,
      paymentChannel: params.paymentChannel || 'WEB',
      paymentGroup: params.paymentGroup || 'PRODUCT',
      paymentCard: {
        cardHolderName: params.card.holderName,
        cardNumber: params.card.number,
        expireMonth: params.card.expireMonth,
        expireYear: params.card.expireYear,
        cvc: params.card.cvc,
        registerCard: 0,
      },
      buyer: {
        id: params.buyer.id,
        name: params.buyer.name,
        surname: params.buyer.surname,
        gsmNumber: params.buyer.gsmNumber || '',
        email: params.buyer.email,
        identityNumber: params.buyer.identityNumber || '74300864791',
        lastLoginDate: params.buyer.lastLoginDate || '2015-10-05 12:43:35',
        registrationDate: params.buyer.registrationDate || '2013-04-21 15:12:09',
        registrationAddress: params.buyer.address || 'Adres bilgisi',
        ip: params.buyer.ip || '85.34.78.112',
        city: params.buyer.city || 'Istanbul',
        country: params.buyer.country || 'Turkey',
        zipCode: params.buyer.zipCode || '34000',
      },
      shippingAddress: {
        contactName: `${params.buyer.name} ${params.buyer.surname}`,
        city: params.buyer.city || 'Istanbul',
        country: params.buyer.country || 'Turkey',
        address: params.buyer.address || 'Adres bilgisi',
        zipCode: params.buyer.zipCode || '34000',
      },
      billingAddress: {
        contactName: `${params.buyer.name} ${params.buyer.surname}`,
        city: params.buyer.city || 'Istanbul',
        country: params.buyer.country || 'Turkey',
        address: params.buyer.address || 'Adres bilgisi',
        zipCode: params.buyer.zipCode || '34000',
      },
      // Sepet öğeleri - her biri bir alt satıcıya ait
      basketItems: params.basketItems.map((item) => ({
        id: item.id,
        name: item.name,
        category1: item.category || 'Genel',
        itemType: item.itemType || 'PHYSICAL',
        price: item.price,
        subMerchantKey: item.subMerchantKey,
        subMerchantPrice: item.subMerchantPrice, // Alt satıcıya ödenecek tutar
      })),
    };

    iyzipay.payment.create(request, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
}

// 3D Secure pazaryeri ödemesi başlat
function initiate3DPayment(params) {
  return new Promise((resolve, reject) => {
    const request = {
      locale: params.locale || 'tr',
      conversationId: params.conversationId || `conv-${Date.now()}`,
      price: params.price,
      paidPrice: params.paidPrice,
      currency: params.currency || 'TRY',
      installment: params.installment || 1,
      basketId: params.basketId || `basket-${Date.now()}`,
      paymentChannel: params.paymentChannel || 'WEB',
      paymentGroup: params.paymentGroup || 'PRODUCT',
      callbackUrl: params.callbackUrl,
      paymentCard: {
        cardHolderName: params.card.holderName,
        cardNumber: params.card.number,
        expireMonth: params.card.expireMonth,
        expireYear: params.card.expireYear,
        cvc: params.card.cvc,
        registerCard: 0,
      },
      buyer: {
        id: params.buyer.id,
        name: params.buyer.name,
        surname: params.buyer.surname,
        gsmNumber: params.buyer.gsmNumber || '',
        email: params.buyer.email,
        identityNumber: params.buyer.identityNumber || '74300864791',
        lastLoginDate: '2015-10-05 12:43:35',
        registrationDate: '2013-04-21 15:12:09',
        registrationAddress: params.buyer.address || 'Adres bilgisi',
        ip: params.buyer.ip || '85.34.78.112',
        city: params.buyer.city || 'Istanbul',
        country: params.buyer.country || 'Turkey',
        zipCode: params.buyer.zipCode || '34000',
      },
      shippingAddress: {
        contactName: `${params.buyer.name} ${params.buyer.surname}`,
        city: params.buyer.city || 'Istanbul',
        country: params.buyer.country || 'Turkey',
        address: params.buyer.address || 'Adres bilgisi',
        zipCode: params.buyer.zipCode || '34000',
      },
      billingAddress: {
        contactName: `${params.buyer.name} ${params.buyer.surname}`,
        city: params.buyer.city || 'Istanbul',
        country: params.buyer.country || 'Turkey',
        address: params.buyer.address || 'Adres bilgisi',
        zipCode: params.buyer.zipCode || '34000',
      },
      basketItems: params.basketItems.map((item) => ({
        id: item.id,
        name: item.name,
        category1: item.category || 'Genel',
        itemType: item.itemType || 'PHYSICAL',
        price: item.price,
        subMerchantKey: item.subMerchantKey,
        subMerchantPrice: item.subMerchantPrice,
      })),
    };

    iyzipay.threedsInitialize.create(request, (err, result) => {
      if (err) return reject(err);
      resolve(result);
    });
  });
}

// 3D Secure ödeme tamamla
function complete3DPayment(params) {
  return new Promise((resolve, reject) => {
    iyzipay.threedsPayment.create(
      {
        locale: params.locale || 'tr',
        conversationId: params.conversationId || `conv-${Date.now()}`,
        paymentId: params.paymentId,
        conversationData: params.conversationData,
      },
      (err, result) => {
        if (err) return reject(err);
        resolve(result);
      }
    );
  });
}

// Üye iş yeri ödeme onayı (onay → satıcıya para serbest bırakılır)
// POST /payment/iyzipos/item/approve
function approvePayment(params) {
  return new Promise((resolve, reject) => {
    iyzipay.approval.create(
      {
        locale: params.locale || 'tr',
        conversationId: params.conversationId || `conv-${Date.now()}`,
        paymentTransactionId: params.paymentTransactionId,
      },
      (err, result) => {
        if (err) return reject(err);
        resolve(result);
      }
    );
  });
}

// Üye iş yeri ödeme onayı reddi (disapprove → satıcıya para gönderilmez)
// POST /payment/iyzipos/item/disapprove
function disapprovePayment(params) {
  return new Promise((resolve, reject) => {
    iyzipay.disapproval.create(
      {
        locale: params.locale || 'tr',
        conversationId: params.conversationId || `conv-${Date.now()}`,
        paymentTransactionId: params.paymentTransactionId,
      },
      (err, result) => {
        if (err) return reject(err);
        resolve(result);
      }
    );
  });
}

// Ödemeyi iade et
function refundPayment(params) {
  return new Promise((resolve, reject) => {
    iyzipay.refund.create(
      {
        locale: params.locale || 'tr',
        conversationId: params.conversationId || `conv-${Date.now()}`,
        paymentTransactionId: params.paymentTransactionId,
        price: params.price,
        currency: params.currency || 'TRY',
        ip: params.ip || '85.34.78.112',
      },
      (err, result) => {
        if (err) return reject(err);
        resolve(result);
      }
    );
  });
}

module.exports = {
  createSubMerchant,
  updateSubMerchant,
  getSubMerchant,
  createPayment,
  initiate3DPayment,
  complete3DPayment,
  approvePayment,
  disapprovePayment,
  refundPayment,
};
