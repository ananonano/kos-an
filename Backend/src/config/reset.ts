import { pool } from './database';

async function resetDatabase() {
    console.log('🔄 Resetting database...\n');

    try {
        const client = await pool.connect();

        console.log('🗑️  Dropping all tables...');

        await client.query('DROP TABLE IF EXISTS announcements CASCADE');
        await client.query('DROP TABLE IF EXISTS maintenance CASCADE');
        await client.query('DROP TABLE IF EXISTS payments CASCADE');
        await client.query('DROP TABLE IF EXISTS bills CASCADE');
        await client.query('DROP TABLE IF EXISTS contracts CASCADE');
        await client.query('DROP TABLE IF EXISTS tenants CASCADE');
        await client.query('DROP TABLE IF EXISTS rooms CASCADE');
        await client.query('DROP TABLE IF EXISTS users CASCADE');

        console.log('✅ All tables dropped\n');

        client.release();

        console.log('✅ Database reset completed!\n');
        console.log('📝 Run "npm run migrate" to recreate tables');
        console.log('🌱 Run "npm run seed" to populate with dummy data\n');

        process.exit(0);
    } catch (error) {
        console.error('❌ Reset failed:', error);
        process.exit(1);
    }
}

resetDatabase();
