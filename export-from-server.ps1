# ============================================
# EXPORT POSTGRESQL DATABASE FROM SERVER
# ============================================
# Run this script ON THE SERVER (192.168.18.24)

$ErrorActionPreference = "Stop"

Write-Host "🔄 PostgreSQL Data Export Script" -ForegroundColor Cyan
Write-Host "================================`n" -ForegroundColor Cyan

# Configuration
$DB_HOST = "localhost"  # or 192.168.18.24
$DB_PORT = "5432"
$DB_NAME = "kosterpadu_db"
$DB_USER = "admin"
$EXPORT_FILE = "kosterpadu_backup_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').sql"
$EXPORT_PATH = "C:\Temp\$EXPORT_FILE"

Write-Host "📋 Export Configuration:" -ForegroundColor Yellow
Write-Host "   Database: $DB_NAME"
Write-Host "   Host: $DB_HOST"
Write-Host "   Export to: $EXPORT_PATH`n"

# Check if pg_dump exists
$pgDumpPath = Get-Command pg_dump -ErrorAction SilentlyContinue

if (-not $pgDumpPath) {
    Write-Host "❌ pg_dump not found!" -ForegroundColor Red
    Write-Host "   Please install PostgreSQL client tools first." -ForegroundColor Red
    exit 1
}

# Create temp directory
if (-not (Test-Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" | Out-Null
}

# Export database
Write-Host "🔄 Exporting database..." -ForegroundColor Cyan

try {
    $env:PGPASSWORD = Read-Host "Enter PostgreSQL password for user '$DB_USER'" -AsSecureString | ConvertFrom-SecureString -AsPlainText
    
    & pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -F p -f $EXPORT_PATH
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Export successful!" -ForegroundColor Green
        Write-Host "`n📄 Backup file created:" -ForegroundColor Cyan
        Write-Host "   $EXPORT_PATH" -ForegroundColor White
        
        $fileSize = (Get-Item $EXPORT_PATH).Length / 1KB
        Write-Host "   Size: $([math]::Round($fileSize, 2)) KB`n" -ForegroundColor White
        
        Write-Host "📂 Next Steps:" -ForegroundColor Yellow
        Write-Host "   1. Copy file to USB drive"
        Write-Host "   2. Transfer to laptop"
        Write-Host "   3. Import to Cloud SQL`n"
        
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
