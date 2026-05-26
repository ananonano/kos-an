# Test Create Payment Endpoint

## Endpoint Information
- **URL**: `POST http://localhost:5000/api/payments`
- **Auth**: Required (Bearer token)
- **Role**: Any authenticated user (tenant or admin)

## Required Fields
```json
{
  "bill_id": number,        // ID tagihan yang akan dibayar
  "tenant_id": number,      // ID penghuni yang membayar
  "jumlah": number,         // Jumlah pembayaran
  "tanggal_bayar": string,  // Format: "YYYY-MM-DD" atau ISO date
  "metode_pembayaran": string  // Contoh: "transfer", "cash", "e-wallet"
}
```

## Optional Fields
```json
{
  "bukti_pembayaran": string,  // URL/path bukti pembayaran
  "keterangan": string         // Catatan tambahan
}
```

## Steps to Test

### 1. Get Authentication Token
Login terlebih dahulu untuk mendapatkan token:

```bash
curl -X POST http://localhost:5000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"admin@kosan.com\",\"password\":\"admin123\"}"
```

Copy token dari response.

### 2. Check Available Bills
Cek tagihan yang ada di database:

```bash
curl -X GET http://localhost:5000/api/bills ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Pilih salah satu `bill_id` yang statusnya `belum_lunas`.

### 3. Check Available Tenants
Cek penghuni yang ada:

```bash
curl -X GET http://localhost:5000/api/tenants ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Pilih salah satu `tenant_id`.

### 4. Create Payment
Buat pembayaran baru:

```bash
curl -X POST http://localhost:5000/api/payments ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -d "{\"bill_id\":1,\"tenant_id\":1,\"jumlah\":1500000,\"tanggal_bayar\":\"2026-05-26\",\"metode_pembayaran\":\"transfer\",\"keterangan\":\"Test pembayaran via API\"}"
```

### 5. Verify Payment Created
Cek apakah payment berhasil dibuat:

```bash
curl -X GET http://localhost:5000/api/payments ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Atau cek di DBeaver:
```sql
SELECT * FROM payments ORDER BY created_at DESC LIMIT 5;
```

## Expected Response

### Success (201 Created)
```json
{
  "success": true,
  "message": "Pembayaran berhasil disubmit, menunggu verifikasi",
  "data": {
    "id": 1,
    "bill_id": 1,
    "tenant_id": 1,
    "jumlah": 1500000,
    "tanggal_bayar": "2026-05-26T00:00:00.000Z",
    "metode_pembayaran": "transfer",
    "status": "menunggu_verifikasi",
    "bukti_pembayaran": null,
    "keterangan": "Test pembayaran via API",
    "verified_by": null,
    "verified_at": null,
    "created_at": "2026-05-26T...",
    "updated_at": "2026-05-26T..."
  }
}
```

### Error (400 Bad Request)
```json
{
  "success": false,
  "message": "Bill ID, tenant ID, jumlah, tanggal bayar, dan metode pembayaran harus diisi"
}
```

### Error (401 Unauthorized)
```json
{
  "success": false,
  "message": "Token tidak valid"
}
```

## Test Flow

1. ✅ Create payment dengan data valid
2. ✅ Verify payment muncul di list payments (status: menunggu_verifikasi)
3. ✅ Verify payment muncul di DBeaver
4. ✅ Admin verify payment
5. ✅ Check bill status berubah jadi 'lunas'
6. ✅ Check payment status berubah jadi 'lunas'

## Alternative: Test via PowerShell

```powershell
# 1. Login
$loginResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" -Method POST -ContentType "application/json" -Body '{"email":"admin@kosan.com","password":"admin123"}'
$token = $loginResponse.token

# 2. Create Payment
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$body = @{
    bill_id = 1
    tenant_id = 1
    jumlah = 1500000
    tanggal_bayar = "2026-05-26"
    metode_pembayaran = "transfer"
    keterangan = "Test pembayaran via PowerShell"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5000/api/payments" -Method POST -Headers $headers -Body $body
$response

# 3. Get All Payments
$payments = Invoke-RestMethod -Uri "http://localhost:5000/api/payments" -Method GET -Headers $headers
$payments.data
```

## Notes

- Payment status akan otomatis di-set ke `menunggu_verifikasi`
- Setelah admin verify, status akan berubah jadi `lunas` dan bill status juga akan update
- Jika admin reject, status akan berubah jadi `ditolak`
- Tenant bisa update payment selama statusnya masih `menunggu_verifikasi`
