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

    await client.query(`
      INSERT INTO users (email, password, nama, role, no_telepon) VALUES
      ('admin@kosterpadu.com', $1, 'Admin Kos Terpadu', 'admin', '081234567890'),
      ('budi@email.com', $2, 'Budi Santoso', 'tenant', '081234567891'),
      ('ani@email.com', $3, 'Ani Wijaya', 'tenant', '081234567892'),
      ('citra@email.com', $4, 'Citra Dewi', 'tenant', '081234567893'),
      ('doni@email.com', $5, 'Doni Pratama', 'tenant', '081234567894')
      ON CONFLICT (email) DO NOTHING
    `, [adminPassword, tenantPassword, tenantPassword, tenantPassword, tenantPassword]);

    console.log(`✅ Users seeded\n`);

    // ============================================
    // 2. SEED ROOMS
    // ============================================
    console.log('🏠 Seeding rooms...');

    await client.query(`
      INSERT INTO rooms (nomor_kamar, tipe, harga, status, deskripsi, fasilitas) VALUES
      ('A1', 'Standard', 1500000, 'terisi', 'Kamar nyaman dengan AC', '["AC", "Kasur", "Lemari", "Meja Belajar"]'),
      ('A2', 'Standard', 1500000, 'terisi', 'Kamar nyaman dengan AC', '["AC", "Kasur", "Lemari", "Meja Belajar"]'),
      ('A3', 'Standard', 1500000, 'kosong', 'Kamar nyaman dengan AC', '["AC", "Kasur", "Lemari", "Meja Belajar"]'),
      ('B1', 'Deluxe', 2000000, 'terisi', 'Kamar mewah dengan kamar mandi dalam', '["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV"]'),
      ('B2', 'Deluxe', 2000000, 'kosong', 'Kamar mewah dengan kamar mandi dalam', '["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV"]'),
      ('C1', 'Premium', 2500000, 'terisi', 'Kamar premium dengan balkon', '["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV", "Balkon", "Kulkas"]'),
      ('C2', 'Premium', 2500000, 'kosong', 'Kamar premium dengan balkon', '["AC", "Kasur", "Lemari", "Meja Belajar", "Kamar Mandi Dalam", "TV", "Balkon", "Kulkas"]'),
      ('D1', 'Standard', 1500000, 'kosong', 'Kamar nyaman dengan AC', '["AC", "Kasur", "Lemari", "Meja Belajar"]')
      ON CONFLICT (nomor_kamar) DO NOTHING
    `);

    console.log(`✅ Rooms seeded\n`);

    // ============================================
    // 3. SEED TENANTS
    // ============================================
    console.log('👥 Seeding tenants...');

    // Get user IDs
    const usersResult = await client.query(`SELECT id, email FROM users WHERE role = 'tenant' ORDER BY id LIMIT 4`);
    const roomsResult = await client.query(`SELECT id, nomor_kamar FROM rooms WHERE status = 'terisi' ORDER BY id LIMIT 4`);
    const users = usersResult.rows;
    const rooms = roomsResult.rows;

    if (users.length >= 4 && rooms.length >= 4) {
      await client.query(`
        INSERT INTO tenants (user_id, kamar_id, nama, email, no_telepon, alamat_asal, pekerjaan, kontak_darurat, tanggal_masuk, status) VALUES
        ($1, $2, 'Budi Santoso', 'budi@email.com', '081234567891', 'Jakarta', 'Karyawan Swasta', '081234567801', '2024-01-01', 'aktif'),
        ($3, $4, 'Ani Wijaya', 'ani@email.com', '081234567892', 'Bandung', 'Mahasiswa', '081234567802', '2024-01-15', 'aktif'),
        ($5, $6, 'Citra Dewi', 'citra@email.com', '081234567893', 'Surabaya', 'Freelancer', '081234567803', '2024-02-01', 'aktif'),
        ($7, $8, 'Doni Pratama', 'doni@email.com', '081234567894', 'Yogyakarta', 'Karyawan Swasta', '081234567804', '2024-02-15', 'aktif')
      `, [
        users[0].id, rooms[0].id,
        users[1].id, rooms[1].id,
        users[2].id, rooms[2].id,
        users[3].id, rooms[3].id,
      ]);

      console.log(`✅ Tenants seeded\n`);
    }

    // ============================================
    // 4. SEED CONTRACTS
    // ============================================
    console.log('📄 Seeding contracts...');

    const tenantsResult = await client.query(`SELECT id, kamar_id FROM tenants WHERE status = 'aktif' ORDER BY id LIMIT 4`);
    const roomPricesResult = await client.query(`SELECT id, harga FROM rooms WHERE id IN ($1, $2, $3, $4)`,
      [rooms[0].id, rooms[1].id, rooms[2].id, rooms[3].id]);
    const tenants = tenantsResult.rows;
    const roomPrices = roomPricesResult.rows;

    if (tenants.length >= 4) {
      await client.query(`
        INSERT INTO contracts (tenant_id, kamar_id, tanggal_mulai, harga_per_bulan, deposit, status) VALUES
        ($1, $2, '2024-01-01', $3, 1500000, 'aktif'),
        ($4, $5, '2024-01-15', $6, 1500000, 'aktif'),
        ($7, $8, '2024-02-01', $9, 2000000, 'aktif'),
        ($10, $11, '2024-02-15', $12, 2500000, 'aktif')
      `, [
        tenants[0].id, tenants[0].kamar_id, roomPrices[0].harga,
        tenants[1].id, tenants[1].kamar_id, roomPrices[1].harga,
        tenants[2].id, tenants[2].kamar_id, roomPrices[2].harga,
        tenants[3].id, tenants[3].kamar_id, roomPrices[3].harga,
      ]);

      console.log(`✅ Contracts seeded\n`);
    }

    // ============================================
    // 5. SEED BILLS
    // ============================================
    console.log('💰 Seeding bills...');

    const contractsResult = await client.query(`SELECT id, tenant_id, harga_per_bulan FROM contracts WHERE status = 'aktif' ORDER BY id LIMIT 4`);
    const contracts = contractsResult.rows;

    if (contracts.length >= 4) {
      await client.query(`
        INSERT INTO bills (tenant_id, contract_id, bulan, tahun, jumlah, status, jatuh_tempo, denda) VALUES
        ($1, $2, 'Januari', 2024, $3, 'lunas', '2024-01-10', 0),
        ($4, $5, 'Februari', 2024, $6, 'lunas', '2024-02-10', 0),
        ($7, $8, 'Maret', 2024, $9, 'belum_lunas', '2024-03-10', 0),
        ($10, $11, 'Januari', 2024, $12, 'lunas', '2024-01-10', 0),
        ($13, $14, 'Februari', 2024, $15, 'belum_lunas', '2024-02-10', 0),
        ($16, $17, 'Februari', 2024, $18, 'lunas', '2024-02-10', 0),
        ($19, $20, 'Maret', 2024, $21, 'belum_lunas', '2024-03-10', 0),
        ($22, $23, 'Februari', 2024, $24, 'belum_lunas', '2024-02-10', 0)
        ON CONFLICT DO NOTHING
      `, [
        contracts[0].tenant_id, contracts[0].id, contracts[0].harga_per_bulan,
        contracts[0].tenant_id, contracts[0].id, contracts[0].harga_per_bulan,
        contracts[0].tenant_id, contracts[0].id, contracts[0].harga_per_bulan,
        contracts[1].tenant_id, contracts[1].id, contracts[1].harga_per_bulan,
        contracts[1].tenant_id, contracts[1].id, contracts[1].harga_per_bulan,
        contracts[2].tenant_id, contracts[2].id, contracts[2].harga_per_bulan,
        contracts[2].tenant_id, contracts[2].id, contracts[2].harga_per_bulan,
        contracts[3].tenant_id, contracts[3].id, contracts[3].harga_per_bulan,
      ]);

      console.log(`✅ Bills seeded\n`);
    }

    // ============================================
    // 6. SEED PAYMENTS
    // ============================================
    console.log('💳 Seeding payments...');

    const billsResult = await client.query(`SELECT id, tenant_id, jumlah FROM bills WHERE status = 'lunas' ORDER BY id LIMIT 4`);
    const adminResult = await client.query(`SELECT id FROM users WHERE role = 'admin' LIMIT 1`);
    const bills = billsResult.rows;
    const admin = adminResult.rows;

    if (bills.length >= 4 && admin.length > 0) {
      await client.query(`
        INSERT INTO payments (bill_id, tenant_id, jumlah, tanggal_bayar, metode_pembayaran, status, keterangan, verified_by, verified_at) VALUES
        ($1, $2, $3, '2024-01-08', 'Transfer Bank', 'lunas', 'Pembayaran telah diverifikasi', $4, NOW()),
        ($5, $6, $7, '2024-02-07', 'Transfer Bank', 'lunas', 'Pembayaran telah diverifikasi', $8, NOW()),
        ($9, $10, $11, '2024-01-09', 'Transfer Bank', 'lunas', 'Pembayaran telah diverifikasi', $12, NOW()),
        ($13, $14, $15, '2024-02-08', 'Transfer Bank', 'lunas', 'Pembayaran telah diverifikasi', $16, NOW())
      `, [
        bills[0].id, bills[0].tenant_id, bills[0].jumlah, admin[0].id,
        bills[1].id, bills[1].tenant_id, bills[1].jumlah, admin[0].id,
        bills[2].id, bills[2].tenant_id, bills[2].jumlah, admin[0].id,
        bills[3].id, bills[3].tenant_id, bills[3].jumlah, admin[0].id,
      ]);

      console.log(`✅ Payments seeded\n`);
    }

    // ============================================
    // 7. SEED MAINTENANCE
    // ============================================
    console.log('🔧 Seeding maintenance requests...');

    const activeTenantsResult = await client.query(`SELECT id, kamar_id FROM tenants WHERE status = 'aktif' ORDER BY id LIMIT 3`);
    const activeTenants = activeTenantsResult.rows;

    if (activeTenants.length >= 3) {
      await client.query(`
        INSERT INTO maintenance (tenant_id, kamar_id, judul, deskripsi, kategori, prioritas, status, tanggal_lapor) VALUES
        ($1, $2, 'AC Tidak Dingin', 'AC di kamar tidak dingin, sudah dicoba dibersihkan tapi tetap tidak dingin', 'Elektronik', 'tinggi', 'diproses', CURRENT_DATE),
        ($3, $4, 'Keran Air Bocor', 'Keran air di kamar mandi bocor dan menetes terus', 'Sanitasi', 'sedang', 'baru', CURRENT_DATE),
        ($5, $6, 'Lampu Mati', 'Lampu kamar mati total, sepertinya masalah listrik', 'Elektronik', 'urgent', 'baru', CURRENT_DATE)
      `, [
        activeTenants[0].id, activeTenants[0].kamar_id,
        activeTenants[1].id, activeTenants[1].kamar_id,
        activeTenants[2].id, activeTenants[2].kamar_id,
      ]);

      console.log(`✅ Maintenance requests seeded\n`);
    }

    // ============================================
    // 8. SEED ANNOUNCEMENTS
    // ============================================
    console.log('📢 Seeding announcements...');

    if (admin.length > 0) {
      await client.query(`
        INSERT INTO announcements (judul, konten, kategori, prioritas, target, created_by, is_active) VALUES
        ('Pembayaran Bulan Maret', 'Mohon untuk segera melakukan pembayaran kos bulan Maret paling lambat tanggal 10 Maret 2024', 'Pembayaran', 'penting', 'tenant', $1, true),
        ('Pemadaman Listrik', 'Akan ada pemadaman listrik pada hari Minggu, 10 Maret 2024 pukul 08:00 - 12:00 WIB', 'Informasi', 'urgent', 'semua', $2, true),
        ('Jadwal Kebersihan', 'Jadwal pembersihan area umum setiap hari Senin dan Kamis pukul 09:00 WIB', 'Informasi', 'info', 'semua', $3, true)
      `, [admin[0].id, admin[0].id, admin[0].id]);

      console.log(`✅ Announcements seeded\n`);
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
