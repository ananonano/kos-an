-- Fix nama tenant dari GORGA DOLI LIBERTO NAPITUPULU ke Budi Santoso
-- Jalankan di Cloud SQL

-- 1. Cek data sekarang
SELECT id, user_id, nama, email FROM tenants WHERE email = 'budi@email.com';

-- 2. Update nama tenant
UPDATE tenants 
SET nama = 'Budi Santoso'
WHERE email = 'budi@email.com';

-- 3. Verifikasi perubahan
SELECT id, user_id, nama, email FROM tenants WHERE email = 'budi@email.com';

-- Expected result: nama = 'Budi Santoso'
