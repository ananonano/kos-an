# ============================================
# IMPORT DATA TO CLOUD SQL POSTGRESQL
# ============================================

param(
    [Parameter(Mandatory=$false)]
    [string]$SqlFile = ""
)

$ErrorActionPreference = "Stop"

Write-Host "🔄 Import to Cloud SQL PostgreSQL" -ForegroundColor Cyan
Write-Host "==================================`n" -ForegroundColor Cyan

# Configuration from .env
$DB_HOST = "34.50.122.143"
$DB_PORT = "5432"
$DB_NAME = "kosterpadu_db"
$DB_USER = "admin"
$DB_PASSWORD = "KosanPassword123"

# If no SQL file provided, list available files
if ($SqlFile -eq "") {
    Write-Host "📋 Available SQL backup files:" -ForegroundColor Yellow
    $sqlFiles = Get-ChildItem -Filter "*.sql" | Sort-Object LastWriteTime -Descending
    
    if ($sqlFiles.Count -eq 0) {
        Write-Host "❌ No SQL files found in current directory!" -ForegroundColor Red
        Write-Host "`n💡 Usage: .\import-to-cloudsql.ps1 <filename.sql>" -ForegroundColor Yellow
        exit 1
    }
    
    for ($i = 0; $i -lt $sqlFiles.Count; $i++) {
        $file = $sqlFiles[$i]
        $size = [math]::Round($file.Length / 1KB, 2)
        Write-Host "   [$($i + 1)] $($file.Name) ($size KB) - $($file.LastWriteTime)" -ForegroundColor White
    }
    
    $selection = Read-Host "`nSelect file number (1-$($sqlFiles.Count))"
    
    try {
        $index = [int]$selection - 1
        if ($index -ge 0 -and $index -lt $sqlFiles.Count) {
            $SqlFile = $sqlFiles[$index].Name
        } else {
            Write-Host "❌ Invalid selection!" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "❌ Invalid input!" -ForegroundColor Red
        exit 1
    }
}

# Check if file exists
if (-not (Test-Path $SqlFile)) {
    Write-Host "❌ File not found: $SqlFile" -ForegroundColor Red
    exit 1
}

Write-Host "`n📋 Import Configuration:" -ForegroundColor Yellow
Write-Host "   SQL File: $SqlFile"
Write-Host "   Cloud SQL Host: $DB_HOST"
Write-Host "   Database: $DB_NAME`n"

# Check if psql exists
$psqlPath = Get-Command psql -ErrorAction SilentlyContinue

if (-not $psqlPath) {
    Write-Host "❌ psql not found!" -ForegroundColor Red
    Write-Host "`n📌 Install PostgreSQL client:" -ForegroundColor Yellow
    Write-Host "   Download from: https://www.postgresql.org/download/windows/"
    Write-Host "   Or use: winget install PostgreSQL.PostgreSQL"
    exit 1
}

Write-Host "✅ psql found at: $($psqlPath.Source)`n" -ForegroundColor Green

# Confirmation
$confirm = Read-Host "⚠️  This will REPLACE all data in Cloud SQL. Continue? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "❌ Import cancelled." -ForegroundColor Red
    exit 0
}

Write-Host "`n🔄 Importing to Cloud SQL..." -ForegroundColor Cyan

try {
    # First, drop existing data (reset)
    Write-Host "   1/3 Cleaning existing data..." -ForegroundColor Yellow
    $env:PGPASSWORD = $DB_PASSWORD
    
    $dropQuery = @"
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO $DB_USER;
GRANT ALL ON SCHEMA public TO public;
"@
    
    $dropQuery | & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to clean database!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "   ✅ Database cleaned" -ForegroundColor Green
    
    # Import SQL file
    Write-Host "   2/3 Importing SQL file..." -ForegroundColor Yellow
    
    & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f $SqlFile
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Import failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "   ✅ Data imported" -ForegroundColor Green
    
    # Verify import
    Write-Host "   3/3 Verifying import..." -ForegroundColor Yellow
    
    $verifyQuery = @"
SELECT 
    'users' as table_name, COUNT(*) as count FROM users
UNION ALL SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL SELECT 'tenants', COUNT(*) FROM tenants
UNION ALL SELECT 'contracts', COUNT(*) FROM contracts
UNION ALL SELECT 'bills', COUNT(*) FROM bills
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'maintenance', COUNT(*) FROM maintenance
UNION ALL SELECT 'announcements', COUNT(*) FROM announcements
ORDER BY table_name;
"@
    
    Write-Host "`n📊 Imported Data Count:" -ForegroundColor Cyan
    $verifyQuery | & psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t
    
    Write-Host "`n✅ Import completed successfully!" -ForegroundColor Green
    Write-Host "`n📌 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Test backend: https://kosan-backend-670153358279.asia-southeast2.run.app/api/auth/login"
    Write-Host "   2. Test web: https://kosan-web-670153358279.asia-southeast2.run.app"
    Write-Host "   3. Login with real user credentials from imported data`n"
    
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    exit 1
} finally {
    $env:PGPASSWORD = $null
}

Write-Host "✅ Done!" -ForegroundColor Green
