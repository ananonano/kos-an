/**
 * Add Notifications System
 * 1. Create notifications table for payment notifications
 * 2. Create user_announcement_reads table to track read announcements
 */

import { pool } from '../config/database';

async function addNotificationsSystem() {
  const client = await pool.connect();

  try {
    console.log('🚀 Adding notifications system...\n');

    await client.query('BEGIN');

    // 1. Create notifications table
    console.log('📋 Creating notifications table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        type VARCHAR(50) NOT NULL, -- 'payment_submitted', 'payment_approved', 'payment_rejected', etc.
        related_id INT, -- payment_id, bill_id, etc.
        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('✅ notifications table created');

    // Create index for faster queries
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
      CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
    `);
    console.log('✅ Indexes created');

    // 2. Create user_announcement_reads junction table
    console.log('\n📋 Creating user_announcement_reads table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_announcement_reads (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        announcement_id INT NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
        read_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, announcement_id)
      )
    `);
    console.log('✅ user_announcement_reads table created');

    // Create index
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_user_announcement_reads_user ON user_announcement_reads(user_id);
      CREATE INDEX IF NOT EXISTS idx_user_announcement_reads_announcement ON user_announcement_reads(announcement_id);
    `);
    console.log('✅ Indexes created');

    await client.query('COMMIT');

    console.log('\n🎉 Notifications system added successfully!');
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error adding notifications system:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

// Run the script
addNotificationsSystem()
  .then(() => {
    console.log('\n👋 Done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Failed:', error);
    process.exit(1);
  });
