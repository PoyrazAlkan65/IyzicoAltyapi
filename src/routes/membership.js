const express = require('express');
const router = express.Router();
const membership = require('../services/membership');

// POST /api/membership/product - Subscription ürünü oluştur
router.post('/product', async (req, res) => {
  try {
    const result = await membership.createProduct(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/membership/plan - Plan oluştur
router.post('/plan', async (req, res) => {
  try {
    const result = await membership.createPlan(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/membership/customer - Müşteri oluştur
router.post('/customer', async (req, res) => {
  try {
    const result = await membership.createCustomer(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/membership/subscribe - Abonelik başlat
router.post('/subscribe', async (req, res) => {
  try {
    const result = await membership.createSubscription(req.body);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/membership/:referenceCode - Aboneliği iptal et
router.delete('/:referenceCode', async (req, res) => {
  try {
    const result = await membership.cancelSubscription(req.params.referenceCode);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/membership/:referenceCode - Abonelik sorgula
router.get('/:referenceCode', async (req, res) => {
  try {
    const result = await membership.getSubscription(req.params.referenceCode);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
