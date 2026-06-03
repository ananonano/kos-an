/**
 * Initialize Billing System
 * 1. Randomize tanggal_masuk for existing tenants
 * 2. Generate bills for all tenants based on their tanggal_masuk
 */

import { pool } from '../config/database';
import { BillModel } from '../models/bill.model';

async function initializeBilling() {
  const client = await pool.connect();

  try {
    console.log('🚀 Starting billing initialization...\n');

    // Step 1: Randomize tanggal_masuk for existing tenants (if null)
    console.log('📅 Step 1: Setting random tanggal_masuk for existing tenants...');

    // Random tanggal_masuk between 30-60 days ago (max 2 months)
    const updateQuery = `
      UPDATE tenants
      SET tanggal_masuk = (
        CURRENT_DATE - (FLOOR(RANDOM() * 30) + 30)::INTEGER
      )
      WHERE tanggal_masuk IS NULL AND status = 'aktif'
      RETURNING id, nama, tanggal_masuk
    `;

    const updatedTenants = await client.query(updateQuery);

    console.log(`✅ Updated ${updatedTenants.rowCount} tenants with random tanggal_masuk:`);
    updatedTenants.rows.forEach((tenant) => {
      console.log(`   - ${tenant.nama}: ${tenant.tanggal_masuk.toISOString().split('T')[0]}`);
    });

    // Step 2: Generate bills for all tenants
    console.log('\n💰 Step 2: Generating bills for all tenants...');

    const results = await BillModel.generateBillsForAllTenants();

    console.log(`\n✅ Bill generation complete!`);
    console.log(`📊 Summary:`);

    let totalBills = 0;
    results.forEach((result) => {
      console.log(`   - Tenant ID ${result.tenant_id}: ${result.bills_created} bills created`);
      totalBills += result.bills_created;
    });

    console.log(`\n🎉 Total: ${totalBills} bills created for ${results.length} tenants`);

    // Step 3: Show some sample bills
    console.log('\n📋 Sample bills:');
    const sampleBills = await client.query(`
      SELECT b.id, t.nama, b.bulan, b.tahun, b.jumlah, b.status, b.jatuh_tempo
      FROM bills b
      JOIN tenants t ON b.tenant_id = t.id
      ORDER BY b.created_at DESC
      LIMIT 5
    `);

    sampleBills.rows.forEach((bill) => {
      console.log(
        `   - ${bill.nama}: ${bill.bulan} ${bill.tahun} - Rp ${bill.jumlah.toLocaleString()} (${bill.status})`
      );
    });

    console.log('\n✅ Billing system initialized successfully!');
  } catch (error) {
    console.error('❌ Error initializing billing:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

// Run the script
initializeBilling()
  .then(() => {
    console.log('\n👋 Done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Failed:', error);
    process.exit(1);
  });
