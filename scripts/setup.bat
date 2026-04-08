@echo off
REM ============================================================
REM  iyzico Entegrasyon - Windows Kurulum Scripti
REM  Kullanım: scripts\setup.bat
REM ============================================================
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo  ╔══════════════════════════════════════╗
echo  ║  iyzico Entegrasyon Kurulum Scripti  ║
echo  ╚══════════════════════════════════════╝
echo.

cd /d "%~dp0.."

REM ── 1. Node.js kontrolü ────────────────────────────────────
echo [1] Node.js kontrol ediliyor...
node --version >nul 2>&1
if errorlevel 1 (
    echo   ✗ Node.js bulunamadi. https://nodejs.org adresinden indirin.
    pause & exit /b 1
)
for /f "tokens=*" %%v in ('node --version') do echo   ✓ Node.js %%v

REM ── 2. npm bağımlılıkları ──────────────────────────────────
echo.
echo [2] npm bagimliliklar yukleniyor...
call npm install --silent
if errorlevel 1 ( echo   ✗ npm install basarisiz. & pause & exit /b 1 )
echo   ✓ Bagimliliklar yuklendi.

REM ── 3. .env ────────────────────────────────────────────────
echo.
echo [3] .env yapılandırılıyor...
if exist ".env" (
    echo   ⚠ .env zaten mevcut, atlaniyor.
) else (
    set /p API_KEY="  iyzico Sandbox API Key    : "
    set /p SECRET_KEY="  iyzico Sandbox Secret Key : "
    set /p PORT="  Sunucu portu [65430]      : "
    if "!PORT!"=="" set PORT=65430
    if "!API_KEY!"=="" set API_KEY=sandbox-YOUR_API_KEY
    if "!SECRET_KEY!"=="" set SECRET_KEY=sandbox-YOUR_SECRET_KEY

    (
        echo IYZICO_API_KEY=!API_KEY!
        echo IYZICO_SECRET_KEY=!SECRET_KEY!
        echo IYZICO_BASE_URL=https://sandbox-api.iyzipay.com
        echo PORT=!PORT!
    ) > .env
    echo   ✓ .env olusturuldu ^(port: !PORT!^)
)

REM ── 4. Veritabanı ──────────────────────────────────────────
echo.
echo [4] Veritabani kurulumu
echo   [1] PostgreSQL   [2] MySQL   [3] MSSQL   [4] Atla
set /p DB_CHOICE="  Secim: "

if "%DB_CHOICE%"=="1" (
    set /p DB_URL="  PostgreSQL URL (postgresql://user:pass@host/db): "
    psql "!DB_URL!" -f database\schema.sql
    if not errorlevel 1 (
        echo   ✓ PostgreSQL semasi olusturuldu.
        set /p DO_SEED="  Ornek veriler eklensin mi? [e/H]: "
        if /i "!DO_SEED!"=="e" (
            psql "!DB_URL!" -f database\seed.sql
            echo   ✓ Seed verisi eklendi.
        )
    ) else echo   ✗ PostgreSQL hatasi. psql yuklu mu?
)

if "%DB_CHOICE%"=="2" (
    set /p DB_HOST="  MySQL host [127.0.0.1]: "
    if "!DB_HOST!"=="" set DB_HOST=127.0.0.1
    set /p DB_PORT="  MySQL port [3306]     : "
    if "!DB_PORT!"=="" set DB_PORT=3306
    set /p DB_USER="  MySQL kullanici [root] : "
    if "!DB_USER!"=="" set DB_USER=root
    set /p DB_PASS="  MySQL sifre            : "
    set /p DB_NAME="  Veritabani adi [iyzico]: "
    if "!DB_NAME!"=="" set DB_NAME=iyzico

    mysql -h!DB_HOST! -P!DB_PORT! -u!DB_USER! -p!DB_PASS! !DB_NAME! < database\schema-mysql.sql
    if not errorlevel 1 (
        echo   ✓ MySQL semasi olusturuldu.
        set /p DO_SEED="  Ornek veriler eklensin mi? [e/H]: "
        if /i "!DO_SEED!"=="e" (
            mysql -h!DB_HOST! -P!DB_PORT! -u!DB_USER! -p!DB_PASS! !DB_NAME! < database\seed.sql
            echo   ✓ Seed verisi eklendi.
        )
    ) else echo   ✗ MySQL hatasi. mysql client yuklu mu?
)

if "%DB_CHOICE%"=="3" (
    set /p DB_HOST="  MSSQL host [localhost]  : "
    if "!DB_HOST!"=="" set DB_HOST=localhost
    set /p DB_PORT="  MSSQL port [1433]       : "
    if "!DB_PORT!"=="" set DB_PORT=1433
    set /p DB_USER="  MSSQL kullanici [sa]    : "
    if "!DB_USER!"=="" set DB_USER=sa
    set /p DB_PASS="  MSSQL sifre             : "
    set /p DB_NAME="  Veritabani adi [iyzico] : "
    if "!DB_NAME!"=="" set DB_NAME=iyzico

    sqlcmd -S !DB_HOST!,!DB_PORT! -U !DB_USER! -P "!DB_PASS!" -d !DB_NAME! -i database\schema-mssql.sql
    if not errorlevel 1 (
        echo   ✓ MSSQL semasi olusturuldu. ^(dummy_users tablosu users yerine kullanilir^)
        set /p DO_SEED="  Ornek veriler eklensin mi? [e/H]: "
        if /i "!DO_SEED!"=="e" (
            sqlcmd -S !DB_HOST!,!DB_PORT! -U !DB_USER! -P "!DB_PASS!" -d !DB_NAME! -i database\seed-mssql.sql
            echo   ✓ Seed verisi eklendi.
        )
    ) else echo   ✗ MSSQL hatasi. sqlcmd yuklu mu? ^(SQL Server Tools^)
)

if "%DB_CHOICE%"=="4" echo   ⚠ Veritabani atlandi.

REM ── 5. Özet ────────────────────────────────────────────────
echo.
echo [5] Kurulum tamamlandi!
echo.
echo   Sunucuyu baslat : npm start
echo   Uyelik testi    : npm run test:membership
echo   Pazaryeri testi : npm run test:marketplace
echo.
for /f "tokens=2 delims==" %%p in ('findstr "PORT" .env') do set FINAL_PORT=%%p
echo   Arayuz: http://localhost:!FINAL_PORT!
echo.
pause
