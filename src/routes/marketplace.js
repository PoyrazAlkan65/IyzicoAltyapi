const express = require('express');
const router = express.Router();
const marketplace = require('../services/marketplace');

// POST /api/marketplace/merchant - Alt satıcı oluştur
router.post('/merchant', async (req, res) => {
  try {
    const result = await marketplace.createSubMerchant(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/marketplace/merchant - Alt satıcı güncelle
router.put('/merchant', async (req, res) => {
  try {
    const result = await marketplace.updateSubMerchant(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/marketplace/merchant/:externalId - Alt satıcı sorgula
router.get('/merchant/:externalId', async (req, res) => {
  try {
    const result = await marketplace.getSubMerchant(req.params.externalId);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/marketplace/payment - Ödeme oluştur
router.post('/payment', async (req, res) => {
  try {
    const result = await marketplace.createPayment(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/marketplace/payment/3d/init - 3D Secure başlat
router.post('/payment/3d/init', async (req, res) => {
  try {
    const result = await marketplace.initiate3DPayment(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/marketplace/payment/3d/complete - 3D Secure tamamla (callback)
router.post('/payment/3d/complete', async (req, res) => {
  try {
    const result = await marketplace.complete3DPayment(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/marketplace/approve - Üye iş yeri ödeme onayı
router.post('/approve', async (req, res) => {
  try {
    const result = await marketplace.approvePayment(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/marketplace/disapprove - Üye iş yeri ödeme reddi
router.post('/disapprove', async (req, res) => {
  try {
    const result = await marketplace.disapprovePayment(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/marketplace/refund - İade et
router.post('/refund', async (req, res) => {
  try {
    const result = await marketplace.refundPayment(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
