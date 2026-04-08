#!/usr/bin/env bash
# ============================================================
#  iyzico Entegrasyon - Bash Kurulum Scripti (Linux / macOS)
#  Kullanım: bash scripts/setup.sh
# ============================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
err()  { echo -e "${RED}  ✗ $1${NC}"; }
step() { echo -e "\n${CYAN}[$1] $2${NC}"; }

echo -e "\n${BOLD}╔══════════════════════════════════════╗"
echo -e "║  iyzico Entegrasyon Kurulum Scripti  ║"
echo -e "╚══════════════════════════════════════╝${NC}\n"

# ── 1. Node.js kontrolü ──────────────────────────────────────
step 1 "Node.js sürümü kontrol ediliyor..."
if ! command -v node &>/dev/null; then
  err "Node.js bulunamadı. https://nodejs.org adresinden indirin."
  exit 1
fi
NODE_MAJOR=$(node -e "process.stdout.write(process.version.split('.')[0].replace('v',''))")
if [ "$NODE_MAJOR" -lt 16 ]; then
  err "Node.js 16+ gerekli. Mevcut: $(node -v)"
  exit 1
fi
ok "Node.js $(node -v)"

# ── 2. npm bağımlılıkları ────────────────────────────────────
step 2 "npm bağımlılıkları yükleniyor..."
cd "$ROOT" && npm install --silent
ok "Bağımlılıklar yüklendi."

# ── 3. .env dosyası ──────────────────────────────────────────
step 3 ".env yapılandırılıyor..."
if [ -f "$ROOT/.env" ]; then
  warn ".env zaten mevcut, atlanıyor."
else
  read -rp "  iyzico Sandbox API Key    : " API_KEY
  read -rp "  iyzico Sandbox Secret Key : " SECRET_KEY
  read -rp "  Sunucu portu [65430]      : " PORT
  PORT=${PORT:-65430}
  API_KEY=${API_KEY:-sandbox-YOUR_API_KEY}
  SECRET_KEY=${SECRET_KEY:-sandbox-YOUR_SECRET_KEY}

  cat > "$ROOT/.env" <<EOF
IYZICO_API_KEY=$API_KEY
IYZICO_SECRET_KEY=$SECRET_KEY
IYZICO_BASE_URL=https://sandbox-api.iyzipay.com
PORT=$PORT
EOF
  ok ".env oluşturuldu (port: $PORT)"
fi

# ── 4. Veritabanı ────────────────────────────────────────────
step 4 "Veritabanı kurulumu"
echo "  [1] PostgreSQL  [2] MySQL  [3] Atla"
read -rp "  Seçim: " DB_CHOICE

if [ "$DB_CHOICE" = "1" ]; then
  read -rp "  PostgreSQL URL (postgresql://user:pass@host/db): " DB_URL
  if [ -n "$DB_URL" ]; then
    psql "$DB_URL" -f "$ROOT/database/schema.sql"
    ok "PostgreSQL şeması oluşturuldu."
    read -rp "  Örnek veriler eklensin mi? [e/H]: " DO_SEED
    if [[ "$DO_SEED" =~ ^[Ee]$ ]]; then
      psql "$DB_URL" -f "$ROOT/database/seed.sql"
      ok "Seed verisi eklendi."
    fi
  fi

elif [ "$DB_CHOICE" = "2" ]; then
  read -rp "  MySQL host [127.0.0.1]: " DB_HOST; DB_HOST=${DB_HOST:-127.0.0.1}
  read -rp "  MySQL port [3306]     : " DB_PORT; DB_PORT=${DB_PORT:-3306}
  read -rp "  MySQL kullanıcı [root]: " DB_USER; DB_USER=${DB_USER:-root}
  read -rsp "  MySQL şifre           : " DB_PASS; echo
  read -rp "  Veritabanı adı [iyzico]: " DB_NAME; DB_NAME=${DB_NAME:-iyzico}

  MYSQL_OPTS="-h$DB_HOST -P$DB_PORT -u$DB_USER"
  [ -n "$DB_PASS" ] && MYSQL_OPTS="$MYSQL_OPTS -p$DB_PASS"

  mysql $MYSQL_OPTS "$DB_NAME" < "$ROOT/database/schema-mysql.sql"
  ok "MySQL şeması oluşturuldu."
  read -rp "  Örnek veriler eklensin mi? [e/H]: " DO_SEED
  if [[ "$DO_SEED" =~ ^[Ee]$ ]]; then
    mysql $MYSQL_OPTS "$DB_NAME" < "$ROOT/database/seed.sql"
    ok "Seed verisi eklendi."
  fi
else
  warn "Veritabanı atlandı."
fi

# ── 5. Özet ──────────────────────────────────────────────────
PORT=$(grep PORT "$ROOT/.env" | cut -d= -f2)
step 5 "Kurulum tamamlandı!"
echo -e "
${GREEN}${BOLD}Sonraki adımlar:${NC}
  ${CYAN}npm start${NC}                  → Sunucuyu başlat
  ${CYAN}npm run test:membership${NC}    → Üyelik testi
  ${CYAN}npm run test:marketplace${NC}   → Pazaryeri testi

${GREEN}Arayüz:${NC}
  http://localhost:${PORT}
"
