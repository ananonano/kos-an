// ============================================
// DATABASE MIGRATION SCRIPT
// ============================================

import { pool } from './database';

async function migrate() {
  const client = await pool.connect();

  try {
    console.log('🚀 Starting database migration...\n');

    await client.query('BEGIN');

    // ============================================
    // 1. USERS TABLE
    // ============================================
    console.log('📋 Creating users table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        nama VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL DEFAULT 'tenant' CHECK (role IN ('admin', 'tenant')),
        no_telepon VARCHAR(20),
        foto TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Users table created\n');

    // ============================================
    // 2. ROOMS TABLE
    // ============================================
    console.log('📋 Creating rooms table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS rooms (
        id SERIAL PRIMARY KEY,
        nomor_kamar VARCHAR(50) UNIQUE NOT NULL,
        tipe VARCHAR(100) NOT NULL,
        harga DECIMAL(12, 2) NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'kosong' CHECK (status IN ('kosong', 'terisi')),
        deskripsi TEXT,
        fasilitas JSONB,
        foto TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Rooms table created\n');

    // ============================================
    // 3. TENANTS TABLE
    // ============================================
    console.log('📋 Creating tenants table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS tenants (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        kamar_id INTEGER REFERENCES rooms(id) ON DELETE SET NULL,
        nama VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        no_telepon VARCHAR(20) NOT NULL,
        alamat_asal TEXT,
        pekerjaan VARCHAR(255),
        kontak_darurat VARCHAR(20),
        tanggal_masuk DATE,
        tanggal_keluar DATE,
        status VARCHAR(50) NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif', 'tidak_aktif')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Tenants table created\n');

    // ============================================
    // 4. CONTRACTS TABLE
    // ============================================
    console.log('📋 Creating contracts table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS contracts (
        id SERIAL PRIMARY KEY,
        tenant_id INTEGER REFERENCES tenants(id) ON DELETE CASCADE,
        kamar_id INTEGER REFERENCES rooms(id) ON DELETE CASCADE,
        tanggal_mulai DATE NOT NULL,
        tanggal_selesai DATE,
        harga_per_bulan DECIMAL(12, 2) NOT NULL,
        deposit DECIMAL(12, 2) NOT NULL DEFAULT 0,
        status VARCHAR(50) NOT NULL DEFAULT 'aktif' CHECK (status IN ('aktif', 'selesai', 'dibatalkan')),
        catatan TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Contracts table created\n');

    // ============================================
    // 5. BILLS TABLE
    // ============================================
    console.log('📋 Creating bills table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS bills (
        id SERIAL PRIMARY KEY,
        tenant_id INTEGER REFERENCES tenants(id) ON DELETE CASCADE,
        contract_id INTEGER REFERENCES contracts(id) ON DELETE CASCADE,
        bulan VARCHAR(50) NOT NULL,
        tahun INTEGER NOT NULL,
        jumlah DECIMAL(12, 2) NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'belum_lunas' CHECK (status IN ('belum_lunas', 'lunas', 'terlambat')),
        jatuh_tempo DATE NOT NULL,
        denda DECIMAL(12, 2) DEFAULT 0,
        catatan TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(tenant_id, bulan, tahun)
      )
    `);
    console.log('✅ Bills table created\n');

    // ============================================
    // 6. PAYMENTS TABLE
    // ============================================
    console.log('📋 Creating payments table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS payments (
        id SERIAL PRIMARY KEY,
        bill_id INTEGER REFERENCES bills(id) ON DELETE CASCADE,
        tenant_id INTEGER REFERENCES tenants(id) ON DELETE CASCADE,
        jumlah DECIMAL(12, 2) NOT NULL,
        tanggal_bayar DATE NOT NULL,
        metode_pembayaran VARCHAR(100) NOT NULL,
        bukti_pembayaran TEXT,
        status VARCHAR(50) NOT NULL DEFAULT 'menunggu_verifikasi' CHECK (status IN ('menunggu_verifikasi', 'lunas', 'ditolak')),
        keterangan TEXT,
        verified_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
        verified_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Payments table created\n');

    // ============================================
    // 7. MAINTENANCE TABLE
    // ============================================
    console.log('📋 Creating maintenance table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS maintenance (
        id SERIAL PRIMARY KEY,
        tenant_id INTEGER REFERENCES tenants(id) ON DELETE CASCADE,
        kamar_id INTEGER REFERENCES rooms(id) ON DELETE CASCADE,
        judul VARCHAR(255) NOT NULL,
        deskripsi TEXT NOT NULL,
        kategori VARCHAR(100) NOT NULL,
        prioritas VARCHAR(50) NOT NULL DEFAULT 'sedang' CHECK (prioritas IN ('rendah', 'sedang', 'tinggi', 'urgent')),
        status VARCHAR(50) NOT NULL DEFAULT 'baru' CHECK (status IN ('baru', 'diproses', 'selesai', 'ditolak')),
        foto JSONB,
        tanggal_lapor DATE NOT NULL,
        tanggal_selesai DATE,
        komentar_admin TEXT,
        biaya DECIMAL(12, 2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Maintenance table created\n');

    // ============================================
    // 8. ANNOUNCEMENTS TABLE
    // ============================================
    console.log('📋 Creating announcements table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS announcements (
        id SERIAL PRIMARY KEY,
        judul VARCHAR(255) NOT NULL,
        konten TEXT NOT NULL,
        kategori VARCHAR(100) NOT NULL,
        prioritas VARCHAR(50) NOT NULL DEFAULT 'info' CHECK (prioritas IN ('info', 'penting', 'urgent')),
        target VARCHAR(50) NOT NULL DEFAULT 'semua' CHECK (target IN ('semua', 'tenant', 'admin')),
        created_by INTEGER REFERENCES users(id) ON DELETE CASCADE,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Announcements table created\n');

    // ============================================
    // 9. NOTIFICATIONS TABLE
    // ============================================
    console.log('📋 Creating notifications table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        type VARCHAR(50) NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        reference_id INTEGER,
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Notifications table created\n');

    // ============================================
    // CREATE INDEXES FOR PERFORMANCE
    // ============================================
    console.log('📋 Creating indexes...');

    await client.query('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_rooms_status ON rooms(status)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_tenants_user_id ON tenants(user_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_tenants_kamar_id ON tenants(kamar_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_tenants_status ON tenants(status)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_contracts_tenant_id ON contracts(tenant_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_contracts_kamar_id ON contracts(kamar_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_contracts_status ON contracts(status)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_bills_tenant_id ON bills(tenant_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_bills_status ON bills(status)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_bills_bulan_tahun ON bills(bulan, tahun)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_payments_bill_id ON payments(bill_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_payments_tenant_id ON payments(tenant_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_maintenance_tenant_id ON maintenance(tenant_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_maintenance_kamar_id ON maintenance(kamar_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_maintenance_status ON maintenance(status)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_maintenance_prioritas ON maintenance(prioritas)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_announcements_is_active ON announcements(is_active)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_announcements_target ON announcements(target)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id)');
    await client.query('CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read)');

    console.log('✅ Indexes created\n');

    await client.query('COMMIT');

    console.log('✅ Migration completed successfully!\n');
    console.log('📊 Database schema is ready for use.\n');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

// Run migration
migrate()
  .then(() => {
    console.log('🎉 All done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Fatal error:', error);
    process.exit(1);
  });
