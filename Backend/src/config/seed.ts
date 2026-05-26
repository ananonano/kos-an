// ============================================
// DATABASE SEED SCRIPT - Dummy Data
// ============================================

import { pool } from './database';
import bcrypt from 'bcryptjs';

async function seed() {
  const client = await pool.connect();

  try {
    console.log('🌱 Starting database seeding...\n');

    await client.query('BEGIN');

    // ============================================
    // 1. SEED USERS
    // ============================================
    console.log('👤 Seeding users...');

    const adminPassword = await bcrypt.hash('admin123', 10);
    const tenantPassword = await bcrypt.hash('tenant123', 10);

    const usersResult = await client.query(`
      INSERT INTO users (email, password, nama, role, no_telepon) VALUES
      ('admin@kosterpadu.com', $1, 'Admin Kos Terpadu', 'admin', '081234567890'),
      ('budi@email.com', $2, 'Budi Santoso', 'tenant', '081234567891'),
      ('ani@email.com', $2, 'Ani Wijaya', 'tenant', '081234567892'),
      ('citra@email.com', $2, 'Citra Dewi', 'tenant', '081234567893'),
      ('doni@email.com', $2, 'Doni Pratama', 'tenant', '081234567894')
      ON CONFLICT (email) DO NOTHING
      RETURNING id, email, role
    `, [adminPassword, tenantPassword]);

    console.log(`✅ ${usersResult.rows.length} users seeded\n`);

    // ============================================
    // 2. SEED ROOMS
    // ============================================
    console.log('🏠 Seeding rooms...');

    const roomsResult = await client.query(`
      INSERT INTO rooms (nomor_kamar, tipe, harga, status, deskripsi, fasilitas) VALUES
      ('A1', 'Standard', 1500000, 'terisi', 'Kamar nyaman dengan AC', '["AC", "Kasur", "Lemari", "Meja Belajar"]'::jsonb),
      ('A2', 'Standard', 1500000, 'terisi', 'Kamar nyaman dengan AC', '["AC", "Kasur", "Lemari", "Meja Belajar"]'::jsonb),
      ('A3', 'Standard', 1500000, 'kosong', 'Kamar nyaman dengan AC', '["AC", "Kasur", "Lemari", "Meja Belajar"]'::jsonb),
      ('B1', 'Deluxe', 2000000, 'terisi', 'Kamar mewah dengan kamar mandi dalam', '["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV"]'::jsonb),
      ('B2', 'Deluxe', 2000000, 'kosong', 'Kamar mewah dengan kamar mandi dalam', '["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV"]'::jsonb),
      ('C1', 'Premium', 2500000, 'terisi', 'Kamar premium dengan balkon', '["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV", "Balkon", "Kulkas"]'::jsonb),
      ('C2', 'Premium', 2500000, 'kosong', 'Kamar premium dengan balkon', '["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV", "Balkon", "Kulkas"]'::jsonb),
      ('D1', 'Standard', 1500000, 'kosong', 'Kamar nyaman dengan AC', '["AC", "Kasur", "Lemari", "Meja Belajar"]'::jsonb)
      ON CONFLICT (nomor_kamar) DO NOTHING
      RETURNING id, nomor_kamar
    `);

    console.log(`✅ ${roomsResult.rows.length} rooms seeded\n`);

    // ============================================
    // 3. SEED TENANTS
    // ============================================
    console.log('👥 Seeding tenants...');

    // Get user IDs
    const users = await client.query(`SELECT id, email FROM users WHERE role = 'tenant' ORDER BY id LIMIT 4`);
    const rooms = await client.query(`SELECT id, nomor_kamar FROM rooms WHERE status = 'terisi' ORDER BY id LIMIT 4`);

    if (users.rows.length >= 4 && rooms.rows.length >= 4) {
      const tenantsResult = await client.query(`
        INSERT INTO tenants (user_id, kamar_id, nama, email, no_telepon, alamat_asal, pekerjaan, kontak_darurat, tanggal_masuk, status) VALUES
        ($1, $2, 'Budi Santoso', 'budi@email.com', '081234567891', 'Jakarta', 'Karyawan Swasta', '081234567801', '2024-01-01', 'aktif'),
        ($3, $4, 'Ani Wijaya', 'ani@email.com', '081234567892', 'Bandung', 'Mahasiswa', '081234567802', '2024-01-15', 'aktif'),
        ($5, $6, 'Citra Dewi', 'citra@email.com', '081234567893', 'Surabaya', 'Freelancer', '081234567803', '2024-02-01', 'aktif'),
        ($7, $8, 'Doni Pratama', 'doni@email.com', '081234567894', 'Yogyakarta', 'Karyawan Swasta', '081234567804', '2024-02-15', 'aktif')
        RETURNING id, nama
      `, [
        users.rows[0].id, rooms.rows[0].id,
        users.rows[1].id, rooms.rows[1].id,
        users.rows[2].id, rooms.rows[2].id,
        users.rows[3].id, rooms.rows[3].id,
      ]);

      console.log(`✅ ${tenantsResult.rows.length} tenants seeded\n`);
    }

    // ============================================
    // 4. SEED CONTRACTS
    // ============================================
    console.log('📄 Seeding contracts...');

    const tenants = await client.query(`SELECT id, kamar_id FROM tenants WHERE status = 'aktif' ORDER BY id LIMIT 4`);
    const roomPrices = await client.query(`SELECT id, harga FROM rooms WHERE id IN ($1, $2, $3, $4)`,
      [rooms.rows[0].id, rooms.rows[1].id, rooms.rows[2].id, rooms.rows[3].id]);

    if (tenants.rows.length >= 4) {
      const contractsResult = await client.query(`
        INSERT INTO contracts (tenant_id, kamar_id, tanggal_mulai, harga_per_bulan, deposit, status) VALUES
        ($1, $2, '2024-01-01', $3, 1500000, 'aktif'),
        ($4, $5, '2024-01-15', $6, 1500000, 'aktif'),
        ($7, $8, '2024-02-01', $9, 2000000, 'aktif'),
        ($10, $11, '2024-02-15', $12, 2500000, 'aktif')
        RETURNING id
      `, [
        tenants.rows[0].id, tenants.rows[0].kamar_id, roomPrices.rows[0].harga,
        tenants.rows[1].id, tenants.rows[1].kamar_id, roomPrices.rows[1].harga,
        tenants.rows[2].id, tenants.rows[2].kamar_id, roomPrices.rows[2].harga,
        tenants.rows[3].id, tenants.rows[3].kamar_id, roomPrices.rows[3].harga,
      ]);

      console.log(`✅ ${contractsResult.rows.length} contracts seeded\n`);
    }

    // ============================================
    // 5. SEED BILLS
    // ============================================
    console.log('💰 Seeding bills...');

    const contracts = await client.query(`SELECT id, tenant_id, harga_per_bulan FROM contracts WHERE status = 'aktif' ORDER BY id LIMIT 4`);

    if (contracts.rows.length >= 4) {
      const billsResult = await client.query(`
        INSERT INTO bills (tenant_id, contract_id, bulan, tahun, jumlah, status, jatuh_tempo, denda) VALUES
        ($1, $2, 'Januari', 2024, $3, 'lunas', '2024-01-10', 0),
        ($1, $2, 'Februari', 2024, $3, 'lunas', '2024-02-10', 0),
        ($1, $2, 'Maret', 2024, $3, 'belum_lunas', '2024-03-10', 0),
        ($4, $5, 'Januari', 2024, $6, 'lunas', '2024-01-10', 0),
        ($4, $5, 'Februari', 2024, $6, 'belum_lunas', '2024-02-10', 0),
        ($7, $8, 'Februari', 2024, $9, 'lunas', '2024-02-10', 0),
        ($7, $8, 'Maret', 2024, $9, 'belum_lunas', '2024-03-10', 0),
        ($10, $11, 'Februari', 2024, $12, 'belum_lunas', '2024-02-10', 0)
        ON CONFLICT (tenant_id, bulan, tahun) DO NOTHING
        RETURNING id
      `, [
        contracts.rows[0].tenant_id, contracts.rows[0].id, contracts.rows[0].harga_per_bulan,
        contracts.rows[1].tenant_id, contracts.rows[1].id, contracts.rows[1].harga_per_bulan,
        contracts.rows[2].tenant_id, contracts.rows[2].id, contracts.rows[2].harga_per_bulan,
        contracts.rows[3].tenant_id, contracts.rows[3].id, contracts.rows[3].harga_per_bulan,
      ]);

      console.log(`✅ ${billsResult.rows.length} bills seeded\n`);
    }

    // ============================================
    // 6. SEED PAYMENTS
    // ============================================
    console.log('💳 Seeding payments...');

    const bills = await client.query(`SELECT id, tenant_id, jumlah FROM bills WHERE status = 'lunas' ORDER BY id LIMIT 4`);
    const admin = await client.query(`SELECT id FROM users WHERE role = 'admin' LIMIT 1`);

    if (bills.rows.length >= 4 && admin.rows.length > 0) {
      const paymentsResult = await client.query(`
        INSERT INTO payments (bill_id, tenant_id, jumlah, tanggal_bayar, metode_pembayaran, status, keterangan, verified_by, verified_at) VALUES
        ($1, $2, $3, '2024-01-08', 'Transfer Bank', 'lunas', 'Pembayaran telah diverifikasi', $4, NOW()),
        ($5, $6, $7, '2024-02-07', 'Transfer Bank', 'lunas', 'Pembayaran telah diverifikasi', $4, NOW()),
        ($8, $9, $10, '2024-01-09', 'Transfer Bank', 'lunas', 'Pembayaran telah diverifikasi', $4, NOW()),
        ($11, $12, $13, '2024-02-08', 'Transfer Bank', 'lunas', 'Pembayaran telah diverifikasi', $4, NOW())
        RETURNING id
      `, [
        bills.rows[0].id, bills.rows[0].tenant_id, bills.rows[0].jumlah, admin.rows[0].id,
        bills.rows[1].id, bills.rows[1].tenant_id, bills.rows[1].jumlah,
        bills.rows[2].id, bills.rows[2].tenant_id, bills.rows[2].jumlah,
        bills.rows[3].id, bills.rows[3].tenant_id, bills.rows[3].jumlah,
      ]);

      console.log(`✅ ${paymentsResult.rows.length} payments seeded\n`);
    }

    // ============================================
    // 7. SEED MAINTENANCE
    // ============================================
    console.log('🔧 Seeding maintenance requests...');

    const activeTenants = await client.query(`SELECT id, kamar_id FROM tenants WHERE status = 'aktif' ORDER BY id LIMIT 3`);

    if (activeTenants.rows.length >= 3) {
      const maintenanceResult = await client.query(`
        INSERT INTO maintenance (tenant_id, kamar_id, judul, deskripsi, kategori, prioritas, status, tanggal_lapor) VALUES
        ($1, $2, 'AC Tidak Dingin', 'AC di kamar tidak dingin, sudah dicoba dibersihkan tapi tetap tidak dingin', 'Elektronik', 'tinggi', 'diproses', CURRENT_DATE),
        ($3, $4, 'Keran Air Bocor', 'Keran air di kamar mandi bocor dan menetes terus', 'Sanitasi', 'sedang', 'baru', CURRENT_DATE),
        ($5, $6, 'Lampu Mati', 'Lampu kamar mati total, sepertinya masalah listrik', 'Elektronik', 'urgent', 'baru', CURRENT_DATE)
        RETURNING id
      `, [
        activeTenants.rows[0].id, activeTenants.rows[0].kamar_id,
        activeTenants.rows[1].id, activeTenants.rows[1].kamar_id,
        activeTenants.rows[2].id, activeTenants.rows[2].kamar_id,
      ]);

      console.log(`✅ ${maintenanceResult.rows.length} maintenance requests seeded\n`);
    }

    // ============================================
    // 8. SEED ANNOUNCEMENTS
    // ============================================
    console.log('📢 Seeding announcements...');

    if (admin.rows.length > 0) {
      const announcementsResult = await client.query(`
        INSERT INTO announcements (judul, konten, kategori, prioritas, target, created_by, is_active) VALUES
        ('Pembayaran Bulan Maret', 'Mohon untuk segera melakukan pembayaran kos bulan Maret paling lambat tanggal 10 Maret 2024', 'Pembayaran', 'penting', 'tenant', $1, true),
        ('Pemadaman Listrik', 'Akan ada pemadaman listrik pada hari Minggu, 10 Maret 2024 pukul 08:00 - 12:00 WIB', 'Informasi', 'urgent', 'semua', $1, true),
        ('Jadwal Kebersihan', 'Jadwal pembersihan area umum setiap hari Senin dan Kamis pukul 09:00 WIB', 'Informasi', 'info', 'semua', $1, true)
        RETURNING id
      `, [admin.rows[0].id]);

      console.log(`✅ ${announcementsResult.rows.length} announcements seeded\n`);
    }

    await client.query('COMMIT');

    console.log('✅ Seeding completed successfully!\n');
    console.log('📊 Database is ready with dummy data.\n');
    console.log('🔑 Login Credentials:');
    console.log('   Admin: admin@kosterpadu.com / admin123');
    console.log('   Tenant: budi@email.com / tenant123\n');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Seeding failed:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

// Run seed
seed()
  .then(() => {
    console.log('🎉 All done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Fatal error:', error);
    process.exit(1);
  });
