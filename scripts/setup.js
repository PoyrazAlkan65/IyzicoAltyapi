#!/usr/bin/env node
/**
 * iyzico Entegrasyon - Node.js Kurulum Scripti
 * Kullanım: node scripts/setup.js
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const ROOT = path.join(__dirname, '..');
const ENV_FILE = path.join(ROOT, '.env');
const ENV_EXAMPLE = path.join(ROOT, '.env.example');

const colors = {
  reset:  '\x1b[0m',
  green:  '\x1b[32m',
  yellow: '\x1b[33m',
  red:    '\x1b[31m',
  cyan:   '\x1b[36m',
  bold:   '\x1b[1m',
};

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const ask = (q) => new Promise(resolve => rl.question(q, resolve));

function log(color, msg)  { console.log(`${color}${msg}${colors.reset}`); }
function step(n, msg)     { log(colors.cyan,   `\n[${n}] ${msg}`); }
function ok(msg)          { log(colors.green,  `  ✓ ${msg}`); }
function warn(msg)        { log(colors.yellow, `  ⚠ ${msg}`); }
function err(msg)         { log(colors.red,    `  ✗ ${msg}`); }

async function main() {
  console.log(`\n${colors.bold}╔══════════════════════════════════════╗`);
  console.log(`║   iyzico Entegrasyon Kurulum Scripti  ║`);
  console.log(`╚══════════════════════════════════════╝${colors.reset}\n`);

  // ── 1. Node version kontrolü ──────────────────────────────
  step(1, 'Node.js sürümü kontrol ediliyor...');
  const nodeVersion = process.versions.node;
  const major = parseInt(nodeVersion.split('.')[0]);
  if (major < 16) {
    err(`Node.js 16+ gerekli. Mevcut: v${nodeVersion}`);
    process.exit(1);
  }
  ok(`Node.js v${nodeVersion}`);

  // ── 2. npm bağımlılıkları ────────────────────────────────
  step(2, 'npm bağımlılıkları yükleniyor...');
  try {
    execSync('npm install', { cwd: ROOT, stdio: 'pipe' });
    ok('Bağımlılıklar yüklendi.');
  } catch (e) {
    err('npm install başarısız.');
    console.error(e.stderr?.toString());
    process.exit(1);
  }

  // ── 3. .env dosyası ──────────────────────────────────────
  step(3, '.env dosyası yapılandırılıyor...');
  if (fs.existsSync(ENV_FILE)) {
    warn('.env zaten mevcut, atlanıyor. (Silip tekrar çalıştırın)');
  } else {
    let apiKey    = await ask('  iyzico Sandbox API Key    : ');
    let secretKey = await ask('  iyzico Sandbox Secret Key : ');
    let port      = await ask('  Sunucu portu [65430]      : ');
    if (!port) port = '65430';
    if (!apiKey)    apiKey    = 'sandbox-YOUR_API_KEY';
    if (!secretKey) secretKey = 'sandbox-YOUR_SECRET_KEY';

    const envContent = [
      `IYZICO_API_KEY=${apiKey}`,
      `IYZICO_SECRET_KEY=${secretKey}`,
      `IYZICO_BASE_URL=https://sandbox-api.iyzipay.com`,
      `PORT=${port}`,
    ].join('\n') + '\n';

    fs.writeFileSync(ENV_FILE, envContent);
    ok(`.env dosyası oluşturuldu (port: ${port})`);
  }

  // ── 4. Veritabanı seçimi ─────────────────────────────────
  step(4, 'Veritabanı kurulumu');
  const dbChoice = await ask('  Veritabanı: [1] PostgreSQL  [2] MySQL  [3] MSSQL  [4] Atla → ');

  if (dbChoice === '1') {
    const dbUrl  = await ask('  PostgreSQL bağlantı URL (postgresql://user:pass@host/db): ');
    if (dbUrl) {
      try {
        execSync(`psql "${dbUrl}" -f "${path.join(ROOT, 'database/schema.sql')}"`, { stdio: 'inherit' });
        ok('PostgreSQL şeması oluşturuldu.');

        const doSeed = await ask('  Örnek veriler eklensin mi? [e/H]: ');
        if (doSeed.toLowerCase() === 'e') {
          execSync(`psql "${dbUrl}" -f "${path.join(ROOT, 'database/seed.sql')}"`, { stdio: 'inherit' });
          ok('Seed verisi eklendi.');
        }
      } catch (e) {
        err('PostgreSQL kurulumu başarısız. psql yüklü mü?');
      }
    }
  } else if (dbChoice === '2') {
    const host   = await ask('  MySQL host [127.0.0.1]: ') || '127.0.0.1';
    const port2  = await ask('  MySQL port [3306]     : ') || '3306';
    const user   = await ask('  MySQL kullanıcı [root]: ') || 'root';
    const pass   = await ask('  MySQL şifre           : ');
    const db     = await ask('  Veritabanı adı [iyzico]: ') || 'iyzico';

    const mysqlCmd = `mysql -h${host} -P${port2} -u${user} ${pass ? `-p${pass}` : ''} ${db}`;
    try {
      execSync(`${mysqlCmd} < "${path.join(ROOT, 'database/schema-mysql.sql')}"`, { stdio: 'inherit', shell: true });
      ok('MySQL şeması oluşturuldu.');

      const doSeed = await ask('  Örnek veriler eklensin mi? [e/H]: ');
      if (doSeed.toLowerCase() === 'e') {
        execSync(`${mysqlCmd} < "${path.join(ROOT, 'database/seed.sql')}"`, { stdio: 'inherit', shell: true });
        ok('Seed verisi eklendi.');
      }
    } catch (e) {
      err('MySQL kurulumu başarısız. mysql client yüklü mü?');
    }
  } else if (dbChoice === '3') {
    const host   = await ask('  MSSQL host [localhost]   : ') || 'localhost';
    const port2  = await ask('  MSSQL port [1433]        : ') || '1433';
    const user   = await ask('  MSSQL kullanıcı [sa]     : ') || 'sa';
    const pass   = await ask('  MSSQL şifre              : ');
    const db     = await ask('  Veritabanı adı [iyzico]  : ') || 'iyzico';

    // sqlcmd ile bağlan (SQL Server Tools)
    const sqlcmd = `sqlcmd -S ${host},${port2} -U ${user} -P "${pass}" -d ${db}`;
    try {
      execSync(`${sqlcmd} -i "${path.join(ROOT, 'database/schema-mssql.sql')}"`, { stdio: 'inherit', shell: true });
      ok('MSSQL şeması oluşturuldu. (dummy_users tablosu users yerine kullanılır)');

      const doSeed = await ask('  Örnek veriler eklensin mi? [e/H]: ');
      if (doSeed.toLowerCase() === 'e') {
        execSync(`${sqlcmd} -i "${path.join(ROOT, 'database/seed-mssql.sql')}"`, { stdio: 'inherit', shell: true });
        ok('Seed verisi eklendi.');
      }
    } catch (e) {
      err('MSSQL kurulumu başarısız. sqlcmd yüklü mü? (SQL Server Tools)');
      warn('Manuel kurulum: sqlcmd -S <host> -U <user> -P <pass> -d iyzico -i database/schema-mssql.sql');
    }
  } else {
    warn('Veritabanı kurulumu atlandı. Şemayı manuel uygulamak için:');
    warn('  PostgreSQL → psql <DB_URL> -f database/schema.sql');
    warn('  MySQL      → mysql <db> < database/schema-mysql.sql');
    warn('  MSSQL      → sqlcmd -S <host> -U <user> -P <pass> -d iyzico -i database/schema-mssql.sql');
  }

  // ── 5. Özet ──────────────────────────────────────────────
  step(5, 'Kurulum tamamlandı!');
  const envData = fs.existsSync(ENV_FILE) ? fs.readFileSync(ENV_FILE, 'utf8') : '';
  const portMatch = envData.match(/PORT=(\d+)/);
  const port = portMatch ? portMatch[1] : '65430';

  console.log(`
${colors.green}${colors.bold}Sonraki adımlar:${colors.reset}
  ${colors.cyan}npm start${colors.reset}                  → Sunucuyu başlat
  ${colors.cyan}npm run test:membership${colors.reset}    → Üyelik testini çalıştır
  ${colors.cyan}npm run test:marketplace${colors.reset}   → Pazaryeri testini çalıştır

${colors.green}Arayüz:${colors.reset}
  http://localhost:${port}

${colors.yellow}Not: .env dosyasındaki API anahtarlarınızı${colors.reset}
${colors.yellow}     sandbox.iyzipay.com'dan alabilirsiniz.${colors.reset}
`);

  rl.close();
}

main().catch(e => {
  console.error(e);
  rl.close();
  process.exit(1);
});
