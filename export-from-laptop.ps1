# ============================================
# EXPORT POSTGRESQL DATABASE FROM LAPTOP
# ============================================
# Run this script AFTER connecting to same network as server

$ErrorActionPreference = "Stop"

Write-Host "🔄 PostgreSQL Remote Export Script" -ForegroundColor Cyan
Write-Host "===================================`n" -ForegroundColor Cyan

# Configuration
$DB_HOST = "192.168.18.24"
$DB_PORT = "5432"
$DB_NAME = "kosterpadu_db"
$DB_USER = "admin"
$EXPORT_FILE = "kosterpadu_backup_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').sql"
$EXPORT_PATH = ".\$EXPORT_FILE"

Write-Host "📋 Export Configuration:" -ForegroundColor Yellow
Write-Host "   Database: $DB_NAME"
Write-Host "   Host: $DB_HOST"
Write-Host "   Export to: $EXPORT_PATH`n"

# Test connection first
Write-Host "🔍 Testing connection to server..." -ForegroundColor Cyan
$pingResult = Test-Connection -ComputerName $DB_HOST -Count 2 -Quiet

if (-not $pingResult) {
    Write-Host "❌ Cannot reach server at $DB_HOST" -ForegroundColor Red
    Write-Host "   Make sure you're connected to the same network!" -ForegroundColor Red
    Write-Host "`n📌 Your current IP:" -ForegroundColor Yellow
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -like "192.168.*"} | Select-Object IPAddress, InterfaceAlias
    exit 1
}

Write-Host "✅ Server is reachable!`n" -ForegroundColor Green

# Check if pg_dump exists
$pgDumpPath = Get-Command pg_dump -ErrorAction SilentlyContinue

if (-not $pgDumpPath) {
    Write-Host "❌ pg_dump not found!" -ForegroundColor Red
    Write-Host "`n📌 Install PostgreSQL client:" -ForegroundColor Yellow
    Write-Host "   Download from: https://www.postgresql.org/download/windows/"
    Write-Host "   Or use: winget install PostgreSQL.PostgreSQL"
    exit 1
}

Write-Host "✅ pg_dump found at: $($pgDumpPath.Source)`n" -ForegroundColor Green

# Export database
Write-Host "🔄 Exporting database..." -ForegroundColor Cyan

try {
    $password = Read-Host "Enter PostgreSQL password for user '$DB_USER'" -AsSecureString
    $env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    & pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -F p -f $EXPORT_PATH
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Export successful!" -ForegroundColor Green
        Write-Host "`n📄 Backup file created:" -ForegroundColor Cyan
        Write-Host "   $((Get-Item $EXPORT_PATH).FullName)" -ForegroundColor White
        
        $fileSize = (Get-Item $EXPORT_PATH).Length / 1KB
        Write-Host "   Size: $([math]::Round($fileSize, 2)) KB`n" -ForegroundColor White
        
        Write-Host "📂 Next Steps:" -ForegroundColor Yellow
        Write-Host "   Run: .\import-to-cloudsql.ps1 $EXPORT_FILE`n"
        
    } else {
        Write-Host "❌ Export failed!" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    exit 1
} finally {
    $env:PGPASSWORD = $null
}

Write-Host "✅ Done!" -ForegroundColor Green
