require('dotenv').config();
const express = require('express');
const path = require('path');
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Routes
app.use('/api/membership', require('./src/routes/membership'));
app.use('/api/marketplace', require('./src/routes/marketplace'));

// Sağlık kontrolü
app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'iyzico Entegrasyon API çalışıyor' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Sunucu http://localhost:${PORT} adresinde çalışıyor`);
  console.log(`Ortam: sandbox (${process.env.IYZICO_BASE_URL})`);
});
