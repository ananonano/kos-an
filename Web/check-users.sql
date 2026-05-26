-- Check users in database
SELECT id, nama, email, role, created_at 
FROM users 
ORDER BY id;

-- Check if there's an admin user
SELECT id, nama, email, role 
FROM users 
WHERE role = 'admin';
